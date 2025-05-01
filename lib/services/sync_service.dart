import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../repositories/character_repository.dart';
import '../repositories/google_drive_character_repository.dart';
import 'google_auth_client.dart';
import '../repositories/mappers/character_mapper.dart';

class SyncService extends ChangeNotifier {
  static const String _prefSyncEnabled = 'sync_enabled';
  static const String _prefLastSync = 'last_sync';
  static const String _appFolderName = 'TTRPG Character Manager';
  
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;
  final CharacterRepository _localRepo;
  final GoogleDriveCharacterRepository _cloudRepo;
  
  drive.DriveApi? _driveApi;
  String? _appFolderId;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _syncDebouncer;
  bool _hasPendingChanges = false;
  
  SyncService({
    required GoogleSignIn googleSignIn,
    required SharedPreferences prefs,
    required CharacterRepository localRepo,
    required GoogleDriveCharacterRepository cloudRepo,
  }) : _googleSignIn = googleSignIn,
       _prefs = prefs,
       _localRepo = localRepo,
       _cloudRepo = cloudRepo {
    _lastSyncTime = _getLastSyncTime();
    // Listen to local repository changes
    _localRepo.addListener(_onRepositoryChanged);
  }
  
  @override
  void dispose() {
    _syncDebouncer?.cancel();
    _localRepo.removeListener(_onRepositoryChanged);
    super.dispose();
  }
  
  // Public getters
  bool get isEnabled => _prefs.getBool(_prefSyncEnabled) ?? false;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get currentAccount => _googleSignIn.currentUser?.email;
  bool get hasPendingChanges => _hasPendingChanges;
  
  void _onRepositoryChanged() {
    if (!isEnabled) return;
    _hasPendingChanges = true;
    notifyListeners();
    _debouncedSync();
  }
  
  void _debouncedSync() {
    // Cancel any pending sync
    _syncDebouncer?.cancel();
    
    // Schedule a new sync in 5 seconds
    _syncDebouncer = Timer(const Duration(seconds: 5), () async {
      try {
        if (!isEnabled || !_hasPendingChanges) return;
        
        await syncNow();
        _hasPendingChanges = false;
        notifyListeners();
      } catch (e) {
        // Keep _hasPendingChanges true so we can retry later
      }
    });
  }
  
  // Enable sync
  Future<void> enableSync() async {
    try {
      _isSyncing = true;
      notifyListeners();
      
      // Sign in to Google
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Sign in cancelled or failed');
      }

      // Get auth client
      try {
        final auth = await account.authHeaders;
        final client = GoogleAuthClient(auth);
        _driveApi = drive.DriveApi(client);
      } catch (authError) {
        rethrow;
      }
      
      // Initialize Drive folder
      try {
        _appFolderId = await _getOrCreateAppFolder();
      } catch (folderError) {
        rethrow;
      }
      // Do initial sync
      await _syncData();

      // Save preferences
      await _prefs.setBool(_prefSyncEnabled, true);

      _isSyncing = false;
      notifyListeners();

    } catch (e, stackTrace) {
      print(stackTrace);

      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Disable sync
  Future<void> disableSync() async {
    await _googleSignIn.signOut();
    await _prefs.setBool(_prefSyncEnabled, false);
    _driveApi = null;
    _appFolderId = null;
    notifyListeners();
  }
  
  // Manual sync
  Future<void> syncNow() async {
    if (!isEnabled) return;
    
    try {
      _isSyncing = true;
      notifyListeners();
      
      await _syncData();
      _hasPendingChanges = false;
      
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Remove cloud data
  Future<void> removeCloudData() async {
    if (_driveApi == null || _appFolderId == null) return;
    
    try {
      _isSyncing = true;
      notifyListeners();
      
      // List all files in app folder
      final files = await _driveApi!.files.list(
        q: "'$_appFolderId' in parents",
        spaces: 'drive',
      );
      
      // Delete each file
      for (final file in files.files ?? []) {
        await _driveApi!.files.delete(file.id!);
      }
      
      // Delete app folder
      await _driveApi!.files.delete(_appFolderId!);
      
      _appFolderId = null;
      await _updateLastSyncTime(null);
      
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Private methods
  Future<String> _getOrCreateAppFolder() async {
    if (_driveApi == null) throw Exception('Drive API not initialized');
    
    // Try to find existing folder
    final query = "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder'";
    final result = await _driveApi!.files.list(q: query);
    
    if (result.files?.isNotEmpty ?? false) {
      return result.files!.first.id!;
    }
    
    // Create new folder
    final folder = drive.File()
      ..name = _appFolderName
      ..mimeType = 'application/vnd.google-apps.folder';
    
    final created = await _driveApi!.files.create(folder);
    return created.id!;
  }
  
  Future<void> _syncData() async {
    if (_driveApi == null || _appFolderId == null) return;
    
    // Get local characters
    final localCharacters = await _localRepo.getAllCharacters();
    
    // Get remote characters
    final remoteCharacters = await _cloudRepo.getAllCharacters();
    
    // Merge characters
    final mergedCharacters = _mergeCharacterLists(
      localCharacters,
      remoteCharacters,
    );
    
    // Update local storage
    await _localRepo.updateCharacters(mergedCharacters);
    
    // Update remote storage
    await _cloudRepo.updateCharacters(mergedCharacters);
    
    // Update last sync time
    await _updateLastSyncTime(DateTime.now());
  }
  
  List<Character> _mergeCharacterLists(
    List<Character> local,
    List<Character> remote,
  ) {
    final merged = <String, Character>{};
    
    // Add all local characters
    for (final char in local) {
      merged[char.id] = char;
    }
    
    // Merge remote characters
    for (final char in remote) {
      if (!merged.containsKey(char.id)) {
        // New character from remote
        merged[char.id] = char;
      } else {
        // Character exists locally, keep newest version
        final localChar = merged[char.id]!;
        if (char.lastUsed.isAfter(localChar.lastUsed)) {
          merged[char.id] = char;
        }
      }
    }
    
    return merged.values.toList();
  }
  
  DateTime? _getLastSyncTime() {
    final timestamp = _prefs.getInt(_prefLastSync);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  Future<void> _updateLastSyncTime(DateTime? time) async {
    if (time == null) {
      await _prefs.remove(_prefLastSync);
    } else {
      await _prefs.setInt(_prefLastSync, time.millisecondsSinceEpoch);
    }
    _lastSyncTime = time;
    notifyListeners();
  }
} 
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../models/character.dart';
import 'character_repository.dart';
import 'mappers/character_mapper.dart';
import '../services/google_auth_client.dart';

class GoogleDriveCharacterRepository extends ChangeNotifier implements CharacterRepository {
  static const String _appFolderName = 'TTRPG Character Manager';
  
  final GoogleSignIn _googleSignIn;
  final drive.DriveApi _driveApi;
  String? _appFolderId;
  bool _isInitialized = false;

  GoogleDriveCharacterRepository({
    required GoogleSignIn googleSignIn,
    required drive.DriveApi driveApi,
  }) : _googleSignIn = googleSignIn,
       _driveApi = driveApi;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    try {
      _appFolderId = await _getOrCreateAppFolder();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Google Drive repository: $e');
      rethrow;
    }
  }

  Future<String> _getOrCreateAppFolder() async {
    // Try to find existing folder
    final query = "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder'";
    final result = await _driveApi.files.list(q: query);
    
    if (result.files?.isNotEmpty ?? false) {
      return result.files!.first.id!;
    }
    
    // Create new folder
    final folder = drive.File()
      ..name = _appFolderName
      ..mimeType = 'application/vnd.google-apps.folder';
    
    final created = await _driveApi.files.create(folder);
    return created.id!;
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    await _ensureInitialized();
    if (_appFolderId == null) return [];

    final result = await _driveApi.files.list(
      q: "'$_appFolderId' in parents",
      spaces: 'drive',
    );
    
    final characters = <Character>[];
    for (final file in result.files ?? []) {
      final content = await _driveApi.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      
      final jsonString = await content.stream
        .transform(const Utf8Decoder())
        .join();
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      characters.add(CharacterMapper.fromJson(jsonMap));
    }
    
    return characters;
  }

  @override
  Future<Character?> getCharacter(String id) async {
    await _ensureInitialized();
    if (_appFolderId == null) return null;

    try {
      final result = await _driveApi.files.list(
        q: "'$_appFolderId' in parents and name='$id.json'",
        spaces: 'drive',
      );
      
      if (result.files?.isEmpty ?? true) return null;
      
      final file = result.files!.first;
      final content = await _driveApi.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      
      final jsonString = await content.stream
        .transform(const Utf8Decoder())
        .join();
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return CharacterMapper.fromJson(jsonMap);
    } catch (e) {
      print('Error getting character from Google Drive: $e');
      return null;
    }
  }

  @override
  Future<void> addCharacter(Character character) async {
    await _ensureInitialized();
    if (_appFolderId == null) return;

    final content = jsonEncode(CharacterMapper.toJson(character));
    final file = drive.File()
      ..name = '${character.id}.json'
      ..parents = [_appFolderId!];
    
    await _driveApi.files.create(
      file,
      uploadMedia: drive.Media(
        Stream.fromIterable([const Utf8Encoder().convert(content)]),
        content.length,
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> updateCharacter(Character character) async {
    await _ensureInitialized();
    if (_appFolderId == null) return;

    // First find the existing file
    final result = await _driveApi.files.list(
      q: "'$_appFolderId' in parents and name='${character.id}.json'",
      spaces: 'drive',
    );
    
    if (result.files?.isEmpty ?? true) {
      // File doesn't exist, create it
      await addCharacter(character);
      return;
    }
    
    // Update existing file
    final file = result.files!.first;
    final content = jsonEncode(CharacterMapper.toJson(character));
    
    await _driveApi.files.update(
      drive.File()..id = file.id,
      file.id!,
      uploadMedia: drive.Media(
        Stream.fromIterable([const Utf8Encoder().convert(content)]),
        content.length,
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> deleteCharacter(String id) async {
    await _ensureInitialized();
    if (_appFolderId == null) return;

    try {
      final result = await _driveApi.files.list(
        q: "'$_appFolderId' in parents and name='$id.json'",
        spaces: 'drive',
      );
      
      if (result.files?.isNotEmpty ?? false) {
        await _driveApi.files.delete(result.files!.first.id!);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting character from Google Drive: $e');
    }
  }

  @override
  Future<void> updateCharacters(List<Character> characters) async {
    await _ensureInitialized();
    if (_appFolderId == null) return;

    // Delete all existing files
    final existing = await _driveApi.files.list(
      q: "'$_appFolderId' in parents",
      spaces: 'drive',
    );
    
    for (final file in existing.files ?? []) {
      await _driveApi.files.delete(file.id!);
    }
    
    // Upload new files
    for (final character in characters) {
      await addCharacter(character);
    }
  }

  @override
  Future<void> syncToCloud() async {
    // No-op, this is the cloud implementation
  }

  @override
  Future<void> syncFromCloud() async {
    // No-op, this is the cloud implementation
  }
} 
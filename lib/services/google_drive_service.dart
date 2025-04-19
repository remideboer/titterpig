import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:ttrpg_character_manager/services/google_auth_client.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      print('=== Google Sign In Debug Log ===');
      print('1. Initializing sign-in process');
      print('Configured scopes: ${_googleSignIn.scopes.join(", ")}');
      
      // Check if already signed in
      final currentUser = _googleSignIn.currentUser;
      print('Current user before sign in: ${currentUser?.email ?? "None"}');
      
      print('2. Attempting to sign in...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        print('❌ Sign in failed: account is null');
        print('This usually means the user cancelled the sign-in or there was a configuration error');
        return null;
      }
      
      print('✓ Successfully signed in!');
      print('Account details:');
      print('- Email: ${account.email}');
      print('- Display Name: ${account.displayName}');
      print('- Server Auth Code available: ${account.serverAuthCode != null}');
      
      print('3. Requesting auth headers...');
      try {
        final headers = await account.authHeaders;
        print('✓ Auth headers received successfully');
        print('Header keys present: ${headers.keys.join(", ")}');
        
        print('4. Creating Drive API client...');
        final client = GoogleAuthClient(headers);
        final driveApi = drive.DriveApi(client);
        print('✓ Drive API client created successfully');
        
        return driveApi;
      } catch (headerError) {
        print('❌ Error getting auth headers:');
        print('Error type: ${headerError.runtimeType}');
        print('Error details: $headerError');
        rethrow;
      }
    } catch (e, stackTrace) {
      print('\n=== Error Details ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('\nStack trace:');
      print(stackTrace);
      print('\nCommon error codes:');
      print('- ApiException 10: Usually indicates an OAuth configuration issue');
      print('- ApiException 12501: Google Play Services is missing or outdated');
      print('- ApiException 12500: Google Play Services is disabled');
      print('======================\n');
      rethrow;  // Rethrow to let the UI handle the error
    }
  }

  Future<String?> uploadFile(String fileName, String content) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      final Stream<List<int>> mediaStream = 
          Stream.value(utf8.encode(content));
      final drive.File fileMetadata = drive.File(
        name: fileName,
        mimeType: 'application/json',
      );

      final response = await driveApi.files.create(
        fileMetadata,
        uploadMedia: drive.Media(mediaStream, content.length),
      );

      return response.id;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<String?> downloadFile(String fileId) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      final response = await driveApi.files
          .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final List<int> dataStore = [];
      await response.stream.forEach((data) {
        dataStore.insertAll(dataStore.length, data);
      });

      return utf8.decode(dataStore);
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  Future<List<drive.File>> listFiles() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return [];

      final fileList = await driveApi.files.list(
        spaces: 'drive',
        q: "mimeType='application/json'",
      );

      return fileList.files ?? [];
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      await driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      print('Error signing out: $e');
      return false;
    }
  }
} 
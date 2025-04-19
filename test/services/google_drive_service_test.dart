import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/services.dart';
import 'package:ttrpg_character_manager/services/google_drive_service.dart';

@GenerateNiceMocks([
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<drive.DriveApi>(),
  MockSpec<drive.FilesResource>(),
])
import 'google_drive_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleDriveService service;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockDriveApi mockDriveApi;
  late MockFilesResource mockFilesResource;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockDriveApi = MockDriveApi();
    mockFilesResource = MockFilesResource();

    // Set up asset bundle
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      return Uint8List.fromList(
        '{"client_id": "test_client_id.apps.googleusercontent.com"}'.codeUnits,
      );
    });

    service = GoogleDriveService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('GoogleDriveService', () {
    test('initialize loads credentials and sets up GoogleSignIn', () async {
      await service.initialize();
      expect(service, isNotNull);
    });

    test('uploadFile successfully uploads a file', () async {
      // Arrange
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.authHeaders)
          .thenAnswer((_) async => {'Authorization': 'Bearer test_token'});
      when(mockDriveApi.files).thenReturn(mockFilesResource);
      when(mockFilesResource.create(
        any,
        uploadMedia: anyNamed('uploadMedia'),
      )).thenAnswer((_) async => drive.File(id: 'test_file_id'));

      // Act
      final result = await service.uploadFile('test.json', '{"test": "data"}');

      // Assert
      expect(result, equals('test_file_id'));
    });

    test('downloadFile successfully downloads a file', () async {
      // Arrange
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.authHeaders)
          .thenAnswer((_) async => {'Authorization': 'Bearer test_token'});
      when(mockDriveApi.files).thenReturn(mockFilesResource);
      
      final mockMedia = drive.Media(
        Stream.value(utf8.encode('{"test": "data"}')),
        13,
      );
      
      when(mockFilesResource.get(
        any,
        downloadOptions: anyNamed('downloadOptions'),
      )).thenAnswer((_) async => mockMedia);

      // Act
      final result = await service.downloadFile('test_file_id');

      // Assert
      expect(result, equals('{"test": "data"}'));
    });

    test('listFiles returns list of files', () async {
      // Arrange
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.authHeaders)
          .thenAnswer((_) async => {'Authorization': 'Bearer test_token'});
      when(mockDriveApi.files).thenReturn(mockFilesResource);
      when(mockFilesResource.list(
        spaces: anyNamed('spaces'),
        q: anyNamed('q'),
      )).thenAnswer((_) async => drive.FileList(files: [
        drive.File(id: 'file1', name: 'test1.json'),
        drive.File(id: 'file2', name: 'test2.json'),
      ]));

      // Act
      final result = await service.listFiles();

      // Assert
      expect(result.length, equals(2));
      expect(result[0].id, equals('file1'));
      expect(result[1].id, equals('file2'));
    });

    test('deleteFile successfully deletes a file', () async {
      // Arrange
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.authHeaders)
          .thenAnswer((_) async => {'Authorization': 'Bearer test_token'});
      when(mockDriveApi.files).thenReturn(mockFilesResource);
      when(mockFilesResource.delete(any))
          .thenAnswer((_) async => null);

      // Act
      final result = await service.deleteFile('test_file_id');

      // Assert
      expect(result, isTrue);
    });

    test('signOut successfully signs out', () async {
      // Arrange
      when(mockGoogleSignIn.signOut())
          .thenAnswer((_) async => mockAccount);

      // Act
      final result = await service.signOut();

      // Assert
      expect(result, isTrue);
    });
  });
} 
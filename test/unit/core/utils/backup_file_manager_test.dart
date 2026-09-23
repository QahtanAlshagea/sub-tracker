import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/utils/backup_file_manager.dart';

void main() {
  group('BackupFileInfo', () {
    test('formats sizes correctly across byte, KB, and MB boundaries', () {
      final dummyFile = File('dummy.json');
      final now = DateTime.now();

      final bytesInfo = BackupFileInfo(
        file: dummyFile,
        fileName: 'dummy.json',
        sizeBytes: 512,
        modifiedAt: now,
      );
      expect(bytesInfo.formattedSize, equals('512 B'));

      final kbInfo = BackupFileInfo(
        file: dummyFile,
        fileName: 'dummy.json',
        sizeBytes: 2048,
        modifiedAt: now,
      );
      expect(kbInfo.formattedSize, equals('2.0 KB'));

      final mbInfo = BackupFileInfo(
        file: dummyFile,
        fileName: 'dummy.json',
        sizeBytes: 1024 * 1024 * 3,
        modifiedAt: now,
      );
      expect(mbInfo.formattedSize, equals('3.0 MB'));
    });
  });

  group('BackupFileManager', () {
    test('saves, reads, and lists backup files in backup directory', () async {
      const jsonPayload = '{"version":2,"subscriptions":[]}';

      final file = await BackupFileManager.saveBackupFile(jsonPayload);
      expect(await file.exists(), isTrue);

      final readContent = await BackupFileManager.readBackupFile(file);
      expect(readContent, equals(jsonPayload));

      final files = await BackupFileManager.listBackupFiles();
      expect(files, isNotEmpty);
      expect(
        files.any((f) => f.fileName == file.uri.pathSegments.last),
        isTrue,
      );

      // Clean up test file
      if (await file.exists()) {
        await file.delete();
      }
    });
  });
}

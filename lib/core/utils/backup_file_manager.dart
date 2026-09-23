import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Metadata for a discovered local backup file.
class BackupFileInfo {
  final File file;
  final String fileName;
  final int sizeBytes;
  final DateTime modifiedAt;

  const BackupFileInfo({
    required this.file,
    required this.fileName,
    required this.sizeBytes,
    required this.modifiedAt,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Offline-first file manager for backing up and restoring database snapshots.
class BackupFileManager {
  const BackupFileManager._();

  /// Returns the standard backup directory for Sub Tracker.
  static Future<Directory> getBackupDirectory() async {
    Directory baseDir;
    try {
      if (Platform.isAndroid) {
        final extDir = await getExternalStorageDirectory();
        baseDir = extDir ?? await getApplicationDocumentsDirectory();
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      try {
        baseDir = await getApplicationDocumentsDirectory();
      } catch (_) {
        baseDir = Directory.systemTemp;
      }
    }

    final backupDir = Directory(p.join(baseDir.path, 'SubTracker_Backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Writes [jsonContent] to a timestamped backup file inside the backup directory.
  static Future<File> saveBackupFile(String jsonContent) async {
    final dir = await getBackupDirectory();
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    final fileName =
        'sub_tracker_backup_${year}_${month}_${day}_$hour$minute$second.json';
    final filePath = p.join(dir.path, fileName);
    final file = File(filePath);

    await file.writeAsString(jsonContent, flush: true);
    return file;
  }

  /// Lists all `.json` backup files sorted by modification date descending (newest first).
  static Future<List<BackupFileInfo>> listBackupFiles() async {
    try {
      final dir = await getBackupDirectory();
      final entities = await dir.list().toList();
      final backupFiles = <BackupFileInfo>[];

      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.json')) {
          final stat = await entity.stat();
          backupFiles.add(
            BackupFileInfo(
              file: entity,
              fileName: p.basename(entity.path),
              sizeBytes: stat.size,
              modifiedAt: stat.modified,
            ),
          );
        }
      }

      backupFiles.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      return backupFiles;
    } catch (_) {
      return [];
    }
  }

  /// Reads and returns string content from [file].
  static Future<String> readBackupFile(File file) async {
    return file.readAsString();
  }
}

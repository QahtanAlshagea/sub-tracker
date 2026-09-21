import '../../../../core/utils/result.dart';
import '../entities/backup_data.dart';
import '../entities/backup_preview.dart';

/// Abstract domain repository interface for Backup, Export, and Import operations.
/// Zero Flutter or persistence dependencies.
abstract class BackupRepository {
  /// Assembles all current database records into a [BackupData] domain entity.
  Future<Result<BackupData>> createBackup();

  /// Serializes the entire application data into a formatted UTF-8 JSON string.
  Future<Result<String>> exportBackupToJson();

  /// Inspects a backup JSON payload without altering local data, providing validation and record counts.
  Future<Result<BackupPreview>> previewBackup(String jsonContent);

  /// Restores the provided JSON payload according to the selected [strategy] (merge or replace)
  /// inside an atomic all-or-nothing transaction.
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  });

  /// Permanently and atomically deletes all user records (subscriptions, price history, custom categories),
  /// restoring the database to a clean initial state while preserving the system uncategorized category ([US-39]).
  Future<Result<void>> wipeDatabase();
}

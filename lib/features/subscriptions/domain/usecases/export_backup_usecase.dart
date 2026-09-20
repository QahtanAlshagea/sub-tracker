import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/backup_repository.dart';

/// Use case for exporting application database records to a JSON backup string.
/// Enforces EC-29-3 by preventing export of an empty database.
class ExportBackupUseCase {
  final BackupRepository _repository;

  const ExportBackupUseCase(this._repository);

  Future<Result<String>> call() async {
    final backupResult = await _repository.createBackup();
    if (backupResult.isFailure) {
      return Result.failure(backupResult.failureOrNull!);
    }

    final backupData = backupResult.valueOrNull!;
    if (backupData.isEmpty) {
      return const Result.failure(EmptyDatabaseFailure());
    }

    return _repository.exportBackupToJson();
  }
}

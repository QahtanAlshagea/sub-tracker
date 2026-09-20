import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/backup_preview.dart';
import '../repositories/backup_repository.dart';

/// Use case for executing backup restoration using the chosen strategy (US-30).
class ImportBackupUseCase {
  final BackupRepository _repository;

  const ImportBackupUseCase(this._repository);

  Future<Result<ImportResult>> call({
    required String jsonContent,
    required ImportStrategy strategy,
  }) async {
    if (jsonContent.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure('Backup content cannot be empty.'),
      );
    }

    return _repository.restoreBackup(
      jsonContent: jsonContent,
      strategy: strategy,
    );
  }
}

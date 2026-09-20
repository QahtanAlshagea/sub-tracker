import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/backup_preview.dart';
import '../repositories/backup_repository.dart';

/// Use case for previewing a backup file before executing import (US-30).
class PreviewBackupUseCase {
  final BackupRepository _repository;

  const PreviewBackupUseCase(this._repository);

  Future<Result<BackupPreview>> call(String jsonContent) async {
    if (jsonContent.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure('Backup content cannot be empty.'),
      );
    }

    return _repository.previewBackup(jsonContent);
  }
}

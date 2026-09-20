import 'dart:io';

import 'package:drift/native.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/entities/backup_preview.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_local_data_source.dart';
import '../models/backup_data_model.dart';

/// Implementation of [BackupRepository] conforming to Clean Architecture.
/// Converts low-level errors to domain [Failure]s and ensures zero raw exceptions leak.
class BackupRepositoryImpl implements BackupRepository {
  final BackupLocalDataSource _dataSource;

  const BackupRepositoryImpl(this._dataSource);

  @override
  Future<Result<BackupData>> createBackup() async {
    try {
      final model = await _dataSource.getBackupData();
      return Result.success(model.toEntity());
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException catch (e) {
      return Result.failure(StorageFullFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> exportBackupToJson() async {
    try {
      final model = await _dataSource.getBackupData();
      final entity = model.toEntity();
      if (entity.isEmpty) {
        return const Result.failure(EmptyDatabaseFailure());
      }

      final jsonStr = model.toJsonString();
      await _dataSource.updateLastBackupAt(DateTime.now().toUtc());
      return Result.success(jsonStr);
    } on EmptyDatabaseFailure catch (e) {
      return Result.failure(e);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException catch (e) {
      return Result.failure(StorageFullFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<BackupPreview>> previewBackup(String jsonContent) async {
    try {
      final model = BackupDataModel.fromJsonString(jsonContent);
      final preview = await _dataSource.previewBackup(model);
      return Result.success(preview);
    } on FormatException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on BackupSchemaVersionTooNewException catch (e) {
      return Result.failure(MigrationFailure(e.toString()));
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(ValidationFailure(e.toString()));
    }
  }

  @override
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  }) async {
    try {
      final model = BackupDataModel.fromJsonString(jsonContent);
      final result = await _dataSource.restoreBackup(
        backupModel: model,
        strategy: strategy,
      );
      return Result.success(result);
    } on FormatException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } on BackupSchemaVersionTooNewException catch (e) {
      return Result.failure(MigrationFailure(e.toString()));
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}

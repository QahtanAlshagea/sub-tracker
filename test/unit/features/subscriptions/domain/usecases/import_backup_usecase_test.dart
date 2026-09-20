import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_data.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/backup_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/import_backup_usecase.dart';

class FakeImportBackupRepository implements BackupRepository {
  final Result<ImportResult> restoreResult;

  FakeImportBackupRepository(this.restoreResult);

  @override
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  }) async => restoreResult;

  @override
  Future<Result<BackupData>> createBackup() => throw UnimplementedError();

  @override
  Future<Result<String>> exportBackupToJson() => throw UnimplementedError();

  @override
  Future<Result<BackupPreview>> previewBackup(String jsonContent) =>
      throw UnimplementedError();
}

void main() {
  group('ImportBackupUseCase Domain Tests (US-30 / FR-17)', () {
    test(
      'returns ValidationFailure when json content is empty or whitespace',
      () async {
        final fakeRepo = FakeImportBackupRepository(
          const Result.failure(ValidationFailure('unused')),
        );

        final usecase = ImportBackupUseCase(fakeRepo);
        final result = await usecase(
          jsonContent: '   ',
          strategy: ImportStrategy.merge,
        );

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        expect(result.failureOrNull?.message, contains('cannot be empty'));
      },
    );

    test('delegates restore to repository with given strategy', () async {
      final fakeRepo = FakeImportBackupRepository(
        const Result.success(
          ImportResult(
            importedCategories: 2,
            importedSubscriptions: 3,
            importedPriceHistories: 1,
            strategy: ImportStrategy.replace,
          ),
        ),
      );

      final usecase = ImportBackupUseCase(fakeRepo);
      final result = await usecase(
        jsonContent: '{"schema_version": 2}',
        strategy: ImportStrategy.replace,
      );

      expect(result.isSuccess, isTrue);
      final importResult = result.valueOrNull!;
      expect(importResult.strategy, equals(ImportStrategy.replace));
      expect(importResult.importedSubscriptions, equals(3));
    });
  });
}

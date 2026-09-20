import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_data.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/backup_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/preview_backup_usecase.dart';

class FakePreviewBackupRepository implements BackupRepository {
  final Result<BackupPreview> previewResult;

  FakePreviewBackupRepository(this.previewResult);

  @override
  Future<Result<BackupPreview>> previewBackup(String jsonContent) async =>
      previewResult;

  @override
  Future<Result<BackupData>> createBackup() => throw UnimplementedError();

  @override
  Future<Result<String>> exportBackupToJson() => throw UnimplementedError();

  @override
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> wipeDatabase() async => const Result.success(null);
}

void main() {
  group('PreviewBackupUseCase Domain Tests (US-30 / FR-17)', () {
    test(
      'returns ValidationFailure when json content is empty or whitespace',
      () async {
        final fakeRepo = FakePreviewBackupRepository(
          const Result.failure(ValidationFailure('unused')),
        );

        final usecase = PreviewBackupUseCase(fakeRepo);
        final result = await usecase('   ');

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        expect(result.failureOrNull?.message, contains('cannot be empty'));
      },
    );

    test('delegates to repository when json content is present', () async {
      final now = DateTime.utc(2026, 9, 20);
      final fakeRepo = FakePreviewBackupRepository(
        Result.success(
          BackupPreview(
            schemaVersion: 2,
            exportedAt: now,
            totalCategories: 3,
            newCategories: 2,
            duplicateCategories: 1,
            totalSubscriptions: 5,
            newSubscriptions: 4,
            duplicateSubscriptions: 1,
            totalPriceHistories: 2,
          ),
        ),
      );

      final usecase = PreviewBackupUseCase(fakeRepo);
      final result = await usecase('{"schema_version": 2}');

      expect(result.isSuccess, isTrue);
      final preview = result.valueOrNull!;
      expect(preview.totalSubscriptions, equals(5));
      expect(preview.newSubscriptions, equals(4));
    });
  });
}

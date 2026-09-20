import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_data.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/backup_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/export_backup_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

class FakeBackupRepository implements BackupRepository {
  BackupData backupData;
  String exportedJson;

  FakeBackupRepository({
    required this.backupData,
    this.exportedJson = '{"schema_version": 2}',
  });

  @override
  Future<Result<BackupData>> createBackup() async => Result.success(backupData);

  @override
  Future<Result<String>> exportBackupToJson() async =>
      Result.success(exportedJson);

  @override
  Future<Result<BackupPreview>> previewBackup(String jsonContent) async =>
      throw UnimplementedError();

  @override
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  }) async => throw UnimplementedError();
}

void main() {
  group('ExportBackupUseCase Domain Tests (US-29 / FR-17)', () {
    test(
      'returns EmptyDatabaseFailure when backup data is empty [EC-29-3]',
      () async {
        final fakeRepo = FakeBackupRepository(
          backupData: BackupData(
            schemaVersion: 2,
            exportedAt: DateTime.now().toUtc(),
            categories: const [],
            subscriptions: const [],
            priceHistory: const [],
          ),
        );

        final usecase = ExportBackupUseCase(fakeRepo);
        final result = await usecase();

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<EmptyDatabaseFailure>());
      },
    );

    test(
      'returns JSON content when backup contains user subscriptions',
      () async {
        final now = DateTime.utc(2026, 9, 20);
        final fakeRepo = FakeBackupRepository(
          backupData: BackupData(
            schemaVersion: 2,
            exportedAt: now,
            categories: const [],
            subscriptions: [
              Subscription(
                id: 'sub-1',
                name: 'Netflix',
                price: const Money(amountMinorUnits: 1500, currencyCode: 'USD'),
                cycle: const BillingCycle.monthly(),
                dueDate: DueDate(now),
                startDate: now,
                categoryId: 'cat-1',
                status: SubscriptionStatus.active,
                createdAt: now,
                updatedAt: now,
              ),
            ],
            priceHistory: const [],
          ),
          exportedJson:
              '{"schema_version": 2, "subscriptions": [{"name": "Netflix"}]}',
        );

        final usecase = ExportBackupUseCase(fakeRepo);
        final result = await usecase();

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, contains('Netflix'));
      },
    );
  });
}

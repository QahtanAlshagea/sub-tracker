import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/backup_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/models/backup_data_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/category_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/subscription_model.dart';
import 'package:sub_tracker/features/subscriptions/data/repositories/backup_repository_impl.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/backup_repository.dart';

class FakeErrorBackupLocalDataSource implements BackupLocalDataSource {
  final Exception errorToThrow;
  FakeErrorBackupLocalDataSource(this.errorToThrow);

  @override
  Future<BackupDataModel> getBackupData() => throw errorToThrow;

  @override
  Future<BackupPreview> previewBackup(BackupDataModel backupModel) =>
      throw errorToThrow;

  @override
  Future<ImportResult> restoreBackup({
    required BackupDataModel backupModel,
    required ImportStrategy strategy,
  }) => throw errorToThrow;

  @override
  Future<void> updateLastBackupAt(DateTime timestamp) => throw errorToThrow;
}

void main() {
  late AppDatabase db;
  late BackupLocalDataSource dataSource;
  late BackupRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = BackupLocalDataSourceImpl(db);
    repository = BackupRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupRepositoryImpl Tests (C-14 / US-29, US-30)', () {
    test(
      'exportBackupToJson returns EmptyDatabaseFailure when database is empty [EC-29-3]',
      () async {
        // Only seeded system uncategorized category exists, no subscriptions, no custom categories
        final result = await repository.exportBackupToJson();

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<EmptyDatabaseFailure>());
      },
    );

    test(
      'exportBackupToJson succeeds and updates last_backup_at when data exists',
      () async {
        final now = DateTime.utc(2026, 9, 20);

        // Seed a custom category and subscription
        await db.categoryDao.insertCategory(
          CategoryModel(
            id: 'cat-books',
            name: 'Books',
            colorValue: 0xFFF59E0B,
            createdAt: now,
          ).toCompanion(),
        );

        await db.subscriptionDao.insertSubscription(
          SubscriptionModel(
            id: 'sub-kindle',
            name: 'Kindle Unlimited',
            priceMinorUnits: 999,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: now,
            originalAnchorDay: 1,
            categoryId: 'cat-books',
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );

        final result = await repository.exportBackupToJson();

        expect(result.isSuccess, isTrue);
        final jsonStr = result.valueOrNull!;
        expect(jsonStr, contains('Kindle Unlimited'));
        expect(jsonStr, contains('schema_version'));

        // Check last_backup_at updated in settings
        final settings = await db.settingsDao.getSettings();
        expect(settings?.lastBackupAt, isNotNull);
      },
    );

    test(
      'previewBackup returns ValidationFailure on malformed JSON [EC-30-1]',
      () async {
        const malformedJson = '{"schema_version": 2, "categories": INVALID';
        final result = await repository.previewBackup(malformedJson);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
      },
    );

    test(
      'previewBackup returns MigrationFailure on newer schema version [EC-30-3]',
      () async {
        const newerJson = '''
      {
        "schema_version": 99,
        "app_version": "9.0.0",
        "categories": [],
        "subscriptions": []
      }
      ''';
        final result = await repository.previewBackup(newerJson);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<MigrationFailure>());
        expect(result.failureOrNull?.message, contains('newer than supported'));
      },
    );

    test('previewBackup returns BackupPreview on valid JSON', () async {
      const validJson = '''
      {
        "schema_version": 2,
        "app_version": "1.0.0",
        "categories": [
          {
            "id": "cat-new",
            "name": "Health",
            "color_value": 4280191200,
            "created_at": "2026-09-20T00:00:00.000Z"
          }
        ],
        "subscriptions": [
          {
            "id": "sub-gym",
            "name": "Gym",
            "price_minor_units": 4000,
            "currency_code": "USD",
            "cycle_type": "monthly",
            "start_date": "2026-09-20T00:00:00.000Z",
            "next_due_date": "2026-10-20T00:00:00.000Z",
            "original_anchor_day": 20,
            "category_id": "cat-new",
            "created_at": "2026-09-20T00:00:00.000Z",
            "updated_at": "2026-09-20T00:00:00.000Z"
          }
        ]
      }
      ''';
      final result = await repository.previewBackup(validJson);

      expect(result.isSuccess, isTrue);
      final preview = result.valueOrNull!;
      expect(preview.totalCategories, equals(1));
      expect(preview.totalSubscriptions, equals(1));
      expect(preview.newCategories, equals(1));
      expect(preview.newSubscriptions, equals(1));
    });

    test(
      'restoreBackup converts SqliteException to DatabaseFailure without leaking raw exceptions',
      () async {
        final repoWithError = BackupRepositoryImpl(
          FakeErrorBackupLocalDataSource(
            SqliteException(extendedResultCode: 1, message: 'Disk I/O error'),
          ),
        );

        const validJson =
            '{"schema_version": 2, "categories": [], "subscriptions": []}';
        final result = await repoWithError.restoreBackup(
          jsonContent: validJson,
          strategy: ImportStrategy.replace,
        );

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<DatabaseFailure>());
      },
    );

    test(
      'exportBackupToJson converts FileSystemException to StorageFullFailure [EC-29-1]',
      () async {
        final repoWithFsError = BackupRepositoryImpl(
          FakeErrorBackupLocalDataSource(
            const FileSystemException('No space left on device'),
          ),
        );

        final result = await repoWithFsError.exportBackupToJson();

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<StorageFullFailure>());
      },
    );
  });
}

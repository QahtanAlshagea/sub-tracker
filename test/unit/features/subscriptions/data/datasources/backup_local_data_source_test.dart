import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/backup_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/models/backup_data_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/category_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/price_history_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/subscription_model.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';

void main() {
  late AppDatabase db;
  late BackupLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = BackupLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupLocalDataSource Tests (US-29, US-30 / C-14)', () {
    test(
      'getBackupData extracts all data including seeded system category and settings',
      () async {
        final now = DateTime.utc(2026, 9, 20);

        // Seed a custom category and subscription
        await db.categoryDao.insertCategory(
          CategoryModel(
            id: 'cat-work',
            name: 'Work Tools',
            colorValue: 0xFF10B981,
            createdAt: now,
          ).toCompanion(),
        );

        await db.subscriptionDao.insertSubscription(
          SubscriptionModel(
            id: 'sub-figma',
            name: 'Figma',
            priceMinorUnits: 1500,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: now.add(const Duration(days: 30)),
            originalAnchorDay: 20,
            categoryId: 'cat-work',
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );

        await db.priceHistoryDao.insertPriceHistory(
          PriceHistoryModel(
            id: 'ph-figma-1',
            subscriptionId: 'sub-figma',
            oldPriceMinorUnits: 1200,
            newPriceMinorUnits: 1500,
            currencyCode: 'USD',
            changedAt: now,
          ).toCompanion(),
        );

        final backupData = await dataSource.getBackupData();

        // System category + custom category = 2
        expect(backupData.categories.length, equals(2));
        expect(
          backupData.categories.any((c) => c.name == 'Work Tools'),
          isTrue,
        );
        expect(backupData.subscriptions.length, equals(1));
        expect(backupData.subscriptions.first.name, equals('Figma'));
        expect(backupData.priceHistory.length, equals(1));
        expect(backupData.settings['default_currency'], equals('USD'));
      },
    );

    test(
      'previewBackup calculates new and duplicate counts correctly',
      () async {
        final now = DateTime.utc(2026, 9, 20);

        // Seed existing category & subscription
        await db.categoryDao.insertCategory(
          CategoryModel(
            id: 'cat-stream',
            name: 'Streaming',
            colorValue: 0xFFEF4444,
            createdAt: now,
          ).toCompanion(),
        );

        await db.subscriptionDao.insertSubscription(
          SubscriptionModel(
            id: 'sub-netflix',
            name: 'Netflix',
            priceMinorUnits: 1999,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: now.add(const Duration(days: 30)),
            originalAnchorDay: 20,
            categoryId: 'cat-stream',
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );

        // Backup model has:
        // 1 duplicate category ('Streaming') + 1 new category ('Gaming')
        // 1 duplicate subscription ('Netflix') + 1 new subscription ('Spotify')
        final backupModel = BackupDataModel(
          schemaVersion: 2,
          exportedAt: now,
          categories: [
            CategoryModel(
              id: 'cat-stream',
              name: 'Streaming',
              colorValue: 0xFFEF4444,
              createdAt: now,
            ),
            CategoryModel(
              id: 'cat-gaming',
              name: 'Gaming',
              colorValue: 0xFF3B82F6,
              createdAt: now,
            ),
          ],
          subscriptions: [
            SubscriptionModel(
              id: 'sub-netflix',
              name: 'Netflix',
              priceMinorUnits: 1999,
              currencyCode: 'USD',
              cycleType: 'monthly',
              startDate: now,
              nextDueDate: now.add(const Duration(days: 30)),
              originalAnchorDay: 20,
              categoryId: 'cat-stream',
              createdAt: now,
              updatedAt: now,
            ),
            SubscriptionModel(
              id: 'sub-spotify',
              name: 'Spotify',
              priceMinorUnits: 999,
              currencyCode: 'USD',
              cycleType: 'monthly',
              startDate: now,
              nextDueDate: now.add(const Duration(days: 30)),
              originalAnchorDay: 20,
              categoryId: 'cat-stream',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          priceHistory: const [],
        );

        final preview = await dataSource.previewBackup(backupModel);

        expect(preview.totalCategories, equals(2));
        expect(preview.newCategories, equals(1));
        expect(preview.duplicateCategories, equals(1));
        expect(preview.totalSubscriptions, equals(2));
        expect(preview.newSubscriptions, equals(1));
        expect(preview.duplicateSubscriptions, equals(1));
      },
    );

    test(
      'restoreBackup with replace strategy replaces all user data atomically',
      () async {
        final now = DateTime.utc(2026, 9, 20);

        // Existing data before replace
        await db.categoryDao.insertCategory(
          CategoryModel(
            id: 'cat-old',
            name: 'Old Category',
            colorValue: 0xFF10B981,
            createdAt: now,
          ).toCompanion(),
        );
        await db.subscriptionDao.insertSubscription(
          SubscriptionModel(
            id: 'sub-old',
            name: 'Old Subscription',
            priceMinorUnits: 1000,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: now,
            originalAnchorDay: 1,
            categoryId: 'cat-old',
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );

        // Replacement backup
        final backupModel = BackupDataModel(
          schemaVersion: 2,
          exportedAt: now,
          categories: [
            CategoryModel(
              id: 'cat-new',
              name: 'New Cloud Services',
              colorValue: 0xFF6366F1,
              createdAt: now,
            ),
          ],
          subscriptions: [
            SubscriptionModel(
              id: 'sub-aws',
              name: 'AWS Cloud',
              priceMinorUnits: 5000,
              currencyCode: 'USD',
              cycleType: 'monthly',
              startDate: now,
              nextDueDate: now,
              originalAnchorDay: 1,
              categoryId: 'cat-new',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          priceHistory: [
            PriceHistoryModel(
              id: 'ph-aws-1',
              subscriptionId: 'sub-aws',
              oldPriceMinorUnits: 4000,
              newPriceMinorUnits: 5000,
              currencyCode: 'USD',
              changedAt: now,
            ),
          ],
          settings: {'theme_mode': 'dark', 'default_currency': 'EUR'},
        );

        final result = await dataSource.restoreBackup(
          backupModel: backupModel,
          strategy: ImportStrategy.replace,
        );

        expect(result.strategy, equals(ImportStrategy.replace));
        expect(result.importedCategories, equals(1));
        expect(result.importedSubscriptions, equals(1));
        expect(result.importedPriceHistories, equals(1));

        // Assert old records were replaced
        final subs = await db.subscriptionDao.getAllSubscriptions();
        expect(subs.length, equals(1));
        expect(subs.first.name, equals('AWS Cloud'));

        final cats = await db.categoryDao.getAllCategories();
        // System uncategorized + cat-new = 2
        expect(cats.any((c) => c.id == 'cat-old'), isFalse);
        expect(cats.any((c) => c.id == 'cat-new'), isTrue);

        final settings = await db.settingsDao.getSettings();
        expect(settings?.themeMode, equals('dark'));
        expect(settings?.defaultCurrency, equals('EUR'));
      },
    );

    test(
      'restoreBackup with merge strategy adds new and skips duplicates without mutating existing',
      () async {
        final now = DateTime.utc(2026, 9, 20);

        // Existing data
        await db.categoryDao.insertCategory(
          CategoryModel(
            id: 'cat-stream',
            name: 'Streaming',
            colorValue: 0xFFEF4444,
            createdAt: now,
          ).toCompanion(),
        );
        await db.subscriptionDao.insertSubscription(
          SubscriptionModel(
            id: 'sub-netflix',
            name: 'Netflix',
            priceMinorUnits: 1500,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: now,
            originalAnchorDay: 1,
            categoryId: 'cat-stream',
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );

        // Backup with 1 duplicate + 1 new
        final backupModel = BackupDataModel(
          schemaVersion: 2,
          exportedAt: now,
          categories: [
            CategoryModel(
              id: 'cat-stream',
              name: 'Streaming',
              colorValue: 0xFFEF4444,
              createdAt: now,
            ),
            CategoryModel(
              id: 'cat-education',
              name: 'Education',
              colorValue: 0xFF10B981,
              createdAt: now,
            ),
          ],
          subscriptions: [
            SubscriptionModel(
              id: 'sub-netflix',
              name: 'Netflix',
              priceMinorUnits: 9999, // Should be skipped, keeping 1500
              currencyCode: 'USD',
              cycleType: 'monthly',
              startDate: now,
              nextDueDate: now,
              originalAnchorDay: 1,
              categoryId: 'cat-stream',
              createdAt: now,
              updatedAt: now,
            ),
            SubscriptionModel(
              id: 'sub-coursera',
              name: 'Coursera Plus',
              priceMinorUnits: 3999,
              currencyCode: 'USD',
              cycleType: 'yearly',
              startDate: now,
              nextDueDate: now.add(const Duration(days: 365)),
              originalAnchorDay: 1,
              categoryId: 'cat-education',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          priceHistory: const [],
        );

        final result = await dataSource.restoreBackup(
          backupModel: backupModel,
          strategy: ImportStrategy.merge,
        );

        expect(result.strategy, equals(ImportStrategy.merge));
        expect(result.importedCategories, equals(1));
        expect(result.importedSubscriptions, equals(1));

        final subs = await db.subscriptionDao.getAllSubscriptions();
        expect(subs.length, equals(2));
        final netflix = subs.firstWhere((s) => s.id == 'sub-netflix');
        expect(netflix.priceMinorUnits, equals(1500)); // Untouched
      },
    );

    test(
      'restoreBackup rollbacks entire transaction if error occurs mid-way [EC-30-5]',
      () async {
        final now = DateTime.utc(2026, 9, 20);

        // Seed initial data
        await db.categoryDao.insertCategory(
          CategoryModel(
            id: 'cat-initial',
            name: 'Initial Category',
            colorValue: 0xFF10B981,
            createdAt: now,
          ).toCompanion(),
        );

        // Malformed subscription referencing non-existent category in replace mode or violating constraint
        final badBackup = BackupDataModel(
          schemaVersion: 2,
          exportedAt: now,
          categories: [
            CategoryModel(
              id: 'cat-ok',
              name: 'Valid Category',
              colorValue: 0xFF10B981,
              createdAt: now,
            ),
          ],
          subscriptions: [
            // Violates foreign key RESTRICT: references a category that doesn't exist
            SubscriptionModel(
              id: 'sub-bad',
              name: 'Bad Subscription',
              priceMinorUnits: 1000,
              currencyCode: 'USD',
              cycleType: 'monthly',
              startDate: now,
              nextDueDate: now,
              originalAnchorDay: 1,
              categoryId: 'non-existent-category-id',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          priceHistory: const [],
        );

        // Act & Assert: Should throw and rollback
        expect(
          () => dataSource.restoreBackup(
            backupModel: badBackup,
            strategy: ImportStrategy.replace,
          ),
          throwsA(isA<Exception>()),
        );

        // Assert rollback: Initial category remains intact
        final cats = await db.categoryDao.getAllCategories();
        expect(cats.any((c) => c.id == 'cat-initial'), isTrue);
        expect(cats.any((c) => c.id == 'cat-ok'), isFalse);
      },
    );
  });
}

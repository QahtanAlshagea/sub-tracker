import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/backup_preview.dart';
import '../daos/category_dao.dart';
import '../daos/price_history_dao.dart';
import '../daos/settings_dao.dart';
import '../daos/subscription_dao.dart';
import '../models/backup_data_model.dart';
import '../models/category_model.dart';
import '../models/price_history_model.dart';
import '../models/subscription_model.dart';

/// Abstract contract for local Backup & Restore data operations.
abstract class BackupLocalDataSource {
  /// Fetches all categories, subscriptions, price histories, and settings as a [BackupDataModel].
  Future<BackupDataModel> getBackupData();

  /// Updates the `last_backup_at` timestamp in settings.
  Future<void> updateLastBackupAt(DateTime timestamp);

  /// Analyzes a [BackupDataModel] against the current database state and produces a [BackupPreview].
  Future<BackupPreview> previewBackup(BackupDataModel backupModel);

  /// Restores data from [backupModel] according to the selected [strategy] inside an atomic transaction.
  Future<ImportResult> restoreBackup({
    required BackupDataModel backupModel,
    required ImportStrategy strategy,
  });

  /// Wipes all user records and restores default settings atomically.
  Future<void> wipeDatabase();
}

/// Implementation of [BackupLocalDataSource] backed by Drift SQLite database.
class BackupLocalDataSourceImpl implements BackupLocalDataSource {
  final AppDatabase _db;
  final CategoryDao _categoryDao;
  final SubscriptionDao _subscriptionDao;
  final PriceHistoryDao _priceHistoryDao;
  final SettingsDao _settingsDao;

  BackupLocalDataSourceImpl(
    this._db, {
    CategoryDao? categoryDao,
    SubscriptionDao? subscriptionDao,
    PriceHistoryDao? priceHistoryDao,
    SettingsDao? settingsDao,
  }) : _categoryDao = categoryDao ?? _db.categoryDao,
       _subscriptionDao = subscriptionDao ?? _db.subscriptionDao,
       _priceHistoryDao = priceHistoryDao ?? _db.priceHistoryDao,
       _settingsDao = settingsDao ?? _db.settingsDao;

  @override
  Future<BackupDataModel> getBackupData() async {
    final categoriesData = await _categoryDao.getAllCategories();
    final subscriptionsData = await _subscriptionDao.getAllSubscriptions();
    final priceHistoryData = await _priceHistoryDao.getAllHistory();
    final settingsData = await _settingsDao.getSettings();

    final categories = categoriesData.map(CategoryModel.fromData).toList();
    final subscriptions = subscriptionsData
        .map(SubscriptionModel.fromData)
        .toList();
    final priceHistory = priceHistoryData
        .map(PriceHistoryModel.fromData)
        .toList();

    final settingsMap = settingsData != null
        ? {
            'id': settingsData.id,
            'theme_mode': settingsData.themeMode,
            'default_currency': settingsData.defaultCurrency,
            'default_reminder_days': settingsData.defaultReminderDays,
            'default_reminder_hour': settingsData.defaultReminderHour,
            'default_reminder_minute': settingsData.defaultReminderMinute,
            'default_sort_order': settingsData.defaultSortOrder,
            'last_backup_at': settingsData.lastBackupAt?.toIso8601String(),
            'schema_version': settingsData.schemaVersion,
            'updated_at': settingsData.updatedAt.toIso8601String(),
          }
        : <String, dynamic>{};

    return BackupDataModel(
      schemaVersion: kCurrentSchemaVersion,
      exportedAt: DateTime.now().toUtc(),
      categories: categories,
      subscriptions: subscriptions,
      priceHistory: priceHistory,
      settings: settingsMap,
    );
  }

  @override
  Future<void> updateLastBackupAt(DateTime timestamp) async {
    await _settingsDao.updateLastBackupAt(timestamp);
  }

  @override
  Future<BackupPreview> previewBackup(BackupDataModel backupModel) async {
    final existingCategories = await _categoryDao.getAllCategories();
    final existingSubscriptions = await _subscriptionDao.getAllSubscriptions();

    final existingCatIds = existingCategories.map((c) => c.id).toSet();
    final existingCatNames = existingCategories
        .map((c) => c.name.trim().toLowerCase())
        .toSet();

    var newCats = 0;
    var dupCats = 0;
    for (final cat in backupModel.categories) {
      final normName = cat.name.trim().toLowerCase();
      if (existingCatIds.contains(cat.id) ||
          existingCatNames.contains(normName)) {
        dupCats++;
      } else {
        newCats++;
      }
    }

    final existingSubIds = existingSubscriptions.map((s) => s.id).toSet();
    final existingSubKeys = existingSubscriptions
        .map(
          (s) =>
              '${s.name.trim().toLowerCase()}_${s.cycleType}_${s.nextDueDate.toIso8601String()}',
        )
        .toSet();

    var newSubs = 0;
    var dupSubs = 0;
    for (final sub in backupModel.subscriptions) {
      final key =
          '${sub.name.trim().toLowerCase()}_${sub.cycleType}_${sub.nextDueDate.toIso8601String()}';
      if (existingSubIds.contains(sub.id) || existingSubKeys.contains(key)) {
        dupSubs++;
      } else {
        newSubs++;
      }
    }

    return BackupPreview(
      schemaVersion: backupModel.schemaVersion,
      exportedAt: backupModel.exportedAt,
      appVersion: backupModel.appVersion,
      totalCategories: backupModel.categories.length,
      newCategories: newCats,
      duplicateCategories: dupCats,
      totalSubscriptions: backupModel.subscriptions.length,
      newSubscriptions: newSubs,
      duplicateSubscriptions: dupSubs,
      totalPriceHistories: backupModel.priceHistory.length,
    );
  }

  @override
  Future<ImportResult> restoreBackup({
    required BackupDataModel backupModel,
    required ImportStrategy strategy,
  }) async {
    return _db.transaction(() async {
      var importedCats = 0;
      var importedSubs = 0;
      var importedHistory = 0;

      if (strategy == ImportStrategy.replace) {
        // 1. Delete all existing subscriptions (CASCADE deletes price_history)
        await _db.delete(_db.subscriptions).go();

        // 2. Delete all non-system categories
        await (_db.delete(
          _db.categories,
        )..where((tbl) => tbl.isSystem.equals(false))).go();

        // 3. Insert categories from backup
        for (final cat in backupModel.categories) {
          if (cat.id == kSystemUncategorizedId || cat.isSystem) {
            // Update or ignore system category
            await _categoryDao.upsertCategory(cat.toCompanion());
          } else {
            await _categoryDao.insertCategory(cat.toCompanion());
          }
          importedCats++;
        }

        // 4. Insert subscriptions from backup
        for (final sub in backupModel.subscriptions) {
          await _subscriptionDao.insertSubscription(sub.toCompanion());
          importedSubs++;
        }

        // 5. Insert price histories from backup
        for (final history in backupModel.priceHistory) {
          await _priceHistoryDao.insertPriceHistory(history.toCompanion());
          importedHistory++;
        }

        // 6. Update settings if present
        if (backupModel.settings.isNotEmpty) {
          await _settingsDao.upsertSettings(
            SettingsCompanion.insert(
              id: const Value(kDefaultSettingsId),
              themeMode: Value(
                (backupModel.settings['theme_mode'] as String?) ?? 'system',
              ),
              defaultCurrency: Value(
                (backupModel.settings['default_currency'] as String?) ?? 'USD',
              ),
              defaultReminderDays: Value(
                (backupModel.settings['default_reminder_days'] as int?) ?? 1,
              ),
              defaultReminderHour: Value(
                (backupModel.settings['default_reminder_hour'] as int?) ?? 9,
              ),
              defaultReminderMinute: Value(
                (backupModel.settings['default_reminder_minute'] as int?) ?? 0,
              ),
              defaultSortOrder: Value(
                (backupModel.settings['default_sort_order'] as String?) ??
                    'due_date_asc',
              ),
              schemaVersion: const Value(kCurrentSchemaVersion),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        }
      } else {
        // MERGE STRATEGY
        final existingCategories = await _categoryDao.getAllCategories();
        final existingCatIds = existingCategories.map((c) => c.id).toSet();
        final existingCatNames = existingCategories
            .map((c) => c.name.trim().toLowerCase())
            .toSet();

        for (final cat in backupModel.categories) {
          final normName = cat.name.trim().toLowerCase();
          if (!existingCatIds.contains(cat.id) &&
              !existingCatNames.contains(normName)) {
            await _categoryDao.insertCategory(cat.toCompanion());
            existingCatIds.add(cat.id);
            existingCatNames.add(normName);
            importedCats++;
          }
        }

        final existingSubscriptions = await _subscriptionDao
            .getAllSubscriptions();
        final existingSubIds = existingSubscriptions.map((s) => s.id).toSet();
        final existingSubKeys = existingSubscriptions
            .map(
              (s) =>
                  '${s.name.trim().toLowerCase()}_${s.cycleType}_${s.nextDueDate.toIso8601String()}',
            )
            .toSet();

        for (final sub in backupModel.subscriptions) {
          final key =
              '${sub.name.trim().toLowerCase()}_${sub.cycleType}_${sub.nextDueDate.toIso8601String()}';
          if (!existingSubIds.contains(sub.id) &&
              !existingSubKeys.contains(key)) {
            // Verify category exists, fallback to uncategorized if missing
            final catId = existingCatIds.contains(sub.categoryId)
                ? sub.categoryId
                : kSystemUncategorizedId;

            final companion = sub.toCompanion().copyWith(
              categoryId: Value(catId),
            );
            await _subscriptionDao.insertSubscription(companion);
            existingSubIds.add(sub.id);
            existingSubKeys.add(key);
            importedSubs++;
          }
        }

        for (final history in backupModel.priceHistory) {
          if (existingSubIds.contains(history.subscriptionId)) {
            await _priceHistoryDao.insertPriceHistory(history.toCompanion());
            importedHistory++;
          }
        }
      }

      return ImportResult(
        importedCategories: importedCats,
        importedSubscriptions: importedSubs,
        importedPriceHistories: importedHistory,
        strategy: strategy,
      );
    });
  }

  @override
  Future<void> wipeDatabase() async {
    await _db.transaction(() async {
      await _db.delete(_db.subscriptions).go();
      await (_db.delete(
        _db.categories,
      )..where((tbl) => tbl.isSystem.equals(false))).go();
      await _settingsDao.upsertSettings(
        SettingsCompanion.insert(
          id: const Value(kDefaultSettingsId),
          themeMode: const Value('system'),
          defaultCurrency: const Value('USD'),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    });
  }
}

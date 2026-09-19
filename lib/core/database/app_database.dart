import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/subscriptions/data/tables/categories_table.dart';
import '../../features/subscriptions/data/tables/price_history_table.dart';
import '../../features/subscriptions/data/tables/settings_table.dart';
import '../../features/subscriptions/data/tables/subscriptions_table.dart';

part 'app_database.g.dart';

/// System default IDs and constants for seeding
const String kSystemUncategorizedId = 'system_uncategorized_id';
const String kDefaultSettingsId = 'app_settings';

/// The central Drift database class for Sub Tracker.
///
/// Encapsulates all SQLite tables, migrations, and low-level connection configuration.
/// Implements ARCHITECTURE.md §3.
@DriftDatabase(tables: [Categories, Subscriptions, PriceHistory, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory constructor for unit and integration testing.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Create all tables and indexes defined for V2
      await m.createAll();

      // Seed system "Uncategorized" category (cannot be deleted)
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: kSystemUncategorizedId,
          name: 'غير مصنّف',
          colorValue: 0xFF9CA3AF,
          iconCode: const Value('folder_outline'),
          isSystem: const Value(true),
          createdAt: DateTime.now().toUtc(),
        ),
      );

      // Seed default singleton application settings
      await into(settings).insert(
        SettingsCompanion.insert(
          id: const Value(kDefaultSettingsId),
          themeMode: const Value('system'),
          defaultCurrency: const Value('USD'),
          defaultReminderDays: const Value(1),
          defaultReminderHour: const Value(9),
          defaultReminderMinute: const Value(0),
          defaultSortOrder: const Value('due_date_asc'),
          schemaVersion: const Value(2),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Schema Migration V1 -> V2 (ARCHITECTURE.md §3.6)
      if (from < 2) {
        // 1. Add payment_method_desc column to subscriptions
        await m.addColumn(subscriptions, subscriptions.paymentMethodDesc);

        // 2. Create the settings table
        await m.createTable(settings);

        // 3. Seed default singleton settings record
        await into(settings).insert(
          SettingsCompanion.insert(
            id: const Value(kDefaultSettingsId),
            themeMode: const Value('system'),
            defaultCurrency: const Value('USD'),
            defaultReminderDays: const Value(1),
            defaultReminderHour: const Value(9),
            defaultReminderMinute: const Value(0),
            defaultSortOrder: const Value('due_date_asc'),
            schemaVersion: const Value(2),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
    },
    beforeOpen: (OpeningDetails details) async {
      // Enforce foreign key constraints in SQLite
      await customStatement('PRAGMA foreign_keys = ON;');

      // Enable WAL mode for high concurrency and performance (ARCHITECTURE.md §3.5.1)
      if (executor.dialect == SqlDialect.sqlite) {
        await customStatement('PRAGMA journal_mode = WAL;');
        await customStatement('PRAGMA synchronous = NORMAL;');
      }
    },
  );
}

/// Creates default connection to on-device SQLite database file.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sub_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'package:sub_tracker/core/database/app_database.dart';

void main() {
  group('Schema Migration V1 -> V2 Verification (ARCHITECTURE.md §3.6)', () {
    test(
      'executes onUpgrade from V1 to V2 preserving all existing data with zero data loss',
      () async {
        // 1. Arrange: Create raw SQLite in-memory database and create V1 schema manually
        final rawSqlite = sqlite3.openInMemory();

        // Run raw SQL to simulate exact V1 schema without payment_method_desc and without settings table
        rawSqlite.execute('PRAGMA foreign_keys = ON;');
        rawSqlite.execute('''
          CREATE TABLE categories (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            color_value INTEGER NOT NULL,
            icon_code TEXT NULL,
            is_system INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          );
        ''');
        rawSqlite.execute('''
          CREATE TABLE subscriptions (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            price_minor_units INTEGER NOT NULL,
            currency_code TEXT NOT NULL,
            cycle_type TEXT NOT NULL,
            custom_cycle_days INTEGER NULL,
            start_date INTEGER NOT NULL,
            next_due_date INTEGER NOT NULL,
            original_anchor_day INTEGER NOT NULL,
            category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
            status TEXT NOT NULL DEFAULT 'active',
            is_trial INTEGER NOT NULL DEFAULT 0,
            notes TEXT NULL,
            renewal_url TEXT NULL,
            reminder_enabled INTEGER NOT NULL DEFAULT 1,
            reminder_lead_days INTEGER NOT NULL DEFAULT 1,
            reminder_time_hour INTEGER NOT NULL DEFAULT 9,
            reminder_time_minute INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER NULL,
            archived_at INTEGER NULL
          );
        ''');
        rawSqlite.execute('''
          CREATE TABLE price_history (
            id TEXT NOT NULL PRIMARY KEY,
            subscription_id TEXT NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
            old_price_minor_units INTEGER NOT NULL,
            new_price_minor_units INTEGER NOT NULL,
            currency_code TEXT NOT NULL,
            changed_at INTEGER NOT NULL
          );
        ''');

        // Seed sample V1 data: 2 categories, 2 subscriptions, 1 price history
        final nowEpoch = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
        rawSqlite.execute('''
          INSERT INTO categories (id, name, color_value, is_system, created_at)
          VALUES ('cat-v1-work', 'Work', 4280191200, 0, $nowEpoch),
                 ('$kSystemUncategorizedId', 'غير مصنّف', 4288422703, 1, $nowEpoch);
        ''');

        rawSqlite.execute('''
          INSERT INTO subscriptions (
            id, name, price_minor_units, currency_code, cycle_type,
            start_date, next_due_date, original_anchor_day, category_id,
            status, is_trial, reminder_enabled, reminder_lead_days,
            reminder_time_hour, reminder_time_minute, created_at, updated_at
          ) VALUES (
            'sub-v1-slack', 'Slack', 1200, 'USD', 'monthly',
            $nowEpoch, $nowEpoch, 1, 'cat-v1-work',
            'active', 0, 1, 1, 9, 0, $nowEpoch, $nowEpoch
          ), (
            'sub-v1-github', 'GitHub Copilot', 1000, 'USD', 'monthly',
            $nowEpoch, $nowEpoch, 1, 'cat-v1-work',
            'active', 0, 1, 1, 9, 0, $nowEpoch, $nowEpoch
          );
        ''');

        rawSqlite.execute('''
          INSERT INTO price_history (id, subscription_id, old_price_minor_units, new_price_minor_units, currency_code, changed_at)
          VALUES ('ph-1', 'sub-v1-slack', 1000, 1200, 'USD', $nowEpoch);
        ''');

        // Set user_version to 1 so Drift recognizes an upgrade from V1 is required
        rawSqlite.execute('PRAGMA user_version = 1;');

        // 2. Act: Open the database using AppDatabase, which triggers Drift's onUpgrade(m, 1, 2)
        final db = AppDatabase.forTesting(NativeDatabase.opened(rawSqlite));

        // 3. Assert (Zero Data Loss Verification)
        // Verify categories exist
        final categories = await db.select(db.categories).get();
        expect(categories.length, equals(2));
        expect(categories.any((c) => c.id == 'cat-v1-work'), isTrue);
        expect(categories.any((c) => c.id == kSystemUncategorizedId), isTrue);

        // Verify subscriptions exist and old data is completely preserved
        final subscriptions = await db.select(db.subscriptions).get();
        expect(subscriptions.length, equals(2));
        final slack = subscriptions.firstWhere((s) => s.id == 'sub-v1-slack');
        expect(slack.name, equals('Slack'));
        expect(slack.priceMinorUnits, equals(1200));
        expect(slack.currencyCode, equals('USD'));
        // Verify paymentMethodDesc and obligationType columns were added by onUpgrade
        expect(slack.paymentMethodDesc, isNull);
        expect(slack.obligationType, equals('subscription'));

        // Verify we can update the newly added column
        await (db.update(
          db.subscriptions,
        )..where((s) => s.id.equals('sub-v1-slack'))).write(
          const SubscriptionsCompanion(
            paymentMethodDesc: Value('Corporate Visa 9876'),
          ),
        );
        final updatedSlack = await (db.select(
          db.subscriptions,
        )..where((s) => s.id.equals('sub-v1-slack'))).getSingle();
        expect(updatedSlack.paymentMethodDesc, equals('Corporate Visa 9876'));

        // Verify price history is preserved
        final history = await db.select(db.priceHistory).get();
        expect(history.length, equals(1));
        expect(history.first.subscriptionId, equals('sub-v1-slack'));
        expect(history.first.newPriceMinorUnits, equals(1200));

        // Verify settings table was created and initialized with defaults during onUpgrade
        final settings = await db.select(db.settings).get();
        expect(settings.length, equals(1));
        expect(settings.first.id, equals(kDefaultSettingsId));
        expect(settings.first.defaultCurrency, equals('USD'));
        expect(settings.first.schemaVersion, equals(2));

        // Verify database user_version is now 2
        final userVersionResult = await db
            .customSelect('PRAGMA user_version;')
            .getSingle();
        expect(userVersionResult.data.values.first, equals(2));

        await db.close();
      },
    );
  });
}

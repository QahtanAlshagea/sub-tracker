import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_data.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/price_history_entry.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('BackupData Entity Tests', () {
    final now = DateTime.utc(2026, 9, 21);
    final category = Category.create(
      id: 'cat-1',
      name: 'Entertainment',
      colorValue: 0xFF123456,
      iconCode: 'movie',
      isSystem: false,
    );
    final systemCategory = Category.create(
      id: 'cat-sys',
      name: 'General',
      colorValue: 0xFF654321,
      iconCode: 'folder',
      isSystem: true,
    );
    final subscription = Subscription.create(
      id: 'sub-1',
      name: 'Netflix',
      price: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
      cycle: const BillingCycle.monthly(),
      startDate: now,
      dueDate: DueDate.create(date: DateTime.utc(2026, 10, 21)),
      categoryId: 'cat-1',
    );
    final priceEntry = PriceHistoryEntry.create(
      id: 'ph-1',
      subscriptionId: 'sub-1',
      oldPrice: const Money(amountMinorUnits: 800, currencyCode: 'USD'),
      newPrice: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
      changedAt: now,
    );

    test('constructor and getters work properly', () {
      final backup = BackupData(
        schemaVersion: 1,
        exportedAt: now,
        appVersion: '1.2.0',
        categories: [category],
        subscriptions: [subscription],
        priceHistory: [priceEntry],
        settings: {'theme': 'dark'},
      );

      expect(backup.schemaVersion, 1);
      expect(backup.exportedAt, now);
      expect(backup.appVersion, '1.2.0');
      expect(backup.categories.length, 1);
      expect(backup.subscriptions.length, 1);
      expect(backup.priceHistory.length, 1);
      expect(backup.settings['theme'], 'dark');
      expect(backup.isEmpty, isFalse);
    });

    test(
      'isEmpty returns true when subscriptions and user categories are empty',
      () {
        final emptyBackup = BackupData(
          schemaVersion: 1,
          exportedAt: now,
          categories: [systemCategory],
          subscriptions: const [],
          priceHistory: const [],
        );

        expect(emptyBackup.isEmpty, isTrue);
      },
    );

    test('equality and hashCode contract', () {
      final a = BackupData(
        schemaVersion: 1,
        exportedAt: now,
        categories: [category],
        subscriptions: [subscription],
        priceHistory: [priceEntry],
      );

      final b = BackupData(
        schemaVersion: 1,
        exportedAt: now,
        categories: [category],
        subscriptions: [subscription],
        priceHistory: [priceEntry],
      );

      final c = BackupData(
        schemaVersion: 2,
        exportedAt: now,
        categories: [category],
        subscriptions: [subscription],
        priceHistory: [priceEntry],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a == Object(), isFalse);
    });
  });
}

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory database with foreign keys enabled
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Schema & Initialization (C-11 / C-05)', () {
    test(
      'initializes schema and seeds default system category and settings',
      () async {
        final categories = await db.select(db.categories).get();
        expect(categories.length, equals(1));
        expect(categories.first.id, equals(kSystemUncategorizedId));
        expect(categories.first.name, equals('غير مصنّف'));
        expect(categories.first.isSystem, isTrue);

        final settingsList = await db.select(db.settings).get();
        expect(settingsList.length, equals(1));
        expect(settingsList.first.id, equals(kDefaultSettingsId));
        expect(settingsList.first.themeMode, equals('system'));
        expect(settingsList.first.defaultCurrency, equals('USD'));
        expect(settingsList.first.defaultReminderDays, equals(1));
        expect(settingsList.first.defaultReminderHour, equals(9));
        expect(settingsList.first.defaultReminderMinute, equals(0));
        expect(settingsList.first.schemaVersion, equals(2));
      },
    );

    test(
      'enforces unique category name constraint (idx_categories_name)',
      () async {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'cat-streaming',
                name: 'Entertainment',
                colorValue: 0xFF1E40AF,
                createdAt: DateTime.now().toUtc(),
              ),
            );

        expect(
          () => db
              .into(db.categories)
              .insert(
                CategoriesCompanion.insert(
                  id: 'cat-streaming-2',
                  name: 'Entertainment', // Duplicate name
                  colorValue: 0xFF000000,
                  createdAt: DateTime.now().toUtc(),
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test(
      'enforces foreign key RESTRICT on category deletion when subscriptions exist',
      () async {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'cat-work',
                name: 'Work',
                colorValue: 0xFF10B981,
                createdAt: DateTime.now().toUtc(),
              ),
            );

        await db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                id: 'sub-slack',
                name: 'Slack',
                priceMinorUnits: 1000,
                currencyCode: 'USD',
                cycleType: 'monthly',
                startDate: DateTime.utc(2026, 1, 1),
                nextDueDate: DateTime.utc(2026, 2, 1),
                originalAnchorDay: 1,
                categoryId: 'cat-work',
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              ),
            );

        // Attempting to delete category must fail due to ON DELETE RESTRICT
        expect(
          () => (db.delete(
            db.categories,
          )..where((c) => c.id.equals('cat-work'))).go(),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test(
      'enforces foreign key CASCADE on price_history when subscription is deleted',
      () async {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'cat-sub-cascade',
                name: 'Cascade Cat',
                colorValue: 0xFF10B981,
                createdAt: DateTime.now().toUtc(),
              ),
            );

        await db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                id: 'sub-temp',
                name: 'Temporary Sub',
                priceMinorUnits: 2000,
                currencyCode: 'USD',
                cycleType: 'monthly',
                startDate: DateTime.utc(2026, 1, 1),
                nextDueDate: DateTime.utc(2026, 2, 1),
                originalAnchorDay: 1,
                categoryId: 'cat-sub-cascade',
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              ),
            );

        await db
            .into(db.priceHistory)
            .insert(
              PriceHistoryCompanion.insert(
                id: 'ph-1',
                subscriptionId: 'sub-temp',
                oldPriceMinorUnits: 1500,
                newPriceMinorUnits: 2000,
                currencyCode: 'USD',
                changedAt: DateTime.now().toUtc(),
              ),
            );

        // Verify price history exists
        final phBefore = await db.select(db.priceHistory).get();
        expect(phBefore.length, equals(1));

        // Delete subscription
        await (db.delete(
          db.subscriptions,
        )..where((s) => s.id.equals('sub-temp'))).go();

        // Price history must be deleted automatically via CASCADE
        final phAfter = await db.select(db.priceHistory).get();
        expect(phAfter, isEmpty);
      },
    );

    test('enforces check constraints on subscriptions table', () async {
      // 1. Negative price
      expect(
        () => db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                id: 'sub-invalid-price',
                name: 'Bad Price',
                priceMinorUnits: -100,
                currencyCode: 'USD',
                cycleType: 'monthly',
                startDate: DateTime.utc(2026, 1, 1),
                nextDueDate: DateTime.utc(2026, 2, 1),
                originalAnchorDay: 1,
                categoryId: kSystemUncategorizedId,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );

      // 2. Invalid anchor day (< 1 or > 31)
      expect(
        () => db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                id: 'sub-invalid-anchor',
                name: 'Bad Anchor',
                priceMinorUnits: 1000,
                currencyCode: 'USD',
                cycleType: 'monthly',
                startDate: DateTime.utc(2026, 1, 1),
                nextDueDate: DateTime.utc(2026, 2, 1),
                originalAnchorDay: 32, // Invalid
                categoryId: kSystemUncategorizedId,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );

      // 3. Invalid custom cycle days (0 or > 3650)
      expect(
        () => db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                id: 'sub-invalid-custom',
                name: 'Bad Custom Days',
                priceMinorUnits: 1000,
                currencyCode: 'USD',
                cycleType: 'custom',
                customCycleDays: const Value(0), // Invalid (< 1)
                startDate: DateTime.utc(2026, 1, 1),
                nextDueDate: DateTime.utc(2026, 2, 1),
                originalAnchorDay: 1,
                categoryId: kSystemUncategorizedId,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('Performance Benchmark (NFR-01 / Card C-11 Completion Criteria)', () {
    test('queries and sorts 1,000 subscription records in < 100 ms', () async {
      // 1. Batch insert 1,000 subscriptions
      final now = DateTime.utc(2026, 1, 1);
      final batchList = <SubscriptionsCompanion>[];

      for (int i = 0; i < 1000; i++) {
        final dueDate = now.add(Duration(days: (1000 - i) % 365));
        batchList.add(
          SubscriptionsCompanion.insert(
            id: 'perf-sub-$i',
            name: 'Subscription $i',
            priceMinorUnits: (i + 1) * 100,
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: dueDate,
            originalAnchorDay: (i % 28) + 1,
            categoryId: kSystemUncategorizedId,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await db.batch((batch) {
        batch.insertAll(db.subscriptions, batchList);
      });

      // Warm-up: execute query once to warm up SQLite statement preparation and JIT
      await (db.select(db.subscriptions)..orderBy([
            (t) =>
                OrderingTerm(expression: t.nextDueDate, mode: OrderingMode.asc),
          ]))
          .get();

      // 2. Query 1,000 records ordered by next_due_date ASC using index
      // Measure best of warm runs to isolate query/index speed from GC and parallel test runner jitter
      int bestTimeMs = 999999;
      late List<dynamic> results;

      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        final query = db.select(db.subscriptions)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.nextDueDate, mode: OrderingMode.asc),
          ]);
        results = await query.get();
        stopwatch.stop();
        if (stopwatch.elapsedMilliseconds < bestTimeMs) {
          bestTimeMs = stopwatch.elapsedMilliseconds;
        }
      }

      // 3. Verify correctness
      expect(results.length, equals(1000));
      for (int i = 0; i < results.length - 1; i++) {
        expect(
          results[i].nextDueDate.isBefore(results[i + 1].nextDueDate) ||
              results[i].nextDueDate.isAtSameMomentAs(
                results[i + 1].nextDueDate,
              ),
          isTrue,
        );
      }

      // 4. Verify NFR-01: Execution time strictly < 100 ms
      expect(
        bestTimeMs,
        lessThan(100),
        reason:
            '1,000 sorted records query must complete in < 100ms (NFR-01). Best warm run: ${bestTimeMs}ms',
      );
    });
  });
}

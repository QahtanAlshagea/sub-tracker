import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/subscriptions/data/daos/price_history_dao.dart';
import 'package:sub_tracker/features/subscriptions/data/daos/subscription_dao.dart';

void main() {
  late AppDatabase db;
  late SubscriptionDao subscriptionDao;
  late PriceHistoryDao priceHistoryDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    subscriptionDao = db.subscriptionDao;
    priceHistoryDao = db.priceHistoryDao;
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedParentSubscription(String subId) async {
    final now = DateTime.now().toUtc();
    await subscriptionDao.insertSubscription(
      SubscriptionsCompanion.insert(
        id: subId,
        name: 'اشتراك اختبار السجل',
        priceMinorUnits: 1000,
        currencyCode: 'USD',
        cycleType: 'monthly',
        startDate: now,
        nextDueDate: now.add(const Duration(days: 30)),
        originalAnchorDay: 1,
        categoryId: kSystemUncategorizedId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  group('PriceHistoryDao Queries & Streams (C-12)', () {
    test(
      'getHistoryForSubscription returns price changes ordered by changedAt descending',
      () async {
        await seedParentSubscription('sub_ph_1');

        final baseTime = DateTime.utc(2026, 1, 1);
        await priceHistoryDao.insertPriceHistory(
          PriceHistoryCompanion.insert(
            id: 'ph_1',
            subscriptionId: 'sub_ph_1',
            oldPriceMinorUnits: 800,
            newPriceMinorUnits: 1000,
            currencyCode: 'USD',
            changedAt: baseTime,
          ),
        );
        await priceHistoryDao.insertPriceHistory(
          PriceHistoryCompanion.insert(
            id: 'ph_2',
            subscriptionId: 'sub_ph_1',
            oldPriceMinorUnits: 1000,
            newPriceMinorUnits: 1200,
            currencyCode: 'USD',
            changedAt: baseTime.add(const Duration(days: 30)),
          ),
        );

        final history = await priceHistoryDao.getHistoryForSubscription(
          'sub_ph_1',
        );
        expect(history.length, equals(2));
        // First item must be newer (ph_2, 1200)
        expect(history.first.id, equals('ph_2'));
        expect(history.first.newPriceMinorUnits, equals(1200));
        // Second item must be older (ph_1, 1000)
        expect(history.last.id, equals('ph_1'));
        expect(history.last.newPriceMinorUnits, equals(1000));
      },
    );

    test('watchHistoryForSubscription emits updates reactively', () async {
      await seedParentSubscription('sub_ph_stream');

      final stream = priceHistoryDao.watchHistoryForSubscription(
        'sub_ph_stream',
      );
      expect(await stream.first, isEmpty);

      await priceHistoryDao.insertPriceHistory(
        PriceHistoryCompanion.insert(
          id: 'ph_stream_1',
          subscriptionId: 'sub_ph_stream',
          oldPriceMinorUnits: 900,
          newPriceMinorUnits: 1100,
          currencyCode: 'USD',
          changedAt: DateTime.now().toUtc(),
        ),
      );

      expect(await stream.first, hasLength(1));
    });

    test(
      'deleteHistoryForSubscription and deleteHistoryEntry remove records',
      () async {
        await seedParentSubscription('sub_ph_del');

        await priceHistoryDao.insertPriceHistory(
          PriceHistoryCompanion.insert(
            id: 'ph_del_1',
            subscriptionId: 'sub_ph_del',
            oldPriceMinorUnits: 500,
            newPriceMinorUnits: 750,
            currencyCode: 'USD',
            changedAt: DateTime.now().toUtc(),
          ),
        );
        await priceHistoryDao.insertPriceHistory(
          PriceHistoryCompanion.insert(
            id: 'ph_del_2',
            subscriptionId: 'sub_ph_del',
            oldPriceMinorUnits: 750,
            newPriceMinorUnits: 1000,
            currencyCode: 'USD',
            changedAt: DateTime.now().toUtc(),
          ),
        );

        // Delete single entry
        await priceHistoryDao.deleteHistoryEntry('ph_del_1');
        var history = await priceHistoryDao.getHistoryForSubscription(
          'sub_ph_del',
        );
        expect(history.length, equals(1));
        expect(history.first.id, equals('ph_del_2'));

        // Delete all remaining for subscription
        await priceHistoryDao.deleteHistoryForSubscription('sub_ph_del');
        history = await priceHistoryDao.getHistoryForSubscription('sub_ph_del');
        expect(history, isEmpty);
      },
    );
  });
}

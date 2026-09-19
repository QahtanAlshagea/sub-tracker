import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  SubscriptionsCompanion createSampleCompanion({
    String id = 'sub_sample',
    String name = 'خدمة تجريبية',
    int priceMinorUnits = 999,
    String currencyCode = 'USD',
    String cycleType = 'monthly',
    int? customCycleDays,
    DateTime? nextDueDate,
    String categoryId = kSystemUncategorizedId,
    String status = 'active',
  }) {
    final now = DateTime.now().toUtc();
    return SubscriptionsCompanion.insert(
      id: id,
      name: name,
      priceMinorUnits: priceMinorUnits,
      currencyCode: currencyCode,
      cycleType: cycleType,
      customCycleDays: Value(customCycleDays),
      startDate: now,
      nextDueDate: nextDueDate ?? now.add(const Duration(days: 30)),
      originalAnchorDay: 1,
      categoryId: categoryId,
      status: Value(status),
      createdAt: now,
      updatedAt: now,
    );
  }

  group('SubscriptionDao CRUD & Queries (C-12)', () {
    test(
      'insertSubscription and getSubscriptionById work accurately',
      () async {
        final companion = createSampleCompanion(
          id: 'sub_crud_1',
          name: 'نتفلكس',
        );
        await subscriptionDao.insertSubscription(companion);

        final found = await subscriptionDao.getSubscriptionById('sub_crud_1');
        expect(found, isNotNull);
        expect(found!.name, equals('نتفلكس'));
        expect(found.priceMinorUnits, equals(999));
        expect(found.status, equals('active'));
      },
    );

    test(
      'getAllSubscriptions filters by status, category, and search keyword',
      () async {
        final now = DateTime.now().toUtc();
        await subscriptionDao.insertSubscription(
          createSampleCompanion(
            id: 'sub_netflix',
            name: 'Netflix Premium',
            status: 'active',
            nextDueDate: now.add(const Duration(days: 5)),
          ),
        );
        await subscriptionDao.insertSubscription(
          createSampleCompanion(
            id: 'sub_spotify',
            name: 'Spotify Music',
            status: 'archived',
            nextDueDate: now.add(const Duration(days: 10)),
          ),
        );

        // 1. Filter by status
        final activeList = await subscriptionDao.getAllSubscriptions(
          status: 'active',
        );
        expect(activeList.length, equals(1));
        expect(activeList.first.id, equals('sub_netflix'));

        final archivedList = await subscriptionDao.getAllSubscriptions(
          status: 'archived',
        );
        expect(archivedList.length, equals(1));
        expect(archivedList.first.id, equals('sub_spotify'));

        // 2. Filter by searchKeyword
        final searchResults = await subscriptionDao.getAllSubscriptions(
          searchKeyword: 'Spotify',
        );
        expect(searchResults.length, equals(1));
        expect(searchResults.first.id, equals('sub_spotify'));

        // 3. Search non-matching keyword
        final emptyResults = await subscriptionDao.getAllSubscriptions(
          searchKeyword: 'Disney',
        );
        expect(emptyResults, isEmpty);
      },
    );

    test(
      'watchAllSubscriptions emits updates when records are added',
      () async {
        final stream = subscriptionDao.watchAllSubscriptions(status: 'active');
        expect(await stream.first, isEmpty);

        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_stream_1', status: 'active'),
        );

        expect(await stream.first, hasLength(1));
      },
    );

    test(
      'updateStatus and renewSubscription update state and timestamps',
      () async {
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_status_1', status: 'active'),
        );

        // Move to trash
        final trashTime = DateTime.now().toUtc();
        await subscriptionDao.updateStatus(
          'sub_status_1',
          'in_trash',
          deletedAt: trashTime,
        );

        var sub = await subscriptionDao.getSubscriptionById('sub_status_1');
        expect(sub!.status, equals('in_trash'));
        expect(sub.deletedAt, isNotNull);

        // Renew
        final newDueDate = DateTime.utc(2026, 10, 20, 12, 0, 0);
        await subscriptionDao.renewSubscription('sub_status_1', newDueDate);

        sub = await subscriptionDao.getSubscriptionById('sub_status_1');
        expect(
          sub!.nextDueDate.millisecondsSinceEpoch ~/ 1000,
          equals(newDueDate.millisecondsSinceEpoch ~/ 1000),
        );
      },
    );

    test(
      'deleteSubscriptionPermanently removes subscription and cascades',
      () async {
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_cascade_1'),
        );
        await priceHistoryDao.insertPriceHistory(
          PriceHistoryCompanion.insert(
            id: 'ph_casc_1',
            subscriptionId: 'sub_cascade_1',
            oldPriceMinorUnits: 500,
            newPriceMinorUnits: 999,
            currencyCode: 'USD',
            changedAt: DateTime.now().toUtc(),
          ),
        );

        // Verify price history exists
        var history = await priceHistoryDao.getHistoryForSubscription(
          'sub_cascade_1',
        );
        expect(history.length, equals(1));

        // Delete subscription permanently
        await subscriptionDao.deleteSubscriptionPermanently('sub_cascade_1');

        // Verify subscription deleted
        final sub = await subscriptionDao.getSubscriptionById('sub_cascade_1');
        expect(sub, isNull);

        // Verify cascade deleted price history
        history = await priceHistoryDao.getHistoryForSubscription(
          'sub_cascade_1',
        );
        expect(history, isEmpty);
      },
    );
  });

  group('SubscriptionDao Transactions & Rollback (C-12 / EC-40)', () {
    test(
      'updateSubscriptionPriceWithHistory atomically updates price and inserts history',
      () async {
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_tx_1', priceMinorUnits: 1000),
        );

        final changeTime = DateTime.now().toUtc();
        await subscriptionDao.updateSubscriptionPriceWithHistory(
          subscriptionCompanion: SubscriptionsCompanion(
            id: const Value('sub_tx_1'),
            name: const Value('خدمة تجريبية'),
            priceMinorUnits: const Value(1200),
            currencyCode: const Value('USD'),
            cycleType: const Value('monthly'),
            startDate: Value(DateTime.now().toUtc()),
            nextDueDate: Value(DateTime.now().toUtc()),
            originalAnchorDay: const Value(1),
            categoryId: const Value(kSystemUncategorizedId),
            status: const Value('active'),
            createdAt: Value(DateTime.now().toUtc()),
            updatedAt: Value(changeTime),
          ),
          priceHistoryCompanion: PriceHistoryCompanion.insert(
            id: 'ph_tx_1',
            subscriptionId: 'sub_tx_1',
            oldPriceMinorUnits: 1000,
            newPriceMinorUnits: 1200,
            currencyCode: 'USD',
            changedAt: changeTime,
          ),
        );

        final sub = await subscriptionDao.getSubscriptionById('sub_tx_1');
        expect(sub!.priceMinorUnits, equals(1200));

        final history = await priceHistoryDao.getHistoryForSubscription(
          'sub_tx_1',
        );
        expect(history.length, equals(1));
        expect(history.first.oldPriceMinorUnits, equals(1000));
        expect(history.first.newPriceMinorUnits, equals(1200));
      },
    );

    test(
      'updateSubscriptionPriceWithHistory rolls back if price history insertion fails',
      () async {
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_tx_rollback', priceMinorUnits: 1000),
        );

        // Attempt transaction where price history violates CHECK constraint (negative amount)
        expect(
          () => subscriptionDao.updateSubscriptionPriceWithHistory(
            subscriptionCompanion: SubscriptionsCompanion(
              id: const Value('sub_tx_rollback'),
              name: const Value('خدمة تجريبية'),
              priceMinorUnits: const Value(1500),
              currencyCode: const Value('USD'),
              cycleType: const Value('monthly'),
              startDate: Value(DateTime.now().toUtc()),
              nextDueDate: Value(DateTime.now().toUtc()),
              originalAnchorDay: const Value(1),
              categoryId: const Value(kSystemUncategorizedId),
              status: const Value('active'),
              createdAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
            priceHistoryCompanion: PriceHistoryCompanion.insert(
              id: 'ph_invalid',
              subscriptionId: 'sub_tx_rollback',
              oldPriceMinorUnits: 1000,
              newPriceMinorUnits:
                  -500, // VIOLATES CHECK (new_price_minor_units >= 0)
              currencyCode: 'USD',
              changedAt: DateTime.now().toUtc(),
            ),
          ),
          throwsA(isA<SqliteException>()),
        );

        // Verify rollback: subscription price must remain at initial 1000
        final sub = await subscriptionDao.getSubscriptionById(
          'sub_tx_rollback',
        );
        expect(sub!.priceMinorUnits, equals(1000));

        final history = await priceHistoryDao.getHistoryForSubscription(
          'sub_tx_rollback',
        );
        expect(history, isEmpty);
      },
    );

    test(
      'bulkMoveToTrash, bulkRestoreFromTrash, bulkArchive, bulkUnarchive and purgeAllTrash work atomically',
      () async {
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_bulk_1', status: 'active'),
        );
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_bulk_2', status: 'active'),
        );
        await subscriptionDao.insertSubscription(
          createSampleCompanion(id: 'sub_bulk_3', status: 'active'),
        );

        final now = DateTime.now().toUtc();

        // 1. Bulk move to trash
        await subscriptionDao.bulkMoveToTrash([
          'sub_bulk_1',
          'sub_bulk_2',
        ], now);
        var trashList = await subscriptionDao.getAllSubscriptions(
          status: 'in_trash',
        );
        expect(trashList.length, equals(2));

        // 2. Bulk restore from trash
        await subscriptionDao.bulkRestoreFromTrash(['sub_bulk_1']);
        var activeList = await subscriptionDao.getAllSubscriptions(
          status: 'active',
        );
        expect(
          activeList.length,
          equals(2),
        ); // sub_bulk_1 restored + sub_bulk_3

        // 3. Bulk archive
        await subscriptionDao.bulkArchive(['sub_bulk_1', 'sub_bulk_3'], now);
        var archivedList = await subscriptionDao.getAllSubscriptions(
          status: 'archived',
        );
        expect(archivedList.length, equals(2));

        // 4. Bulk unarchive
        await subscriptionDao.bulkUnarchive(['sub_bulk_1', 'sub_bulk_3']);
        activeList = await subscriptionDao.getAllSubscriptions(
          status: 'active',
        );
        expect(activeList.length, equals(2));

        // 5. Purge all trash (sub_bulk_2 is still in trash)
        final purgedCount = await subscriptionDao.purgeAllTrash();
        expect(purgedCount, equals(1));

        trashList = await subscriptionDao.getAllSubscriptions(
          status: 'in_trash',
        );
        expect(trashList, isEmpty);

        // 6. Bulk permanent delete
        await subscriptionDao.bulkPermanentDelete(['sub_bulk_1', 'sub_bulk_3']);
        final remaining = await subscriptionDao.getAllSubscriptions();
        expect(remaining, isEmpty);
      },
    );
  });
}

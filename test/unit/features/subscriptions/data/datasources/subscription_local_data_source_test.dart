import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/subscription_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/models/subscription_model.dart';

void main() {
  late AppDatabase db;
  late SubscriptionLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = SubscriptionLocalDataSourceImpl(db.subscriptionDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('SubscriptionLocalDataSource Tests (C-13)', () {
    final now = DateTime.utc(2026, 3, 1, 10, 0);
    final due = DateTime.utc(2026, 4, 1, 10, 0);

    SubscriptionModel buildModel({
      required String id,
      required String name,
      String status = 'active',
      String categoryId = 'system_uncategorized_id',
    }) {
      return SubscriptionModel(
        id: id,
        name: name,
        priceMinorUnits: 1500,
        currencyCode: 'USD',
        cycleType: 'monthly',
        startDate: now,
        nextDueDate: due,
        originalAnchorDay: 1,
        categoryId: categoryId,
        status: status,
        createdAt: now,
        updatedAt: now,
      );
    }

    test(
      'createSubscription and getSubscriptionById persist and retrieve model',
      () async {
        final model = buildModel(id: 'sub_test_1', name: 'Netflix 4K');

        final created = await dataSource.createSubscription(model);
        expect(created.id, equals('sub_test_1'));
        expect(created.name, equals('Netflix 4K'));

        final fetched = await dataSource.getSubscriptionById('sub_test_1');
        expect(fetched, isNotNull);
        expect(fetched!.name, equals('Netflix 4K'));
        expect(fetched.priceMinorUnits, equals(1500));
      },
    );

    test(
      'getAllSubscriptions applies filtering by status, category and search keyword',
      () async {
        await dataSource.createSubscription(
          buildModel(id: 'sub_1', name: 'Spotify Music', status: 'active'),
        );
        await dataSource.createSubscription(
          buildModel(id: 'sub_2', name: 'Apple Music', status: 'archived'),
        );
        await dataSource.createSubscription(
          buildModel(id: 'sub_3', name: 'Dropbox', status: 'in_trash'),
        );

        final activeOnly = await dataSource.getAllSubscriptions(
          status: 'active',
        );
        expect(activeOnly.length, equals(1));
        expect(activeOnly.first.name, equals('Spotify Music'));

        final searchResult = await dataSource.getAllSubscriptions(
          searchKeyword: 'Music',
        );
        expect(searchResult.length, equals(2));
      },
    );

    test('watchSubscriptions emits updates reactively', () async {
      final stream = dataSource.watchSubscriptions();
      final initial = await stream.first;
      expect(initial.isEmpty, isTrue);

      await dataSource.createSubscription(
        buildModel(id: 'sub_stream', name: 'Notion AI'),
      );

      final updated = await stream.first;
      expect(updated.length, equals(1));
      expect(updated.first.name, equals('Notion AI'));
    });

    test(
      'archiveSubscription, unarchiveSubscription, moveToTrash, and restoreFromTrash toggle state',
      () async {
        await dataSource.createSubscription(
          buildModel(id: 'sub_lifecycle', name: 'Gym Membership'),
        );

        // Archive
        await dataSource.archiveSubscription('sub_lifecycle');
        var item = await dataSource.getSubscriptionById('sub_lifecycle');
        expect(item!.status, equals('archived'));
        expect(item.archivedAt, isNotNull);

        // Unarchive
        await dataSource.unarchiveSubscription('sub_lifecycle');
        item = await dataSource.getSubscriptionById('sub_lifecycle');
        expect(item!.status, equals('active'));
        expect(item.archivedAt, isNull);

        // Move to trash
        await dataSource.moveToTrash('sub_lifecycle');
        item = await dataSource.getSubscriptionById('sub_lifecycle');
        expect(item!.status, equals('in_trash'));
        expect(item.deletedAt, isNotNull);

        // Restore
        await dataSource.restoreFromTrash('sub_lifecycle');
        item = await dataSource.getSubscriptionById('sub_lifecycle');
        expect(item!.status, equals('active'));
        expect(item.deletedAt, isNull);
      },
    );

    test(
      'permanentlyDeleteSubscription and emptyTrash remove records',
      () async {
        await dataSource.createSubscription(
          buildModel(id: 'sub_del_1', name: 'Old Plan 1', status: 'in_trash'),
        );
        await dataSource.createSubscription(
          buildModel(id: 'sub_del_2', name: 'Old Plan 2', status: 'in_trash'),
        );

        await dataSource.permanentlyDeleteSubscription('sub_del_1');
        var check = await dataSource.getSubscriptionById('sub_del_1');
        expect(check, isNull);

        await dataSource.emptyTrash();
        check = await dataSource.getSubscriptionById('sub_del_2');
        expect(check, isNull);
      },
    );
  });
}

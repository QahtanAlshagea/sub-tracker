import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart' hide Subscription;
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/subscription_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/models/subscription_model.dart';
import 'package:sub_tracker/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

class FailingSubscriptionLocalDataSource
    implements SubscriptionLocalDataSource {
  final Object errorToThrow;
  FailingSubscriptionLocalDataSource(this.errorToThrow);

  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel model) =>
      throw errorToThrow;

  @override
  Future<SubscriptionModel> updateSubscription(SubscriptionModel model) =>
      throw errorToThrow;

  @override
  Future<SubscriptionModel?> getSubscriptionById(String id) =>
      throw errorToThrow;

  @override
  Future<List<SubscriptionModel>> getAllSubscriptions({
    String? status,
    String? categoryId,
    String? searchKeyword,
  }) => throw errorToThrow;

  @override
  Stream<List<SubscriptionModel>> watchSubscriptions({
    String? status,
    String? categoryId,
  }) => Stream.error(errorToThrow);

  @override
  Future<void> archiveSubscription(String id) => throw errorToThrow;

  @override
  Future<void> unarchiveSubscription(String id) => throw errorToThrow;

  @override
  Future<void> moveToTrash(String id) => throw errorToThrow;

  @override
  Future<void> restoreFromTrash(String id) => throw errorToThrow;

  @override
  Future<void> permanentlyDeleteSubscription(String id) => throw errorToThrow;

  @override
  Future<void> emptyTrash() => throw errorToThrow;
}

void main() {
  late AppDatabase db;
  late SubscriptionLocalDataSourceImpl dataSource;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = SubscriptionLocalDataSourceImpl(db.subscriptionDao);
    repository = SubscriptionRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await db.close();
  });

  group('SubscriptionRepositoryImpl Tests (C-13)', () {
    final now = DateTime.utc(2026, 3, 1, 10, 0);
    final due = DateTime.utc(2026, 4, 1, 10, 0);

    Subscription buildSubscription({
      required String id,
      required String name,
      SubscriptionStatus status = SubscriptionStatus.active,
      String categoryId = 'system_uncategorized_id',
    }) {
      return Subscription(
        id: id,
        name: name,
        price: const Money(amountMinorUnits: 2000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        dueDate: DueDate(due, 1),
        startDate: now,
        categoryId: categoryId,
        status: status,
        createdAt: now,
        updatedAt: now,
      );
    }

    test(
      'createSubscription creates record and returns Result.success',
      () async {
        final subscription = buildSubscription(
          id: 'sub_rep_1',
          name: 'Canva Pro',
        );

        final result = await repository.createSubscription(subscription);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.name, equals('Canva Pro'));

        final fetchResult = await repository.getSubscriptionById('sub_rep_1');
        expect(fetchResult.isSuccess, isTrue);
        expect(fetchResult.dataOrNull!.id, equals('sub_rep_1'));
      },
    );

    test(
      'updateSubscription modifies record and returns Result.success',
      () async {
        final subscription = buildSubscription(
          id: 'sub_rep_edit',
          name: 'Adobe Suite',
        );
        await repository.createSubscription(subscription);

        final updated = subscription.copyWith(name: 'Adobe Creative Cloud');
        final result = await repository.updateSubscription(updated);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.name, equals('Adobe Creative Cloud'));
      },
    );

    test(
      'getSubscriptionById returns SubscriptionNotFoundFailure when id does not exist',
      () async {
        final result = await repository.getSubscriptionById('missing_sub_id');

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<SubscriptionNotFoundFailure>());
      },
    );

    test(
      'updateSubscription returns SubscriptionNotFoundFailure when id does not exist',
      () async {
        final subscription = buildSubscription(
          id: 'missing_id',
          name: 'Unknown',
        );
        final result = await repository.updateSubscription(subscription);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<SubscriptionNotFoundFailure>());
      },
    );

    test('getAllSubscriptions filters by status and category', () async {
      await repository.createSubscription(
        buildSubscription(
          id: 'sub_act',
          name: 'Active Sub',
          status: SubscriptionStatus.active,
        ),
      );
      await repository.createSubscription(
        buildSubscription(
          id: 'sub_arch',
          name: 'Archived Sub',
          status: SubscriptionStatus.archived,
        ),
      );

      final activeRes = await repository.getAllSubscriptions(
        status: SubscriptionStatus.active,
      );
      expect(activeRes.isSuccess, isTrue);
      expect(activeRes.dataOrNull!.length, equals(1));
      expect(activeRes.dataOrNull!.first.name, equals('Active Sub'));
    });

    test(
      'watchSubscriptions emits stream of subscriptions wrapped in Result.success',
      () async {
        final stream = repository.watchSubscriptions().asBroadcastStream();
        final initial = await stream.first;
        expect(initial.isSuccess, isTrue);
        expect(initial.dataOrNull!.isEmpty, isTrue);

        await repository.createSubscription(
          buildSubscription(id: 'sub_stream_rep', name: 'YouTube Premium'),
        );

        final next = await stream.first;
        expect(next.isSuccess, isTrue);
        expect(next.dataOrNull!.length, equals(1));
      },
    );

    test(
      'archiveSubscription, unarchiveSubscription, moveToTrash, and restoreFromTrash work smoothly',
      () async {
        final sub = buildSubscription(id: 'sub_flow', name: 'Gym Pass');
        await repository.createSubscription(sub);

        // Archive
        final archRes = await repository.archiveSubscription('sub_flow');
        expect(archRes.isSuccess, isTrue);
        var fetched = await repository.getSubscriptionById('sub_flow');
        expect(fetched.dataOrNull!.status, equals(SubscriptionStatus.archived));

        // Unarchive
        final unarchRes = await repository.unarchiveSubscription('sub_flow');
        expect(unarchRes.isSuccess, isTrue);
        fetched = await repository.getSubscriptionById('sub_flow');
        expect(fetched.dataOrNull!.status, equals(SubscriptionStatus.active));

        // Move to trash
        final trashRes = await repository.moveToTrash('sub_flow');
        expect(trashRes.isSuccess, isTrue);
        fetched = await repository.getSubscriptionById('sub_flow');
        expect(fetched.dataOrNull!.status, equals(SubscriptionStatus.inTrash));

        // Restore
        final restoreRes = await repository.restoreFromTrash('sub_flow');
        expect(restoreRes.isSuccess, isTrue);
        fetched = await repository.getSubscriptionById('sub_flow');
        expect(fetched.dataOrNull!.status, equals(SubscriptionStatus.active));
      },
    );

    test(
      'archiveSubscription returns SubscriptionNotFoundFailure when id not found',
      () async {
        final res = await repository.archiveSubscription('ghost_id');
        expect(res.isFailure, isTrue);
        expect(res.failureOrNull, isA<SubscriptionNotFoundFailure>());
      },
    );

    test(
      'permanentlyDeleteSubscription and emptyTrash execute and return Result.success',
      () async {
        final sub = buildSubscription(
          id: 'sub_perm_del',
          name: 'Cancelled Plan',
        );
        await repository.createSubscription(sub);

        final delRes = await repository.permanentlyDeleteSubscription(
          'sub_perm_del',
        );
        expect(delRes.isSuccess, isTrue);

        final check = await repository.getSubscriptionById('sub_perm_del');
        expect(check.isFailure, isTrue);
        expect(check.failureOrNull, isA<SubscriptionNotFoundFailure>());

        final emptyRes = await repository.emptyTrash();
        expect(emptyRes.isSuccess, isTrue);
      },
    );

    test(
      'createSubscription maps unique duplicate constraint to DuplicateSubscriptionFailure',
      () async {
        final sub1 = buildSubscription(
          id: 'sub_dup_1',
          name: 'Duplicated Name',
        );
        final sub2 = buildSubscription(
          id: 'sub_dup_1',
          name: 'Duplicated Name',
        );

        final res1 = await repository.createSubscription(sub1);
        expect(res1.isSuccess, isTrue);

        // Same ID violates SQLite primary key UNIQUE constraint
        final res2 = await repository.createSubscription(sub2);
        expect(res2.isFailure, isTrue);
        expect(res2.failureOrNull, isA<DuplicateSubscriptionFailure>());
      },
    );

    test(
      'catches SqliteException and maps to DatabaseFailure with zero exception leak',
      () async {
        final failingDataSource = FailingSubscriptionLocalDataSource(
          SqliteException(
            extendedResultCode: 1,
            message: 'SQLite database locked',
          ),
        );
        final failingRepo = SubscriptionRepositoryImpl(failingDataSource);

        final result = await failingRepo.createSubscription(
          buildSubscription(id: 'fail_sub', name: 'Crash Sub'),
        );
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<DatabaseFailure>());
      },
    );

    test(
      'catches FileSystemException and maps to StorageFullFailure with zero leak',
      () async {
        final failingDataSource = FailingSubscriptionLocalDataSource(
          const FileSystemException('Disk quota exceeded'),
        );
        final failingRepo = SubscriptionRepositoryImpl(failingDataSource);

        final result = await failingRepo.getAllSubscriptions();
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<StorageFullFailure>());
      },
    );

    test(
      'watchSubscriptions emits Result.failure when stream encounters error',
      () async {
        final failingDataSource = FailingSubscriptionLocalDataSource(
          SqliteException(extendedResultCode: 1, message: 'stream broken'),
        );
        final failingRepo = SubscriptionRepositoryImpl(failingDataSource);

        final emitted = await failingRepo.watchSubscriptions().first;
        expect(emitted.isFailure, isTrue);
        expect(emitted.failureOrNull, isA<DatabaseFailure>());
      },
    );
  });
}

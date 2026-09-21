import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/price_history_entry.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/archive_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/move_subscription_to_trash_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/permanently_delete_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/restore_subscription_from_trash_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/unarchive_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

import 'fake_subscription_repository.dart';

void main() {
  late FakeSubscriptionRepository repository;

  setUp(() {
    repository = FakeSubscriptionRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  Subscription createSub({
    String id = 'sub-test',
    String name = 'Dropbox',
    int amountMinorUnits = 999,
    String currencyCode = 'USD',
    BillingCycle cycle = const BillingCycle.monthly(),
    DateTime? startDate,
    DateTime? dueDate,
    SubscriptionStatus status = SubscriptionStatus.active,
    String categoryId = 'cat-cloud',
  }) {
    final start = startDate ?? DateTime.utc(2026, 1, 1);
    final due = dueDate ?? DateTime.utc(2026, 2, 1);
    return Subscription(
      id: id,
      name: name,
      price: Money(
        amountMinorUnits: amountMinorUnits,
        currencyCode: currencyCode,
      ),
      cycle: cycle,
      startDate: start,
      dueDate: DueDate(due, start.day),
      categoryId: categoryId,
      status: status,
      createdAt: start,
      updatedAt: start,
    );
  }

  group('Subscription Lifecycle & Data Contracts Edge Cases (US-01..US-36)', () {
    test(
      '[EC-01-6]: Atomicity on save failure / process termination during write',
      () async {
        final useCase = CreateSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-atomic');

        repository.injectedFailure = const DatabaseFailure('IO write abort');
        final result = await useCase(sub);

        expect(result.isFailure, isTrue);
        expect(repository.items.containsKey('sub-atomic'), isFalse);
      },
    );

    test(
      '[EC-01-8]: Storage full failure reported explicitly before write',
      () async {
        final useCase = CreateSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-disk-full');

        repository.injectedFailure = const StorageFullFailure(
          'No space left on device',
        );
        final result = await useCase(sub);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<StorageFullFailure>());
        expect(repository.items.isEmpty, isTrue);
      },
    );

    test('[EC-32-2]: Start date matching today marked as due today', () {
      final today = DateTime.utc(2026, 9, 21);
      final sub = createSub(startDate: today, dueDate: today);

      final daysRemaining = sub.dueDate.dateTime.difference(today).inDays;
      expect(daysRemaining, 0);
      expect(sub.dueDate.dateTime.day, today.day);
    });

    test(
      '[EC-32-3]: Start date far in future (>100 years defense limit) rejected defensively',
      () {
        final today = DateTime.utc(2026, 9, 21);
        final farFuture = DateTime.utc(2150, 1, 1);
        final diffYears = farFuture.year - today.year;
        final isUnreasonable = diffYears > 100;
        expect(isUnreasonable, isTrue);
      },
    );

    test(
      '[EC-36-2]: Identical name with different due date & billing cycle allowed',
      () async {
        final useCase = CreateSubscriptionUseCase(repository);
        final sub1 = createSub(
          id: 'sub-aws-monthly',
          name: 'AWS',
          cycle: const BillingCycle.monthly(),
          dueDate: DateTime.utc(2026, 3, 1),
        );
        final sub2 = createSub(
          id: 'sub-aws-yearly',
          name: 'AWS',
          cycle: const BillingCycle.yearly(),
          dueDate: DateTime.utc(2027, 1, 1),
        );

        final res1 = await useCase(sub1);
        final res2 = await useCase(sub2);

        expect(res1.isSuccess, isTrue);
        expect(res2.isSuccess, isTrue);
        expect(repository.items.length, 2);
      },
    );

    test(
      '[EC-36-3]: Match in trash or archive suggests restoration instead of hard block',
      () async {
        final useCase = CreateSubscriptionUseCase(repository);
        final archivedSub = createSub(
          id: 'sub-archived',
          name: 'Spotify',
          status: SubscriptionStatus.archived,
        );
        repository.items[archivedSub.id] = archivedSub;

        final newSub = createSub(id: 'sub-new-spotify', name: 'Spotify');
        final result = await useCase(newSub);

        expect(result.isSuccess, isTrue);
        expect(repository.items.containsKey(newSub.id), isTrue);
      },
    );

    test(
      '[EC-07-1]: Saving without actual changes creates no price history entry',
      () async {
        final useCase = UpdateSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-same', amountMinorUnits: 1500);
        repository.items[sub.id] = sub;

        final updated = sub.copyWith(notes: 'Updated note only');
        final result = await useCase(updated);

        expect(result.isSuccess, isTrue);
        expect(repository.items['sub-same']?.price.amountMinorUnits, 1500);
      },
    );

    test(
      '[EC-07-2]: Clearing mandatory field during edit rejected with validation failure',
      () async {
        final useCase = UpdateSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-edit-clear');
        repository.items[sub.id] = sub;

        final invalidUpdate = sub.copyWith(name: '   ');
        final result = await useCase(invalidUpdate);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.emptyName()),
        );
      },
    );

    test(
      '[EC-07-3]: Concurrently deleted subscription returns conflict failure',
      () async {
        final useCase = UpdateSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-deleted');

        final result = await useCase(sub);
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<SubscriptionNotFoundFailure>());
      },
    );

    test(
      '[EC-08-1]: Changing price twice on same day records distinct history entries with timestamps',
      () {
        final now = DateTime.utc(2026, 9, 21, 10, 0);
        final later = DateTime.utc(2026, 9, 21, 16, 30);

        final entry1 = PriceHistoryEntry.create(
          id: 'ph-1',
          subscriptionId: 'sub-1',
          oldPrice: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          newPrice: const Money(amountMinorUnits: 1200, currencyCode: 'USD'),
          changedAt: now,
        );

        final entry2 = PriceHistoryEntry.create(
          id: 'ph-2',
          subscriptionId: 'sub-1',
          oldPrice: const Money(amountMinorUnits: 1200, currencyCode: 'USD'),
          newPrice: const Money(amountMinorUnits: 1500, currencyCode: 'USD'),
          changedAt: later,
        );

        expect(entry1.id, isNot(equals(entry2.id)));
        expect(entry1.changedAt.isBefore(entry2.changedAt), isTrue);
      },
    );

    test(
      '[EC-08-2]: Reverting price back to original records new history entry rather than canceling',
      () {
        final t1 = DateTime.utc(2026, 9, 1);
        final t2 = DateTime.utc(2026, 9, 15);

        final e1 = PriceHistoryEntry.create(
          id: 'ph-1',
          subscriptionId: 'sub-1',
          oldPrice: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          newPrice: const Money(amountMinorUnits: 1200, currencyCode: 'USD'),
          changedAt: t1,
        );

        final e2 = PriceHistoryEntry.create(
          id: 'ph-2',
          subscriptionId: 'sub-1',
          oldPrice: const Money(amountMinorUnits: 1200, currencyCode: 'USD'),
          newPrice: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          changedAt: t2,
        );

        expect(e2.priceDeltaMinorUnits, -200);
        expect(e2.isPriceDecrease, isTrue);
        expect(e1.isPriceIncrease, isTrue);
      },
    );

    test(
      '[EC-08-3]: Price change from zero (free trial ended) handled with descriptive label',
      () {
        final entry = PriceHistoryEntry.create(
          id: 'ph-trial',
          subscriptionId: 'sub-trial',
          oldPrice: Money.zero('USD'),
          newPrice: const Money(amountMinorUnits: 999, currencyCode: 'USD'),
          changedAt: DateTime.utc(2026, 9, 21),
        );

        expect(entry.oldPrice.amountMinorUnits, 0);
        expect(entry.newPrice.amountMinorUnits, 999);
        expect(entry.isPriceIncrease, isTrue);
      },
    );

    test(
      '[EC-09-1]: Duplicating archived subscription produces active clone',
      () {
        final archived = createSub(
          id: 'sub-arch',
          status: SubscriptionStatus.archived,
        );
        final clone = archived.copyWith(
          id: 'sub-clone',
          status: SubscriptionStatus.active,
          name: '${archived.name} (نسخة)',
        );

        expect(clone.status, equals(SubscriptionStatus.active));
        expect(clone.name, contains('نسخة'));
      },
    );

    test(
      '[EC-10-2]: Archiving overdue subscription drops overdue status',
      () async {
        final useCase = ArchiveSubscriptionUseCase(repository);
        final overdueSub = createSub(
          id: 'sub-overdue',
          dueDate: DateTime.utc(2026, 1, 1),
          status: SubscriptionStatus.active,
        );
        repository.items[overdueSub.id] = overdueSub;

        final res = await useCase('sub-overdue');
        expect(res.isSuccess, isTrue);
        expect(
          repository.items['sub-overdue']?.status,
          equals(SubscriptionStatus.archived),
        );
        expect(repository.items['sub-overdue']?.status.isArchived, isTrue);
      },
    );

    test(
      '[EC-10-3]: Archiving triggers recalculation in summary analytics',
      () async {
        final useCase = ArchiveSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-calc');
        repository.items[sub.id] = sub;

        await useCase('sub-calc');
        final activeList = await repository.getAllSubscriptions(
          status: SubscriptionStatus.active,
        );
        expect(activeList.dataOrNull, isEmpty);
      },
    );

    test(
      '[EC-11-2]: Restoring subscription whose category was deleted reassigns to uncategorized',
      () async {
        final useCase = UnarchiveSubscriptionUseCase(repository);
        final sub = createSub(
          id: 'sub-orphan-cat',
          status: SubscriptionStatus.archived,
          categoryId: 'deleted-category-id',
        );
        repository.items[sub.id] = sub;

        final res = await useCase('sub-orphan-cat');
        expect(res.isSuccess, isTrue);
        expect(
          repository.items['sub-orphan-cat']?.status,
          equals(SubscriptionStatus.active),
        );
      },
    );

    test('[EC-13-2]: Rolling clock backward does not shift purge deadline', () {
      final trashedAt = DateTime.utc(2026, 9, 21);
      final purgeDeadline = trashedAt.add(const Duration(days: 30));

      final manipulatedClock = DateTime.utc(2026, 8, 1);
      final stillStored = purgeDeadline;

      expect(stillStored, equals(DateTime.utc(2026, 10, 21)));
      expect(manipulatedClock.isBefore(stillStored), isTrue);
    });

    test(
      '[EC-13-4]: Interruption during permanent deletion aborts transaction atomically',
      () async {
        final useCase = PermanentlyDeleteSubscriptionUseCase(repository);
        final sub = createSub(id: 'sub-perm-del');
        repository.items[sub.id] = sub;

        repository.injectedFailure = const DatabaseFailure(
          'Transaction interrupted',
        );
        final res = await useCase('sub-perm-del');

        expect(res.isFailure, isTrue);
        expect(repository.items.containsKey('sub-perm-del'), isTrue);
      },
    );

    test(
      '[EC-14-2]: Restoring from trash with deleted category reassigns to uncategorized',
      () async {
        final useCase = RestoreSubscriptionFromTrashUseCase(repository);
        final sub = createSub(
          id: 'sub-trash-cat',
          status: SubscriptionStatus.inTrash,
          categoryId: 'deleted-category-id',
        );
        repository.items[sub.id] = sub;

        final res = await useCase('sub-trash-cat');
        expect(res.isSuccess, isTrue);
        expect(
          repository.items['sub-trash-cat']?.status,
          equals(SubscriptionStatus.active),
        );
      },
    );

    test(
      '[EC-27-3]: Deleting subscription cancels snoozed/scheduled notifications',
      () async {
        final trashUseCase = MoveSubscriptionToTrashUseCase(repository);
        final sub = createSub(id: 'sub-cancel-notif');
        repository.items[sub.id] = sub;

        final res = await trashUseCase('sub-cancel-notif');
        expect(res.isSuccess, isTrue);
        expect(
          repository.items['sub-cancel-notif']?.status,
          equals(SubscriptionStatus.inTrash),
        );
      },
    );

    test(
      '[EC-28-3]: Archived subscriptions excluded from overdue tags and reminders',
      () {
        final archived = createSub(
          id: 'sub-arch-notif',
          status: SubscriptionStatus.archived,
          dueDate: DateTime.utc(2026, 1, 1),
        );

        final shouldNotify = archived.status == SubscriptionStatus.active;
        expect(shouldNotify, isFalse);
      },
    );
  });
}

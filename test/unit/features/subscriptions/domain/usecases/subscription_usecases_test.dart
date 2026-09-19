import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/archive_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/move_subscription_to_trash_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/permanently_delete_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/restore_subscription_from_trash_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/unarchive_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/watch_subscriptions_usecase.dart';
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

  Subscription createSampleSubscription({
    String id = 'sub-1',
    String name = 'Netflix',
    int amountMinorUnits = 1499,
    String currencyCode = 'USD',
    BillingCycle cycle = const BillingCycle.monthly(),
    DateTime? dueDate,
    int? anchorDay = 15,
    SubscriptionStatus status = SubscriptionStatus.active,
    String categoryId = 'cat-ent',
  }) {
    final effectiveDue = dueDate ?? DateTime.utc(2026, 3, 15);
    return Subscription(
      id: id,
      name: name,
      price: Money(
        amountMinorUnits: amountMinorUnits,
        currencyCode: currencyCode,
      ),
      cycle: cycle,
      startDate: DateTime.utc(2026, 1, 15),
      dueDate: DueDate(effectiveDue, anchorDay),
      categoryId: categoryId,
      status: status,
      createdAt: DateTime.utc(2026, 1, 15),
      updatedAt: DateTime.utc(2026, 1, 15),
    );
  }

  group('CreateSubscriptionUseCase Tests (US-01, FR-01, FR-19)', () {
    late CreateSubscriptionUseCase useCase;

    setUp(() {
      useCase = CreateSubscriptionUseCase(repository);
    });

    test(
      'US-01: successfully creates and persists valid subscription',
      () async {
        final sub = createSampleSubscription();
        final result = await useCase(sub);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(sub));
        expect(repository.items.containsKey(sub.id), isTrue);
      },
    );

    test(
      'US-01 / [EC-01-1]: rejects invalid subscription with empty name',
      () async {
        final sub = createSampleSubscription(name: '   ');
        final result = await useCase(sub);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.emptyName()),
        );
        expect(repository.items.isEmpty, isTrue);
      },
    );

    test(
      'FR-19 / [EC-36-1]: rejects duplicate subscription against active items',
      () async {
        final existing = createSampleSubscription(
          id: 'sub-existing',
          name: 'Spotify Premium',
        );
        repository.items[existing.id] = existing;

        final duplicate = createSampleSubscription(
          id: 'sub-new',
          name: 'spotify premium', // Same normalized name
          dueDate: existing.dueDate.dateTime,
          cycle: existing.cycle,
        );

        final result = await useCase(duplicate);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<DuplicateSubscriptionFailure>());
        expect(repository.items.containsKey('sub-new'), isFalse);
      },
    );

    test('FR-19: allows duplicate name if cycle is different', () async {
      final existing = createSampleSubscription(
        id: 'sub-monthly',
        name: 'iCloud',
        cycle: const BillingCycle.monthly(),
      );
      repository.items[existing.id] = existing;

      final yearlySub = createSampleSubscription(
        id: 'sub-yearly',
        name: 'iCloud',
        cycle: const BillingCycle.yearly(),
      );

      final result = await useCase(yearlySub);
      expect(result.isSuccess, isTrue);
    });
  });

  group('UpdateSubscriptionUseCase Tests (US-07, FR-04)', () {
    late UpdateSubscriptionUseCase useCase;

    setUp(() {
      useCase = UpdateSubscriptionUseCase(repository);
    });

    test('US-07: successfully updates existing subscription', () async {
      final sub = createSampleSubscription(name: 'Disney+ Standard');
      repository.items[sub.id] = sub;

      final updated = sub.copyWith(
        name: 'Disney+ Premium',
        notes: 'Upgraded to 4K',
      );
      final result = await useCase(updated);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.name, equals('Disney+ Premium'));
      expect(repository.items[sub.id]?.notes, equals('Upgraded to 4K'));
    });

    test('US-07: fails when updating non-existent subscription', () async {
      final sub = createSampleSubscription(id: 'sub-non-existent');
      final result = await useCase(sub);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const SubscriptionNotFoundFailure('sub-non-existent')),
      );
    });

    test(
      'US-07: fails when updated attributes violate validation invariants',
      () async {
        final sub = createSampleSubscription();
        repository.items[sub.id] = sub;

        final invalid = sub.copyWith(name: '');
        final result = await useCase(invalid);

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.emptyName()),
        );
      },
    );
  });

  group('GetSubscriptionByIdUseCase Tests (US-06, FR-03)', () {
    late GetSubscriptionByIdUseCase useCase;

    setUp(() {
      useCase = GetSubscriptionByIdUseCase(repository);
    });

    test('US-06: returns subscription when ID exists', () async {
      final sub = createSampleSubscription(id: 'sub-target');
      repository.items[sub.id] = sub;

      final result = await useCase('sub-target');
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, equals('sub-target'));
    });

    test('US-06: fails with NotFoundFailure when ID does not exist', () async {
      final result = await useCase('unknown-id');
      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const SubscriptionNotFoundFailure('unknown-id')),
      );
    });

    test('US-06: fails with NotFoundFailure when ID is empty string', () async {
      final result = await useCase('   ');
      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        equals(const SubscriptionNotFoundFailure('')),
      );
    });
  });

  group(
    'GetSubscriptionsUseCase & WatchSubscriptionsUseCase Tests (US-05, FR-02)',
    () {
      late GetSubscriptionsUseCase getUseCase;
      late WatchSubscriptionsUseCase watchUseCase;

      setUp(() {
        getUseCase = GetSubscriptionsUseCase(repository);
        watchUseCase = WatchSubscriptionsUseCase(repository);
      });

      test('US-05: returns all subscriptions without filter', () async {
        repository.items['sub-1'] = createSampleSubscription(
          id: 'sub-1',
          status: SubscriptionStatus.active,
        );
        repository.items['sub-2'] = createSampleSubscription(
          id: 'sub-2',
          status: SubscriptionStatus.archived,
        );

        final result = await getUseCase(GetSubscriptionsParams.all);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.length, equals(2));
      });

      test('US-05: filters subscriptions by status', () async {
        repository.items['sub-1'] = createSampleSubscription(
          id: 'sub-1',
          status: SubscriptionStatus.active,
        );
        repository.items['sub-2'] = createSampleSubscription(
          id: 'sub-2',
          status: SubscriptionStatus.archived,
        );
        repository.items['sub-3'] = createSampleSubscription(
          id: 'sub-3',
          status: SubscriptionStatus.inTrash,
        );

        final activeResult = await getUseCase(GetSubscriptionsParams.active);
        expect(activeResult.dataOrNull?.length, equals(1));
        expect(activeResult.dataOrNull?.first.id, equals('sub-1'));

        final archivedResult = await getUseCase(
          GetSubscriptionsParams.archived,
        );
        expect(archivedResult.dataOrNull?.length, equals(1));
        expect(archivedResult.dataOrNull?.first.id, equals('sub-2'));

        final trashResult = await getUseCase(GetSubscriptionsParams.inTrash);
        expect(trashResult.dataOrNull?.length, equals(1));
        expect(trashResult.dataOrNull?.first.id, equals('sub-3'));
      });

      test('US-25: filters subscriptions by categoryId', () async {
        repository.items['sub-1'] = createSampleSubscription(
          id: 'sub-1',
          categoryId: 'cat-work',
        );
        repository.items['sub-2'] = createSampleSubscription(
          id: 'sub-2',
          categoryId: 'cat-fun',
        );

        final result = await getUseCase(
          const GetSubscriptionsParams(categoryId: 'cat-work'),
        );
        expect(result.dataOrNull?.length, equals(1));
        expect(result.dataOrNull?.first.id, equals('sub-1'));
      });

      test('WatchSubscriptionsUseCase emits updates reactively', () async {
        final sub = createSampleSubscription(id: 'sub-stream');
        final stream = watchUseCase(GetSubscriptionsParams.all);

        expectLater(
          stream.map((r) => r.dataOrNull?.length ?? 0),
          emitsInOrder([1]),
        );

        await repository.createSubscription(sub);
      });
    },
  );

  group('Lifecycle Use Cases (Archive, Unarchive, Trash, Restore, Delete, Renew)', () {
    test(
      'US-10 / [EC-10-1]: ArchiveSubscriptionUseCase moves active to archived',
      () async {
        final useCase = ArchiveSubscriptionUseCase(repository);
        final sub = createSampleSubscription(
          id: 'sub-arc',
          status: SubscriptionStatus.active,
        );
        repository.items[sub.id] = sub;

        final result = await useCase('sub-arc');
        expect(result.isSuccess, isTrue);
        expect(
          repository.items['sub-arc']?.status,
          equals(SubscriptionStatus.archived),
        );
      },
    );

    test(
      'US-10: ArchiveSubscriptionUseCase fails if already archived or in trash',
      () async {
        final useCase = ArchiveSubscriptionUseCase(repository);
        final archivedSub = createSampleSubscription(
          id: 'sub-1',
          status: SubscriptionStatus.archived,
        );
        repository.items[archivedSub.id] = archivedSub;

        final res1 = await useCase('sub-1');
        expect(res1.isFailure, isTrue);
        expect(
          res1.failureOrNull,
          equals(SubscriptionStateTransitionFailure.alreadyArchived()),
        );

        final trashSub = createSampleSubscription(
          id: 'sub-2',
          status: SubscriptionStatus.inTrash,
        );
        repository.items[trashSub.id] = trashSub;

        final res2 = await useCase('sub-2');
        expect(res2.isFailure, isTrue);
        expect(
          res2.failureOrNull,
          equals(SubscriptionStateTransitionFailure.alreadyInTrash()),
        );
      },
    );

    test(
      'US-11 / [EC-11-1]: UnarchiveSubscriptionUseCase restores archived to active',
      () async {
        final useCase = UnarchiveSubscriptionUseCase(repository);
        final sub = createSampleSubscription(
          id: 'sub-unarc',
          status: SubscriptionStatus.archived,
        );
        repository.items[sub.id] = sub;

        final result = await useCase('sub-unarc');
        expect(result.isSuccess, isTrue);
        expect(
          repository.items['sub-unarc']?.status,
          equals(SubscriptionStatus.active),
        );
      },
    );

    test(
      'US-12 / [EC-12-1]: MoveSubscriptionToTrashUseCase moves subscription to trash',
      () async {
        final useCase = MoveSubscriptionToTrashUseCase(repository);
        final sub = createSampleSubscription(id: 'sub-trash');
        repository.items[sub.id] = sub;

        final result = await useCase('sub-trash');
        expect(result.isSuccess, isTrue);
        expect(
          repository.items['sub-trash']?.status,
          equals(SubscriptionStatus.inTrash),
        );
      },
    );

    test(
      'US-14 / [EC-14-1]: RestoreSubscriptionFromTrashUseCase restores trashed item',
      () async {
        final useCase = RestoreSubscriptionFromTrashUseCase(repository);
        final sub = createSampleSubscription(
          id: 'sub-restore',
          status: SubscriptionStatus.inTrash,
        );
        repository.items[sub.id] = sub;

        final result = await useCase('sub-restore');
        expect(result.isSuccess, isTrue);
        expect(
          repository.items['sub-restore']?.status,
          equals(SubscriptionStatus.active),
        );
      },
    );

    test(
      'US-13 / [EC-13-1]: PermanentlyDeleteSubscriptionUseCase deletes subscription',
      () async {
        final useCase = PermanentlyDeleteSubscriptionUseCase(repository);
        final sub = createSampleSubscription(id: 'sub-del');
        repository.items[sub.id] = sub;

        final result = await useCase('sub-del');
        expect(result.isSuccess, isTrue);
        expect(repository.items.containsKey('sub-del'), isFalse);
      },
    );

    test(
      'US-28 / FR-11: RenewSubscriptionUseCase advances dueDate for active subscription',
      () async {
        final useCase = RenewSubscriptionUseCase(repository);
        final sub = createSampleSubscription(
          id: 'sub-renew',
          dueDate: DateTime.utc(2026, 3, 15),
          anchorDay: 15,
          cycle: const BillingCycle.monthly(),
        );
        repository.items[sub.id] = sub;

        final result = await useCase(
          const RenewSubscriptionParams(subscriptionId: 'sub-renew'),
        );

        expect(result.isSuccess, isTrue);
        expect(
          result.dataOrNull?.dueDate.dateTime,
          equals(DateTime.utc(2026, 4, 15)),
        );
      },
    );

    test(
      'US-28: RenewSubscriptionUseCase fails when subscription is in trash',
      () async {
        final useCase = RenewSubscriptionUseCase(repository);
        final sub = createSampleSubscription(
          id: 'sub-renew-trash',
          status: SubscriptionStatus.inTrash,
        );
        repository.items[sub.id] = sub;

        final result = await useCase(
          const RenewSubscriptionParams(subscriptionId: 'sub-renew-trash'),
        );

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionStateTransitionFailure.cannotRenewInactive()),
        );
      },
    );
  });
}

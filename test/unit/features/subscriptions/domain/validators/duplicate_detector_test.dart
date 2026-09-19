import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/validators/duplicate_detector.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('DuplicateDetector Tests', () {
    final baseSub = Subscription(
      id: 'sub-1',
      name: 'Netflix',
      price: const Money(amountMinorUnits: 1599, currencyCode: 'USD'),
      cycle: const BillingCycle.monthly(),
      startDate: DateTime.utc(2026, 1, 1),
      dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
      categoryId: 'cat-1',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    test(
      'FR-19 / US-36 / EC-36-1: detect duplicate with exact name, cycle, and due date',
      () {
        final candidate = Subscription(
          id: 'sub-new',
          name: 'Netflix',
          price: const Money(amountMinorUnits: 1599, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
          categoryId: 'cat-2',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

        final result = DuplicateDetector.checkDuplicate(
          candidate: candidate,
          existingSubscriptions: [baseSub],
        );

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const DuplicateSubscriptionFailure()),
        );
      },
    );

    test(
      'FR-19 / US-36 / EC-01-4: detect duplicate ignoring case, spaces, and Arabic diacritics',
      () {
        final arabicSub = Subscription(
          id: 'sub-ar-1',
          name: 'شاهد نت',
          price: const Money(amountMinorUnits: 999, currencyCode: 'SAR'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
          categoryId: 'cat-1',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

        // Candidate with Harakat (Tashkeel) and extra whitespace: "شَاهِدْ   نَتْ"
        final candidate = Subscription(
          id: 'sub-ar-2',
          name: 'شَاهِدْ   نَتْ',
          price: const Money(amountMinorUnits: 999, currencyCode: 'SAR'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
          categoryId: 'cat-1',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

        final result = DuplicateDetector.checkDuplicate(
          candidate: candidate,
          existingSubscriptions: [arabicSub],
        );

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(const DuplicateSubscriptionFailure()),
        );
      },
    );

    test(
      'FR-19 / BR-10: do not flag duplicate against archived or trashed subscriptions',
      () {
        final archivedSub = baseSub.archive();
        final trashedSub = baseSub.moveToTrash();

        final candidate = Subscription(
          id: 'sub-new',
          name: 'Netflix',
          price: const Money(amountMinorUnits: 1599, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
          categoryId: 'cat-2',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

        final resultArchived = DuplicateDetector.checkDuplicate(
          candidate: candidate,
          existingSubscriptions: [archivedSub],
        );
        expect(resultArchived.isSuccess, isTrue);

        final resultTrashed = DuplicateDetector.checkDuplicate(
          candidate: candidate,
          existingSubscriptions: [trashedSub],
        );
        expect(resultTrashed.isSuccess, isTrue);
      },
    );

    test('allow updating existing subscription without self-collision', () {
      final candidate = baseSub.copyWith(notes: 'Updated note');

      final result = DuplicateDetector.checkDuplicate(
        candidate: candidate,
        existingSubscriptions: [baseSub],
      );

      expect(result.isSuccess, isTrue);
    });

    test('allow same subscription name if billing cycle is different', () {
      final candidate = Subscription(
        id: 'sub-yearly',
        name: 'Netflix',
        price: const Money(amountMinorUnits: 15999, currencyCode: 'USD'),
        cycle: const BillingCycle.yearly(),
        startDate: DateTime.utc(2026, 1, 1),
        dueDate: DueDate(DateTime.utc(2027, 1, 1), 1),
        categoryId: 'cat-1',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final result = DuplicateDetector.checkDuplicate(
        candidate: candidate,
        existingSubscriptions: [baseSub],
      );

      expect(result.isSuccess, isTrue);
    });

    test('allow same subscription name if due date is different', () {
      final candidate = Subscription(
        id: 'sub-diff-due',
        name: 'Netflix',
        price: const Money(amountMinorUnits: 1599, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 15),
        dueDate: DueDate(DateTime.utc(2026, 2, 15), 15),
        categoryId: 'cat-1',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final result = DuplicateDetector.checkDuplicate(
        candidate: candidate,
        existingSubscriptions: [baseSub],
      );

      expect(result.isSuccess, isTrue);
    });
  });
}

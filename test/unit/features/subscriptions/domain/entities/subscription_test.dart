import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('Subscription Entity Tests', () {
    Subscription createTestSub({
      String name = 'Netflix',
      Money? price,
      bool isTrial = false,
      BillingCycle cycle = const BillingCycle.monthly(),
      DueDate? dueDate,
      int reminderLeadDays = 1,
      int reminderTimeHour = 9,
      int reminderTimeMinute = 0,
      String? notes,
      String? paymentMethodDesc,
    }) {
      final now = DateTime.utc(2026, 9, 1);
      return Subscription.create(
        id: 'sub-1',
        name: name,
        price:
            price ?? Money.create(amountMinorUnits: 1599, currencyCode: 'USD'),
        cycle: cycle,
        dueDate: dueDate ?? DueDate.create(date: DateTime.utc(2026, 10, 1)),
        startDate: now,
        categoryId: 'cat-entertainment',
        isTrial: isTrial,
        reminderLeadDays: reminderLeadDays,
        reminderTimeHour: reminderTimeHour,
        reminderTimeMinute: reminderTimeMinute,
        notes: notes,
        paymentMethodDesc: paymentMethodDesc,
      );
    }

    test('US-01: creates Subscription entity with valid invariants', () {
      final sub = createTestSub();

      expect(sub.id, 'sub-1');
      expect(sub.name, 'Netflix');
      expect(sub.price.amountMinorUnits, 1599);
      expect(sub.price.currencyCode, 'USD');
      expect(sub.cycle.isMonthly, isTrue);
      expect(sub.status.isActive, isTrue);
      expect(sub.isTrial, isFalse);
    });

    test(
      'US-01 / [EC-01-1]: rejects empty or whitespace-only name with ValidationFailure',
      () {
        expect(
          () => createTestSub(name: '   '),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test(
      'US-01 / [EC-01-2]: rejects name exceeding 60 characters with ValidationFailure',
      () {
        final longName = 'A' * 61;
        expect(
          () => createTestSub(name: longName),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('US-01 / [EC-01-4]: rejects price = 0 when not a free trial', () {
      expect(
        () => createTestSub(price: Money.zero('USD'), isTrial: false),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('US-01 / [EC-01-4]: accepts price = 0 when isTrial is true', () {
      final trialSub = createTestSub(price: Money.zero('USD'), isTrial: true);

      expect(trialSub.price.amountMinorUnits, 0);
      expect(trialSub.isTrial, isTrue);
    });

    test('US-01 / [EC-02-2]: rejects reminder lead days outside 0..30', () {
      expect(
        () => createTestSub(reminderLeadDays: -1),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => createTestSub(reminderLeadDays: 31),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test(
      'US-01 / [EC-02-3]: rejects reminder time outside valid 24h clock',
      () {
        expect(
          () => createTestSub(reminderTimeHour: 24),
          throwsA(isA<ValidationFailure>()),
        );
        expect(
          () => createTestSub(reminderTimeMinute: 60),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('US-01: rejects notes exceeding 500 characters', () {
      expect(
        () => createTestSub(notes: 'N' * 501),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('US-01: rejects paymentMethodDesc exceeding 50 characters', () {
      expect(
        () => createTestSub(paymentMethodDesc: 'P' * 51),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('US-02: markAsRenewed advances due date to next recurrence cycle', () {
      final startDue = DueDate.create(
        date: DateTime.utc(2026, 1, 31),
        originalAnchorDay: 31,
      );
      final sub = createTestSub(dueDate: startDue);

      final renewed = sub.markAsRenewed(at: DateTime.utc(2026, 1, 31, 10, 0));

      // Jan 31 -> Feb 28 in 2026 (common year)
      expect(renewed.dueDate.date, DateTime.utc(2026, 2, 28));
      expect(renewed.dueDate.originalAnchorDay, 31);
      expect(renewed.updatedAt, DateTime.utc(2026, 1, 31, 10, 0));
    });

    test('US-04: archive and unarchive toggle lifecycle state', () {
      final sub = createTestSub();
      final archiveTime = DateTime.utc(2026, 9, 15);

      final archived = sub.archive(at: archiveTime);
      expect(archived.isArchived, isTrue);
      expect(archived.archivedAt, archiveTime);

      final restored = archived.unarchive();
      expect(restored.isActive, isTrue);
      expect(restored.archivedAt, isNull);
    });

    test(
      'US-03: moveToTrash and restoreFromTrash toggle soft-delete state',
      () {
        final sub = createTestSub();
        final deleteTime = DateTime.utc(2026, 9, 18);

        final trashed = sub.moveToTrash(at: deleteTime);
        expect(trashed.isInTrash, isTrue);
        expect(trashed.deletedAt, deleteTime);

        final restored = trashed.restoreFromTrash();
        expect(restored.isActive, isTrue);
        expect(restored.deletedAt, isNull);
      },
    );

    test(
      'US-01: copyWith, toString, and hashCode verify full entity state',
      () {
        final sub = createTestSub();
        final updated = sub.copyWith(
          id: 'sub-2',
          name: 'Spotify',
          price: Money.create(amountMinorUnits: 999, currencyCode: 'USD'),
          cycle: const BillingCycle.yearly(),
          dueDate: DueDate.create(date: DateTime.utc(2027, 1, 1)),
          startDate: DateTime.utc(2026, 1, 1),
          categoryId: 'cat-music',
          isTrial: true,
          notes: 'Updated note',
          renewalUrl: 'https://spotify.com/cancel',
          paymentMethodDesc: 'Mastercard',
          reminderEnabled: false,
          reminderLeadDays: 3,
          reminderTimeHour: 10,
          reminderTimeMinute: 30,
          clearDeletedAt: true,
          clearArchivedAt: true,
        );

        expect(updated.id, 'sub-2');
        expect(updated.name, 'Spotify');
        expect(updated.price.amountMinorUnits, 999);
        expect(updated.cycle.isYearly, isTrue);
        expect(updated.categoryId, 'cat-music');
        expect(updated.isTrial, isTrue);
        expect(updated.notes, 'Updated note');
        expect(updated.renewalUrl, 'https://spotify.com/cancel');
        expect(updated.paymentMethodDesc, 'Mastercard');
        expect(updated.reminderEnabled, isFalse);
        expect(updated.reminderLeadDays, 3);
        expect(updated.reminderTimeHour, 10);
        expect(updated.reminderTimeMinute, 30);
        expect(sub, equals(sub.copyWith()));
        expect(sub.hashCode, isNotNull);
        expect(sub.toString(), contains('Netflix'));
      },
    );
  });
}

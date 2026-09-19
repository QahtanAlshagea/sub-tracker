import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';

void main() {
  group('SubscriptionDomainFailure Tests', () {
    test('SubscriptionValidationFailure equality and hashCode', () {
      final f1 = SubscriptionValidationFailure.emptyName();
      final f2 = SubscriptionValidationFailure.emptyName();
      final f3 = SubscriptionValidationFailure.nameTooLong();

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
      expect(f1.reason, equals(SubscriptionValidationReason.emptyName));
    });

    test(
      'All SubscriptionValidationFailure factories produce distinct reasons',
      () {
        expect(
          SubscriptionValidationFailure.emptyName().reason,
          equals(SubscriptionValidationReason.emptyName),
        );
        expect(
          SubscriptionValidationFailure.nameTooLong().reason,
          equals(SubscriptionValidationReason.nameTooLong),
        );
        expect(
          SubscriptionValidationFailure.negativePrice().reason,
          equals(SubscriptionValidationReason.negativePrice),
        );
        expect(
          SubscriptionValidationFailure.zeroPriceNonTrial().reason,
          equals(SubscriptionValidationReason.zeroPriceNonTrial),
        );
        expect(
          SubscriptionValidationFailure.priceTooHigh().reason,
          equals(SubscriptionValidationReason.priceTooHigh),
        );
        expect(
          SubscriptionValidationFailure.invalidCurrencyCode().reason,
          equals(SubscriptionValidationReason.invalidCurrencyCode),
        );
        expect(
          SubscriptionValidationFailure.invalidCustomCycleDays().reason,
          equals(SubscriptionValidationReason.invalidCustomCycleDays),
        );
        expect(
          SubscriptionValidationFailure.notesTooLong().reason,
          equals(SubscriptionValidationReason.notesTooLong),
        );
        expect(
          SubscriptionValidationFailure.creditCardDetected().reason,
          equals(SubscriptionValidationReason.creditCardDetected),
        );
        expect(
          SubscriptionValidationFailure.paymentMethodDescTooLong().reason,
          equals(SubscriptionValidationReason.paymentMethodDescTooLong),
        );
        expect(
          SubscriptionValidationFailure.invalidUrl().reason,
          equals(SubscriptionValidationReason.invalidUrl),
        );
        expect(
          SubscriptionValidationFailure.invalidReminderLeadDays().reason,
          equals(SubscriptionValidationReason.invalidReminderLeadDays),
        );
        expect(
          SubscriptionValidationFailure.invalidReminderTime().reason,
          equals(SubscriptionValidationReason.invalidReminderTime),
        );
        expect(
          SubscriptionValidationFailure.leadDaysExceedCycle().reason,
          equals(SubscriptionValidationReason.leadDaysExceedCycle),
        );
        expect(
          SubscriptionValidationFailure.invalidAnchorDay().reason,
          equals(SubscriptionValidationReason.invalidAnchorDay),
        );
      },
    );

    test('CategoryValidationFailure equality and factories', () {
      final f1 = CategoryValidationFailure.emptyName();
      final f2 = CategoryValidationFailure.emptyName();
      final f3 = CategoryValidationFailure.cannotModifySystemCategory();

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
      expect(
        CategoryValidationFailure.nameTooLong().reason,
        equals(CategoryValidationReason.nameTooLong),
      );
    });

    test('RecurrenceCalculationFailure equality and factories', () {
      final f1 = RecurrenceCalculationFailure.clockTampered();
      final f2 = RecurrenceCalculationFailure.clockTampered();
      final f3 = RecurrenceCalculationFailure.invalidAnchorDay();

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
    });

    test('DuplicateSubscriptionFailure equality and message', () {
      const f1 = DuplicateSubscriptionFailure();
      const f2 = DuplicateSubscriptionFailure();

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1.message, contains('active subscription'));
    });

    test('SubscriptionStateTransitionFailure equality and factories', () {
      final f1 = SubscriptionStateTransitionFailure.alreadyArchived();
      final f2 = SubscriptionStateTransitionFailure.alreadyArchived();
      final f3 = SubscriptionStateTransitionFailure.cannotRenewInactive();

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
      expect(
        SubscriptionStateTransitionFailure.alreadyInTrash().reason,
        equals(StateTransitionReason.alreadyInTrash),
      );
    });
  });
}

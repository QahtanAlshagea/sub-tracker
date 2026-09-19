import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

void main() {
  group('SubscriptionStatus Enum Tests', () {
    test('US-03, US-04: status flags evaluate correctly', () {
      expect(SubscriptionStatus.active.isActive, isTrue);
      expect(SubscriptionStatus.active.isArchived, isFalse);
      expect(SubscriptionStatus.active.isInTrash, isFalse);

      expect(SubscriptionStatus.archived.isArchived, isTrue);
      expect(SubscriptionStatus.inTrash.isInTrash, isTrue);
    });

    test('US-03: parses status from valid strings', () {
      expect(
        SubscriptionStatus.fromString('active'),
        SubscriptionStatus.active,
      );
      expect(
        SubscriptionStatus.fromString('archived'),
        SubscriptionStatus.archived,
      );
      expect(
        SubscriptionStatus.fromString('in_trash'),
        SubscriptionStatus.inTrash,
      );
      expect(
        SubscriptionStatus.fromString('intrash'),
        SubscriptionStatus.inTrash,
      );
    });

    test('US-03: rejects invalid status string with ValidationFailure', () {
      expect(
        () => SubscriptionStatus.fromString('suspended'),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}

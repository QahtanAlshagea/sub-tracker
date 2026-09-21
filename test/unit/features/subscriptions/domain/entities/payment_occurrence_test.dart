import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/payment_occurrence.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('PaymentOccurrence Entity Tests', () {
    final date = DateTime.utc(2026, 9, 25);

    test('constructor, properties, equality, hashCode and toString', () {
      final p1 = PaymentOccurrence(
        subscriptionId: 'sub-1',
        subscriptionName: 'Spotify',
        dueDate: date,
        price: const Money(amountMinorUnits: 999, currencyCode: 'USD'),
        isOverdue: false,
      );

      final p2 = PaymentOccurrence(
        subscriptionId: 'sub-1',
        subscriptionName: 'Spotify',
        dueDate: date,
        price: const Money(amountMinorUnits: 999, currencyCode: 'USD'),
        isOverdue: false,
      );

      final pDiff = PaymentOccurrence(
        subscriptionId: 'sub-1',
        subscriptionName: 'Spotify',
        dueDate: date,
        price: const Money(amountMinorUnits: 999, currencyCode: 'USD'),
        isOverdue: true,
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(pDiff)));
      expect(p1 == Object(), isFalse);
      expect(p1.toString(), contains('PaymentOccurrence(Spotify, 2026-09-25'));
      expect(p1.toString(), contains('overdue: false'));
    });
  });
}

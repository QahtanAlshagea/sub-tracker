import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/payment_occurrence.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/upcoming_projection.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('UpcomingProjection Entity Tests', () {
    final start = DateTime.utc(2026, 9, 1);
    final end = DateTime.utc(2026, 9, 30);
    final occ = PaymentOccurrence(
      subscriptionId: 'sub-1',
      subscriptionName: 'GitHub Copilot',
      dueDate: DateTime.utc(2026, 9, 15),
      price: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
    );

    test('empty factory creates empty projection with zero values', () {
      final emptyProj = UpcomingProjection.empty(
        currencyCode: 'USD',
        windowStart: start,
        windowEnd: end,
        isCalendarMonth: true,
      );

      expect(emptyProj.currencyCode, 'USD');
      expect(emptyProj.windowStart, start);
      expect(emptyProj.windowEnd, end);
      expect(emptyProj.isCalendarMonth, isTrue);
      expect(emptyProj.isEmpty, isTrue);
      expect(emptyProj.occurrencesCount, 0);
      expect(emptyProj.totalProjected.amountMinorUnits, 0);
      expect(emptyProj.overdueAmount.amountMinorUnits, 0);
      expect(emptyProj.upcomingAmount.amountMinorUnits, 0);
    });

    test('constructor, properties, equality, hashCode and toString', () {
      final proj1 = UpcomingProjection(
        currencyCode: 'USD',
        windowStart: start,
        windowEnd: end,
        totalProjected: const Money(
          amountMinorUnits: 1000,
          currencyCode: 'USD',
        ),
        overdueAmount: Money.zero('USD'),
        upcomingAmount: const Money(
          amountMinorUnits: 1000,
          currencyCode: 'USD',
        ),
        occurrences: [occ],
        isCalendarMonth: true,
      );

      final proj2 = UpcomingProjection(
        currencyCode: 'USD',
        windowStart: start,
        windowEnd: end,
        totalProjected: const Money(
          amountMinorUnits: 1000,
          currencyCode: 'USD',
        ),
        overdueAmount: Money.zero('USD'),
        upcomingAmount: const Money(
          amountMinorUnits: 1000,
          currencyCode: 'USD',
        ),
        occurrences: [occ],
        isCalendarMonth: true,
      );

      final projDiff = UpcomingProjection(
        currencyCode: 'USD',
        windowStart: start,
        windowEnd: end,
        totalProjected: const Money(
          amountMinorUnits: 2000,
          currencyCode: 'USD',
        ),
        overdueAmount: Money.zero('USD'),
        upcomingAmount: const Money(
          amountMinorUnits: 2000,
          currencyCode: 'USD',
        ),
        occurrences: const [],
        isCalendarMonth: false,
      );

      expect(proj1, equals(proj2));
      expect(proj1.hashCode, equals(proj2.hashCode));
      expect(proj1, isNot(equals(projDiff)));
      expect(proj1 == Object(), isFalse);
      expect(proj1.isEmpty, isFalse);
      expect(proj1.occurrencesCount, 1);
      expect(proj1.toString(), contains('UpcomingProjection(USD'));
      expect(proj1.toString(), contains('isCalendarMonth=true'));
    });
  });
}

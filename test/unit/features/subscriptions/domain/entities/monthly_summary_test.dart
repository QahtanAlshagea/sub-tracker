import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/monthly_summary.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('MonthlySummary Entity Tests', () {
    test('create factory validates negative activeSubscriptionsCount', () {
      expect(
        () => MonthlySummary.create(
          currencyCode: 'USD',
          totalMonthlyEquivalent: Money.zero('USD'),
          totalAnnualEquivalent: Money.zero('USD'),
          averageMonthlyCost: Money.zero('USD'),
          activeSubscriptionsCount: -1,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('empty factory creates zeroed summary with isEmpty true', () {
      final emptySummary = MonthlySummary.empty('USD');
      expect(emptySummary.currencyCode, 'USD');
      expect(emptySummary.totalMonthlyEquivalent.amountMinorUnits, 0);
      expect(emptySummary.totalAnnualEquivalent.amountMinorUnits, 0);
      expect(emptySummary.averageMonthlyCost.amountMinorUnits, 0);
      expect(emptySummary.activeSubscriptionsCount, 0);
      expect(emptySummary.isEmpty, isTrue);
    });

    test('constructor, properties, equality, hashCode and toString', () {
      final s1 = MonthlySummary(
        currencyCode: 'USD',
        totalMonthlyEquivalent: const Money(
          amountMinorUnits: 3000,
          currencyCode: 'USD',
        ),
        totalAnnualEquivalent: const Money(
          amountMinorUnits: 36000,
          currencyCode: 'USD',
        ),
        averageMonthlyCost: const Money(
          amountMinorUnits: 1500,
          currencyCode: 'USD',
        ),
        activeSubscriptionsCount: 2,
      );

      final s2 = MonthlySummary(
        currencyCode: 'USD',
        totalMonthlyEquivalent: const Money(
          amountMinorUnits: 3000,
          currencyCode: 'USD',
        ),
        totalAnnualEquivalent: const Money(
          amountMinorUnits: 36000,
          currencyCode: 'USD',
        ),
        averageMonthlyCost: const Money(
          amountMinorUnits: 1500,
          currencyCode: 'USD',
        ),
        activeSubscriptionsCount: 2,
      );

      final sDiff = MonthlySummary(
        currencyCode: 'USD',
        totalMonthlyEquivalent: const Money(
          amountMinorUnits: 5000,
          currencyCode: 'USD',
        ),
        totalAnnualEquivalent: const Money(
          amountMinorUnits: 60000,
          currencyCode: 'USD',
        ),
        averageMonthlyCost: const Money(
          amountMinorUnits: 2500,
          currencyCode: 'USD',
        ),
        activeSubscriptionsCount: 2,
      );

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(sDiff)));
      expect(s1 == Object(), isFalse);
      expect(s1.isEmpty, isFalse);
      expect(s1.toString(), contains('MonthlySummary(USD: monthly=3000'));
      expect(s1.toString(), contains('count=2'));
    });
  });
}

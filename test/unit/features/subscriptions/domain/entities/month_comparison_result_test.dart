import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/month_comparison_result.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('MonthComparisonResult Entity Tests', () {
    final curMonth = DateTime.utc(2026, 9, 1);
    final prevMonth = DateTime.utc(2026, 8, 1);

    test('constructor, properties, equality, hashCode and toString', () {
      final res1 = MonthComparisonResult(
        currencyCode: 'USD',
        currentMonth: curMonth,
        previousMonth: prevMonth,
        currentMonthTotal: const Money(
          amountMinorUnits: 15000,
          currencyCode: 'USD',
        ),
        previousMonthTotal: const Money(
          amountMinorUnits: 10000,
          currencyCode: 'USD',
        ),
        differenceAmount: const Money(
          amountMinorUnits: 5000,
          currencyCode: 'USD',
        ),
        signedDifferenceMinorUnits: 5000,
        percentageChange: 50.0,
        trend: SpendTrend.increasing,
      );

      final res2 = MonthComparisonResult(
        currencyCode: 'USD',
        currentMonth: curMonth,
        previousMonth: prevMonth,
        currentMonthTotal: const Money(
          amountMinorUnits: 15000,
          currencyCode: 'USD',
        ),
        previousMonthTotal: const Money(
          amountMinorUnits: 10000,
          currencyCode: 'USD',
        ),
        differenceAmount: const Money(
          amountMinorUnits: 5000,
          currencyCode: 'USD',
        ),
        signedDifferenceMinorUnits: 5000,
        percentageChange: 50.0,
        trend: SpendTrend.increasing,
      );

      final resDiff = MonthComparisonResult(
        currencyCode: 'USD',
        currentMonth: curMonth,
        previousMonth: prevMonth,
        currentMonthTotal: const Money(
          amountMinorUnits: 8000,
          currencyCode: 'USD',
        ),
        previousMonthTotal: const Money(
          amountMinorUnits: 10000,
          currencyCode: 'USD',
        ),
        differenceAmount: const Money(
          amountMinorUnits: 2000,
          currencyCode: 'USD',
        ),
        signedDifferenceMinorUnits: -2000,
        percentageChange: -20.0,
        trend: SpendTrend.decreasing,
      );

      expect(res1, equals(res2));
      expect(res1.hashCode, equals(res2.hashCode));
      expect(res1, isNot(equals(resDiff)));
      expect(res1 == Object(), isFalse);
      expect(res1.toString(), contains('MonthComparisonResult(USD'));
      expect(res1.toString(), contains('trend: SpendTrend.increasing'));
    });

    test(
      'handles null percentageChange gracefully in toString and equality',
      () {
        final resNullPct = MonthComparisonResult(
          currencyCode: 'USD',
          currentMonth: curMonth,
          previousMonth: prevMonth,
          currentMonthTotal: const Money(
            amountMinorUnits: 15000,
            currencyCode: 'USD',
          ),
          previousMonthTotal: Money.zero('USD'),
          differenceAmount: const Money(
            amountMinorUnits: 15000,
            currencyCode: 'USD',
          ),
          signedDifferenceMinorUnits: 15000,
          percentageChange: null,
          trend: SpendTrend.noPreviousData,
        );

        expect(resNullPct.toString(), contains('change: N/A'));
        expect(resNullPct.trend, SpendTrend.noPreviousData);
      },
    );
  });
}

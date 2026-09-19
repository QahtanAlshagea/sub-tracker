import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';

void main() {
  group('DueDate Value Object Tests', () {
    test(
      'US-01: creates DueDate with automatic anchor extraction from date',
      () {
        final date = DateTime.utc(2026, 5, 15);
        final dueDate = DueDate.create(date: date);

        expect(dueDate.date, date);
        expect(dueDate.originalAnchorDay, 15);
      },
    );

    test('US-01: allows specifying explicit anchor day within 1..31', () {
      final date = DateTime.utc(2026, 2, 28);
      final dueDate = DueDate.create(date: date, originalAnchorDay: 31);

      expect(dueDate.originalAnchorDay, 31);
      expect(dueDate.date, date);
    });

    test(
      'US-01 / [EC-02-1]: rejects anchor day outside 1..31 with ValidationFailure',
      () {
        final date = DateTime.utc(2026, 5, 15);
        expect(
          () => DueDate.create(date: date, originalAnchorDay: 0),
          throwsA(isA<ValidationFailure>()),
        );
        expect(
          () => DueDate.create(date: date, originalAnchorDay: 32),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test(
      'US-33 / [EC-13-1]: monthly recurrence on 31st clamps in shorter months and restores on 31-day months',
      () {
        const cycle = BillingCycle.monthly();
        // Start on Jan 31 in a non-leap year (2023)
        final jan31 = DueDate.create(date: DateTime.utc(2023, 1, 31));

        // Jan 31 -> Feb 28
        final feb = jan31.nextOccurrence(cycle);
        expect(feb.date, DateTime.utc(2023, 2, 28));
        expect(feb.originalAnchorDay, 31);

        // Feb 28 -> Mar 31 (returns to anchor 31!)
        final mar = feb.nextOccurrence(cycle);
        expect(mar.date, DateTime.utc(2023, 3, 31));
        expect(mar.originalAnchorDay, 31);

        // Mar 31 -> Apr 30 (clamps to 30)
        final apr = mar.nextOccurrence(cycle);
        expect(apr.date, DateTime.utc(2023, 4, 30));
        expect(apr.originalAnchorDay, 31);

        // Apr 30 -> May 31 (returns to anchor 31!)
        final may = apr.nextOccurrence(cycle);
        expect(may.date, DateTime.utc(2023, 5, 31));
        expect(may.originalAnchorDay, 31);
      },
    );

    test(
      'US-33 / [EC-13-1]: monthly recurrence on Jan 31 in leap year clamps to Feb 29',
      () {
        const cycle = BillingCycle.monthly();
        // Start on Jan 31 in a leap year (2024)
        final jan31 = DueDate.create(date: DateTime.utc(2024, 1, 31));

        // Jan 31 -> Feb 29 (leap year has 29 days)
        final feb = jan31.nextOccurrence(cycle);
        expect(feb.date, DateTime.utc(2024, 2, 29));
        expect(feb.originalAnchorDay, 31);

        // Feb 29 -> Mar 31
        final mar = feb.nextOccurrence(cycle);
        expect(mar.date, DateTime.utc(2024, 3, 31));
        expect(mar.originalAnchorDay, 31);
      },
    );

    test(
      'US-33 / [EC-14-1]: yearly recurrence on Feb 29 clamps to Feb 28 in common years and returns in leap year',
      () {
        const cycle = BillingCycle.yearly();
        // Start on Feb 29, 2024 (leap year)
        final leapStart = DueDate.create(date: DateTime.utc(2024, 2, 29));

        // 2024 -> 2025 (common year clamps to 28)
        final yr2025 = leapStart.nextOccurrence(cycle);
        expect(yr2025.date, DateTime.utc(2025, 2, 28));
        expect(yr2025.originalAnchorDay, 29);

        // 2025 -> 2026 (common year)
        final yr2026 = yr2025.nextOccurrence(cycle);
        expect(yr2026.date, DateTime.utc(2026, 2, 28));

        // 2026 -> 2027 (common year)
        final yr2027 = yr2026.nextOccurrence(cycle);
        expect(yr2027.date, DateTime.utc(2027, 2, 28));

        // 2027 -> 2028 (leap year returns to Feb 29!)
        final yr2028 = yr2027.nextOccurrence(cycle);
        expect(yr2028.date, DateTime.utc(2028, 2, 29));
        expect(yr2028.originalAnchorDay, 29);
      },
    );

    test('US-01: weekly recurrence adds exactly 7 days', () {
      const cycle = BillingCycle.weekly();
      final start = DueDate.create(date: DateTime.utc(2026, 6, 1));
      final next = start.nextOccurrence(cycle);
      expect(next.date, DateTime.utc(2026, 6, 8));
    });

    test('US-01: custom recurrence adds exact custom days', () {
      final cycle = BillingCycle.custom(10);
      final start = DueDate.create(date: DateTime.utc(2026, 6, 1));
      final next = start.nextOccurrence(cycle);
      expect(next.date, DateTime.utc(2026, 6, 11));
    });

    test('US-01: previousOccurrence moves backward by cycle', () {
      const monthly = BillingCycle.monthly();
      final mar31 = DueDate.create(
        date: DateTime.utc(2024, 3, 31),
        originalAnchorDay: 31,
      );
      final prevMonthly = mar31.previousOccurrence(monthly);
      expect(prevMonthly.date, DateTime.utc(2024, 2, 29));
      expect(prevMonthly.originalAnchorDay, 31);

      const weekly = BillingCycle.weekly();
      final jun8 = DueDate.create(date: DateTime.utc(2026, 6, 8));
      final prevWeekly = jun8.previousOccurrence(weekly);
      expect(prevWeekly.date, DateTime.utc(2026, 6, 1));

      final custom = BillingCycle.custom(10);
      final jun11 = DueDate.create(date: DateTime.utc(2026, 6, 11));
      final prevCustom = jun11.previousOccurrence(custom);
      expect(prevCustom.date, DateTime.utc(2026, 6, 1));

      const yearly = BillingCycle.yearly();
      final yr2026 = DueDate.create(
        date: DateTime.utc(2026, 2, 28),
        originalAnchorDay: 29,
      );
      final prevYearly = yr2026.previousOccurrence(yearly);
      expect(prevYearly.date, DateTime.utc(2025, 2, 28));
      expect(prevYearly.originalAnchorDay, 29);
    });

    test('US-01: compareTo, toString and hashCode work accurately', () {
      final d1 = DueDate.create(date: DateTime.utc(2026, 5, 1));
      final d2 = DueDate.create(date: DateTime.utc(2026, 5, 2));

      expect(d1.compareTo(d2), isNegative);
      expect(d2.compareTo(d1), isPositive);
      expect(d1.hashCode, isNotNull);
      expect(d1.toString(), contains('DueDate'));
    });

    test('US-01: daysUntil, isOverdue, and isDueToday calculate correctly', () {
      final today = DateTime.utc(2026, 9, 19);
      final futureDue = DueDate.create(date: DateTime.utc(2026, 9, 25));
      final todayDue = DueDate.create(date: DateTime.utc(2026, 9, 19));
      final pastDue = DueDate.create(date: DateTime.utc(2026, 9, 10));

      expect(futureDue.daysUntil(today), 6);
      expect(futureDue.isOverdue(today), isFalse);
      expect(futureDue.isDueToday(today), isFalse);

      expect(todayDue.daysUntil(today), 0);
      expect(todayDue.isDueToday(today), isTrue);
      expect(todayDue.isOverdue(today), isFalse);

      expect(pastDue.daysUntil(today), -9);
      expect(pastDue.isOverdue(today), isTrue);
      expect(pastDue.isDueToday(today), isFalse);
    });
  });
}

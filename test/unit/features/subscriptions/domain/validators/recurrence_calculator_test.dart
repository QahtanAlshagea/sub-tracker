import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/validators/recurrence_calculator.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';

void main() {
  group('RecurrenceCalculator Tests', () {
    group('FR-18 & US-33: Month-end Clamping & Anchor Preservation', () {
      test(
        'EC-33-1: 31st monthly subscription clamps to 30 on shorter months and restores 31 on longer months',
        () {
          final startDate = DateTime.utc(2026, 1, 31);
          final cycle = BillingCycle.monthly();

          // 1. Reference in February 2026 -> clamps to Feb 28
          final febDue = RecurrenceCalculator.computeNextDueDate(
            startDate: startDate,
            originalAnchorDay: 31,
            cycle: cycle,
            referenceDate: DateTime.utc(2026, 2, 1),
          );
          expect(febDue.dateTime, equals(DateTime.utc(2026, 2, 28)));
          expect(febDue.originalAnchorDay, equals(31));

          // 2. Reference in March 2026 -> restores to March 31
          final marDue = RecurrenceCalculator.computeNextDueDate(
            startDate: startDate,
            originalAnchorDay: 31,
            cycle: cycle,
            referenceDate: DateTime.utc(2026, 3, 1),
          );
          expect(marDue.dateTime, equals(DateTime.utc(2026, 3, 31)));
          expect(marDue.originalAnchorDay, equals(31));

          // 3. Reference in April 2026 -> clamps to April 30
          final aprDue = RecurrenceCalculator.computeNextDueDate(
            startDate: startDate,
            originalAnchorDay: 31,
            cycle: cycle,
            referenceDate: DateTime.utc(2026, 4, 1),
          );
          expect(aprDue.dateTime, equals(DateTime.utc(2026, 4, 30)));
          expect(aprDue.originalAnchorDay, equals(31));
        },
      );

      test(
        'EC-33-2: Feb 29 leap year subscription clamps to Feb 28 on non-leap years and restores Feb 29 on leap year',
        () {
          final leapStart = DateTime.utc(2024, 2, 29);
          final cycle = BillingCycle.yearly();

          // In non-leap year 2025 -> Feb 28
          final due2025 = RecurrenceCalculator.computeNextDueDate(
            startDate: leapStart,
            originalAnchorDay: 29,
            cycle: cycle,
            referenceDate: DateTime.utc(2025, 1, 1),
          );
          expect(due2025.dateTime, equals(DateTime.utc(2025, 2, 28)));
          expect(due2025.originalAnchorDay, equals(29));

          // In non-leap year 2026 -> Feb 28
          final due2026 = RecurrenceCalculator.computeNextDueDate(
            startDate: leapStart,
            originalAnchorDay: 29,
            cycle: cycle,
            referenceDate: DateTime.utc(2026, 1, 1),
          );
          expect(due2026.dateTime, equals(DateTime.utc(2026, 2, 28)));

          // In next leap year 2028 -> restores Feb 29!
          final due2028 = RecurrenceCalculator.computeNextDueDate(
            startDate: leapStart,
            originalAnchorDay: 29,
            cycle: cycle,
            referenceDate: DateTime.utc(2028, 1, 1),
          );
          expect(due2028.dateTime, equals(DateTime.utc(2028, 2, 29)));
          expect(due2028.originalAnchorDay, equals(29));
        },
      );
    });

    group('FR-18, US-32 & EC-32-1: Past Start Date O(1) Fast-Forward', () {
      test(
        'monthly subscription started 5 years ago fast-forwards directly to upcoming date',
        () {
          final startDate = DateTime.utc(2021, 5, 15);
          final cycle = BillingCycle.monthly();
          final refDate = DateTime.utc(2026, 9, 20);

          final nextDue = RecurrenceCalculator.computeNextDueDate(
            startDate: startDate,
            originalAnchorDay: 15,
            cycle: cycle,
            referenceDate: refDate,
          );

          // Next 15th after Sept 20, 2026 is Oct 15, 2026
          expect(nextDue.dateTime, equals(DateTime.utc(2026, 10, 15)));
        },
      );

      test(
        'weekly subscription started 100 weeks ago fast-forwards directly',
        () {
          final startDate = DateTime.utc(2024, 1, 1); // Monday
          final cycle = BillingCycle.weekly();
          final refDate = DateTime.utc(2026, 9, 19);

          final nextDue = RecurrenceCalculator.computeNextDueDate(
            startDate: startDate,
            originalAnchorDay: 1,
            cycle: cycle,
            referenceDate: refDate,
          );

          expect(nextDue.dateTime.weekday, equals(DateTime.monday));
          expect(
            nextDue.dateTime.isAfter(refDate) ||
                nextDue.dateTime.isAtSameMomentAs(refDate),
            isTrue,
          );
        },
      );

      test(
        'custom 45-day cycle started 500 days ago fast-forwards directly',
        () {
          final startDate = DateTime.utc(2024, 1, 1);
          final cycle = BillingCycle.custom(45);
          final refDate = DateTime.utc(2026, 9, 19);

          final nextDue = RecurrenceCalculator.computeNextDueDate(
            startDate: startDate,
            originalAnchorDay: 1,
            cycle: cycle,
            referenceDate: refDate,
          );

          final totalDays = nextDue.dateTime.difference(startDate).inDays;
          expect(totalDays % 45, equals(0));
          expect(
            nextDue.dateTime.isAfter(refDate) ||
                nextDue.dateTime.isAtSameMomentAs(refDate),
            isTrue,
          );
        },
      );

      test('reference date before or at start date returns start date', () {
        final startDate = DateTime.utc(2027, 1, 1);
        final cycle = BillingCycle.monthly();
        final refDate = DateTime.utc(2026, 1, 1);

        final nextDue = RecurrenceCalculator.computeNextDueDate(
          startDate: startDate,
          originalAnchorDay: 1,
          cycle: cycle,
          referenceDate: refDate,
        );

        expect(nextDue.dateTime, equals(startDate));
      });
    });

    group('US-34 & EC-34-1: Clock Anomaly & Tamper Detection', () {
      test(
        'EC-34-1: detect clock tamper when current clock jumps backwards beyond tolerance',
        () {
          final lastRecorded = DateTime.utc(2026, 9, 19, 14, 0);
          // Current clock shows 2 hours earlier (tampered / rolled back)
          final currentClock = DateTime.utc(2026, 9, 19, 12, 0);

          final result = RecurrenceCalculator.detectClockTampering(
            currentTimestamp: currentClock,
            lastKnownTimestamp: lastRecorded,
            allowedTolerance: const Duration(hours: 1),
          );

          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(RecurrenceCalculationFailure.clockTampered()),
          );
        },
      );

      test(
        'accept minor clock difference within allowed tolerance (e.g. 15 min NTP skew)',
        () {
          final lastRecorded = DateTime.utc(2026, 9, 19, 14, 0);
          final currentClock = DateTime.utc(2026, 9, 19, 13, 50);

          final result = RecurrenceCalculator.detectClockTampering(
            currentTimestamp: currentClock,
            lastKnownTimestamp: lastRecorded,
            allowedTolerance: const Duration(hours: 1),
          );

          expect(result.isSuccess, isTrue);
        },
      );

      test('accept forward progressing time normally', () {
        final lastRecorded = DateTime.utc(2026, 9, 19, 14, 0);
        final currentClock = DateTime.utc(2026, 9, 19, 15, 0);

        final result = RecurrenceCalculator.detectClockTampering(
          currentTimestamp: currentClock,
          lastKnownTimestamp: lastRecorded,
        );

        expect(result.isSuccess, isTrue);
      });
    });
  });
}

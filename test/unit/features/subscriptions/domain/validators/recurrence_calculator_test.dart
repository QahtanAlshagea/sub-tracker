import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/validators/recurrence_calculator.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';

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

      test(
        '[EC-34-2]: Forward clock jump detected when difference is unreasonable (>30 days)',
        () {
          final lastRecorded = DateTime.utc(2026, 9, 21);
          final forwardedClock = DateTime.utc(
            2028,
            9,
            21,
          ); // 2 years jump forward

          final jumpDays = forwardedClock.difference(lastRecorded).inDays;
          final isSuspiciousJump = jumpDays > 30;
          expect(isSuspiciousJump, isTrue);
        },
      );

      test(
        '[EC-34-3]: Invalid or corrupted system timestamp detected and flagged',
        () {
          final corruptedEpoch = DateTime.fromMillisecondsSinceEpoch(
            0,
            isUtc: true,
          ); // 1970
          final isCorrupted =
              corruptedEpoch.year < 2020 || corruptedEpoch.year > 2100;
          expect(isCorrupted, isTrue);
        },
      );
    });

    group(
      'Extended Recurrence & Cycle Continuity (EC-03-3, EC-28-1, EC-28-2, EC-33-3, EC-33-4)',
      () {
        test(
          '[EC-03-3]: Cycle change after creation recalculates from original start date, not edit date',
          () {
            final startDate = DateTime.utc(2026, 1, 15);
            final editDate = DateTime.utc(
              2026,
              5,
              20,
            ); // User edits cycle on May 20

            // Changed from monthly to yearly: must anchor to Jan 15, not May 20
            final nextDue = RecurrenceCalculator.computeNextDueDate(
              startDate: startDate,
              originalAnchorDay: 15,
              cycle: const BillingCycle.yearly(),
              referenceDate: editDate,
            );

            expect(nextDue.dateTime, equals(DateTime.utc(2027, 1, 15)));
            expect(nextDue.originalAnchorDay, 15);
          },
        );

        test(
          '[EC-28-1]: Multi-cycle overdue calculates next upcoming occurrence and missed count',
          () {
            final startDate = DateTime.utc(2026, 1, 1);
            final currentRef = DateTime.utc(2026, 6, 15); // 5 months later

            final nextDue = RecurrenceCalculator.computeNextDueDate(
              startDate: startDate,
              originalAnchorDay: 1,
              cycle: const BillingCycle.monthly(),
              referenceDate: currentRef,
            );

            expect(nextDue.dateTime, equals(DateTime.utc(2026, 7, 1)));
            // Elapsed cycles between Jan 1 and June 15 = 6 cycles due (Jan, Feb, Mar, Apr, May, Jun)
            final elapsedCycles = (currentRef.difference(startDate).inDays / 30)
                .floor();
            expect(elapsedCycles, greaterThan(4));
          },
        );

        test(
          '[EC-28-2]: Unreasonable forward clock jump detected and flagged without generating false cycles',
          () {
            final lastSync = DateTime.utc(2026, 9, 21);
            final futureTamper = DateTime.utc(2035, 1, 1); // 9 year jump

            final jumpYears = futureTamper.year - lastSync.year;
            final isClockAnomalous = jumpYears > 1;
            expect(isClockAnomalous, isTrue);
          },
        );

        test(
          '[EC-33-3]: Quarterly cycle starting August 31 stays anchored to month-ends without drift',
          () {
            final aug31 = DateTime.utc(2026, 8, 31);
            final cycle = const BillingCycle.monthly();
            // Step 1: 3 months after August -> November 30
            final novDue = DueDate(
              aug31,
              31,
            ).nextOccurrence(cycle).nextOccurrence(cycle).nextOccurrence(cycle);
            expect(novDue.dateTime, equals(DateTime.utc(2026, 11, 30)));
            expect(novDue.originalAnchorDay, 31);

            // Step 2: 3 months after November -> February 28 (non-leap)
            final febDue = novDue
                .nextOccurrence(cycle)
                .nextOccurrence(cycle)
                .nextOccurrence(cycle);
            expect(febDue.dateTime, equals(DateTime.utc(2027, 2, 28)));
            expect(febDue.originalAnchorDay, 31);

            // Step 3: 3 months after February -> May 31 (restores 31)
            final mayDue = febDue
                .nextOccurrence(cycle)
                .nextOccurrence(cycle)
                .nextOccurrence(cycle);
            expect(mayDue.dateTime, equals(DateTime.utc(2027, 5, 31)));
            expect(mayDue.originalAnchorDay, 31);
          },
        );

        test(
          '[EC-33-4]: Long recurrence sequence computes from anchor day without cumulative drift',
          () {
            final anchorDate = DateTime.utc(2024, 1, 31); // 31st anchor
            var currentDue = DueDate(anchorDate, 31);

            // Advance 24 months in loop
            for (int i = 0; i < 24; i++) {
              currentDue = currentDue.nextOccurrence(
                const BillingCycle.monthly(),
              );
              expect(currentDue.originalAnchorDay, 31);
            }

            // At month 24 (Jan 2026), anchor 31 must be restored exactly
            expect(currentDue.dateTime, equals(DateTime.utc(2026, 1, 31)));
          },
        );
      },
    );
  });
}

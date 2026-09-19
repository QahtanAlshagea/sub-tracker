import '../../../../core/utils/result.dart';
import '../failures/subscription_failures.dart';
import '../value_objects/billing_cycle.dart';
import '../value_objects/due_date.dart';

/// Pure domain calendar and recurrence calculation engine.
/// Implements FR-18, US-32, US-33, US-34 and EC-32-1, EC-33-1, EC-33-2, EC-34-1.
/// Pure Dart — zero dependencies on Flutter or persistence.
class RecurrenceCalculator {
  const RecurrenceCalculator._();

  /// Calculates the next upcoming due date that falls strictly after or on [referenceDate].
  /// Guaranteed to compute in O(1) time complexity even if [startDate] is in the distant past (US-32, EC-32-1).
  /// Preserves [originalAnchorDay] across variable month lengths and leap years (FR-18, US-33).
  static DueDate computeNextDueDate({
    required DateTime startDate,
    required int originalAnchorDay,
    required BillingCycle cycle,
    required DateTime referenceDate,
  }) {
    // Normalise all inputs to UTC calendar dates (00:00:00)
    final refUtc = DateTime.utc(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final startUtc = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // If reference is before or on start date, the first due date is start date
    if (refUtc.isBefore(startUtc) || refUtc.isAtSameMomentAs(startUtc)) {
      return DueDate(startUtc, originalAnchorDay);
    }

    switch (cycle.type) {
      case CycleType.weekly:
        final diffDays = refUtc.difference(startUtc).inDays;
        final periods = (diffDays / 7).ceil();
        final nextDate = startUtc.add(Duration(days: periods * 7));
        return DueDate(nextDate, originalAnchorDay);

      case CycleType.custom:
        final cycleDays = cycle.customDays ?? 30;
        final diffDays = refUtc.difference(startUtc).inDays;
        final periods = (diffDays / cycleDays).ceil();
        final nextDate = startUtc.add(Duration(days: periods * cycleDays));
        return DueDate(nextDate, originalAnchorDay);

      case CycleType.monthly:
        // Direct O(1) month offset computation
        int monthDiff =
            (refUtc.year - startUtc.year) * 12 +
            (refUtc.month - startUtc.month);
        DateTime candidate = _resolveMonthOccurrence(
          startYear: startUtc.year,
          startMonth: startUtc.month,
          monthOffset: monthDiff,
          anchorDay: originalAnchorDay,
        );

        if (candidate.isBefore(refUtc)) {
          monthDiff += 1;
          candidate = _resolveMonthOccurrence(
            startYear: startUtc.year,
            startMonth: startUtc.month,
            monthOffset: monthDiff,
            anchorDay: originalAnchorDay,
          );
        }
        return DueDate(candidate, originalAnchorDay);

      case CycleType.yearly:
        // Direct O(1) year offset computation
        int yearDiff = refUtc.year - startUtc.year;
        DateTime candidate = _resolveYearOccurrence(
          startYear: startUtc.year,
          month: startUtc.month,
          yearOffset: yearDiff,
          anchorDay: originalAnchorDay,
        );

        if (candidate.isBefore(refUtc)) {
          yearDiff += 1;
          candidate = _resolveYearOccurrence(
            startYear: startUtc.year,
            month: startUtc.month,
            yearOffset: yearDiff,
            anchorDay: originalAnchorDay,
          );
        }
        return DueDate(candidate, originalAnchorDay);
    }
  }

  /// Resolves the specific date for a given month offset with anchor clamping.
  static DateTime _resolveMonthOccurrence({
    required int startYear,
    required int startMonth,
    required int monthOffset,
    required int anchorDay,
  }) {
    final totalMonths = (startMonth - 1) + monthOffset;
    final targetYear = startYear + (totalMonths ~/ 12);
    final targetMonth = (totalMonths % 12) + 1;

    final maxDaysInTargetMonth = DueDate.daysInMonth(targetYear, targetMonth);
    final targetDay = anchorDay > maxDaysInTargetMonth
        ? maxDaysInTargetMonth
        : anchorDay;

    return DateTime.utc(targetYear, targetMonth, targetDay);
  }

  /// Resolves the specific date for a given year offset with Feb 29 leap clamping.
  static DateTime _resolveYearOccurrence({
    required int startYear,
    required int month,
    required int yearOffset,
    required int anchorDay,
  }) {
    final targetYear = startYear + yearOffset;
    final maxDaysInMonth = DueDate.daysInMonth(targetYear, month);
    final targetDay = anchorDay > maxDaysInMonth ? maxDaysInMonth : anchorDay;

    return DateTime.utc(targetYear, month, targetDay);
  }

  /// Detects whether the device clock has jumped backwards abnormally (FR-18, US-34, EC-34-1).
  /// [currentTimestamp]: The active system clock reading.
  /// [lastKnownTimestamp]: The recorded timestamp of the latest persisted event.
  /// [allowedTolerance]: Grace period to absorb minor NTP adjustments or timezone differences.
  static Result<void> detectClockTampering({
    required DateTime currentTimestamp,
    required DateTime lastKnownTimestamp,
    Duration allowedTolerance = const Duration(hours: 1),
  }) {
    if (currentTimestamp.isBefore(
      lastKnownTimestamp.subtract(allowedTolerance),
    )) {
      return Error(RecurrenceCalculationFailure.clockTampered());
    }
    return const Success(null);
  }
}

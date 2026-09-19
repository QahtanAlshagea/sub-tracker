import 'dart:math' as math;
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';

/// Represents a subscription's renewal due date anchored to a specific calendar day.
///
/// Ensures recurrence calculations are strictly evaluated from the original anchor day
/// to prevent cumulative calendar drift (e.g. 31st Jan -> 28th Feb -> 31st Mar).
class DueDate implements Comparable<DueDate> {
  /// The concrete due date and time (always normalized to UTC).
  final DateTime date;

  /// The original calendar day of the month (1-31) when the subscription was initiated.
  final int originalAnchorDay;

  const DueDate._({required this.date, required this.originalAnchorDay})
    : assert(
        originalAnchorDay >= 1 && originalAnchorDay <= 31,
        'Anchor day must be 1..31',
      );

  /// Creates a validated [DueDate] instance.
  /// If [originalAnchorDay] is omitted, it defaults to [date.day].
  factory DueDate.create({required DateTime date, int? originalAnchorDay}) {
    final utcDate = date.isUtc ? date : date.toUtc();
    final anchor = originalAnchorDay ?? utcDate.day;

    if (anchor < 1 || anchor > 31) {
      throw const ValidationFailure(
        'Original anchor day must be between 1 and 31.',
      );
    }

    return DueDate._(date: utcDate, originalAnchorDay: anchor);
  }

  /// Convenience factory creating a [DueDate] with positional parameters.
  factory DueDate(DateTime date, [int? originalAnchorDay]) =>
      DueDate.create(date: date, originalAnchorDay: originalAnchorDay);

  /// Convenience alias for [date].
  DateTime get dateTime => date;

  /// Calculates the next occurrence based on the provided [BillingCycle],
  /// preserving the original anchor day across shorter months and leap years.
  DueDate nextOccurrence(BillingCycle cycle) {
    switch (cycle.type) {
      case CycleType.weekly:
        return DueDate._(
          date: date.add(const Duration(days: 7)),
          originalAnchorDay: originalAnchorDay,
        );

      case CycleType.custom:
        return DueDate._(
          date: date.add(Duration(days: cycle.customDays!)),
          originalAnchorDay: originalAnchorDay,
        );

      case CycleType.monthly:
        final nextYear = date.month == 12 ? date.year + 1 : date.year;
        final nextMonth = date.month == 12 ? 1 : date.month + 1;
        final maxDays = daysInMonth(nextYear, nextMonth);
        final nextDay = math.min(originalAnchorDay, maxDays);

        return DueDate._(
          date: DateTime.utc(
            nextYear,
            nextMonth,
            nextDay,
            date.hour,
            date.minute,
            date.second,
            date.millisecond,
          ),
          originalAnchorDay: originalAnchorDay,
        );

      case CycleType.yearly:
        final nextYear = date.year + 1;
        final maxDays = daysInMonth(nextYear, date.month);
        final nextDay = math.min(originalAnchorDay, maxDays);

        return DueDate._(
          date: DateTime.utc(
            nextYear,
            date.month,
            nextDay,
            date.hour,
            date.minute,
            date.second,
            date.millisecond,
          ),
          originalAnchorDay: originalAnchorDay,
        );
    }
  }

  /// Calculates the previous occurrence based on the provided [BillingCycle].
  DueDate previousOccurrence(BillingCycle cycle) {
    switch (cycle.type) {
      case CycleType.weekly:
        return DueDate._(
          date: date.subtract(const Duration(days: 7)),
          originalAnchorDay: originalAnchorDay,
        );

      case CycleType.custom:
        return DueDate._(
          date: date.subtract(Duration(days: cycle.customDays!)),
          originalAnchorDay: originalAnchorDay,
        );

      case CycleType.monthly:
        final prevYear = date.month == 1 ? date.year - 1 : date.year;
        final prevMonth = date.month == 1 ? 12 : date.month - 1;
        final maxDays = daysInMonth(prevYear, prevMonth);
        final prevDay = math.min(originalAnchorDay, maxDays);

        return DueDate._(
          date: DateTime.utc(
            prevYear,
            prevMonth,
            prevDay,
            date.hour,
            date.minute,
            date.second,
            date.millisecond,
          ),
          originalAnchorDay: originalAnchorDay,
        );

      case CycleType.yearly:
        final prevYear = date.year - 1;
        final maxDays = daysInMonth(prevYear, date.month);
        final prevDay = math.min(originalAnchorDay, maxDays);

        return DueDate._(
          date: DateTime.utc(
            prevYear,
            date.month,
            prevDay,
            date.hour,
            date.minute,
            date.second,
            date.millisecond,
          ),
          originalAnchorDay: originalAnchorDay,
        );
    }
  }

  /// Number of full calendar days between [fromDate] and this due date.
  /// Positive means in the future, negative means overdue.
  int daysUntil(DateTime fromDate) {
    final fromUtc = DateTime.utc(fromDate.year, fromDate.month, fromDate.day);
    final targetUtc = DateTime.utc(date.year, date.month, date.day);
    return targetUtc.difference(fromUtc).inDays;
  }

  /// Whether this due date has passed relative to [currentDate].
  bool isOverdue(DateTime currentDate) => daysUntil(currentDate) < 0;

  /// Whether this due date is due today relative to [currentDate].
  bool isDueToday(DateTime currentDate) => daysUntil(currentDate) == 0;

  /// Helper to calculate maximum days in a specific calendar month.
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        throw ArgumentError('Invalid month: $month');
    }
  }

  /// Helper to check if a calendar year is a leap year.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  @override
  int compareTo(DueDate other) => date.compareTo(other.date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DueDate &&
          runtimeType == other.runtimeType &&
          date.isAtSameMomentAs(other.date) &&
          originalAnchorDay == other.originalAnchorDay;

  @override
  int get hashCode => date.hashCode ^ originalAnchorDay.hashCode;

  @override
  String toString() =>
      'DueDate(${date.toIso8601String()}, anchor: $originalAnchorDay)';
}

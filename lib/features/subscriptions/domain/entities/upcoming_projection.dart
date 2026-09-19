import '../value_objects/money.dart';
import 'payment_occurrence.dart';

/// Projection of upcoming subscription payments over a defined window (calendar month or rolling 30 days).
///
/// Implements FR-06, US-16, US-17, EC-16-1..4, EC-17-1..3.
/// Pure Dart — zero external dependencies.
class UpcomingProjection {
  /// The ISO 4217 currency code of this projection.
  final String currencyCode;

  /// Start timestamp of the projection window (inclusive, UTC).
  final DateTime windowStart;

  /// End timestamp of the projection window (inclusive, UTC).
  final DateTime windowEnd;

  /// Total sum of all scheduled occurrences falling within the window.
  final Money totalProjected;

  /// Sum of occurrences that are overdue relative to the reference date (EC-16-3).
  final Money overdueAmount;

  /// Sum of occurrences due on or after the reference date within the window.
  final Money upcomingAmount;

  /// List of individual payment occurrences sorted chronologically by due date.
  final List<PaymentOccurrence> occurrences;

  /// True if this projection represents a calendar month (US-16), false if rolling window (US-17).
  final bool isCalendarMonth;

  const UpcomingProjection({
    required this.currencyCode,
    required this.windowStart,
    required this.windowEnd,
    required this.totalProjected,
    required this.overdueAmount,
    required this.upcomingAmount,
    required this.occurrences,
    required this.isCalendarMonth,
  });

  /// Creates an empty projection with zero amounts (EC-16-4).
  factory UpcomingProjection.empty({
    required String currencyCode,
    required DateTime windowStart,
    required DateTime windowEnd,
    required bool isCalendarMonth,
  }) {
    return UpcomingProjection(
      currencyCode: currencyCode,
      windowStart: windowStart,
      windowEnd: windowEnd,
      totalProjected: Money.zero(currencyCode),
      overdueAmount: Money.zero(currencyCode),
      upcomingAmount: Money.zero(currencyCode),
      occurrences: const [],
      isCalendarMonth: isCalendarMonth,
    );
  }

  /// True if there are zero scheduled payments in the projection window (EC-16-4).
  bool get isEmpty => occurrences.isEmpty;

  /// Number of payment occurrences in the window.
  int get occurrencesCount => occurrences.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpcomingProjection &&
          runtimeType == other.runtimeType &&
          currencyCode == other.currencyCode &&
          windowStart == other.windowStart &&
          windowEnd == other.windowEnd &&
          totalProjected == other.totalProjected &&
          overdueAmount == other.overdueAmount &&
          upcomingAmount == other.upcomingAmount &&
          isCalendarMonth == other.isCalendarMonth &&
          _occurrencesEqual(occurrences, other.occurrences);

  static bool _occurrencesEqual(
    List<PaymentOccurrence> a,
    List<PaymentOccurrence> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      currencyCode.hashCode ^
      windowStart.hashCode ^
      windowEnd.hashCode ^
      totalProjected.hashCode ^
      overdueAmount.hashCode ^
      upcomingAmount.hashCode ^
      isCalendarMonth.hashCode ^
      occurrences.length.hashCode;

  @override
  String toString() =>
      'UpcomingProjection($currencyCode, total=${totalProjected.amountMinorUnits}, '
      'count=${occurrences.length}, isCalendarMonth=$isCalendarMonth)';
}

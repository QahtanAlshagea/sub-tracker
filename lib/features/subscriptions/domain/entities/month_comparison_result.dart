import '../value_objects/money.dart';

/// Direction of recurring spending change when comparing current month to previous month.
enum SpendTrend {
  /// Spending has increased compared to the previous month.
  increasing,

  /// Spending has decreased compared to the previous month.
  decreasing,

  /// Spending has remained identical (EC-20-3).
  unchanged,

  /// Previous month had no spending/commitments or zero data (EC-20-1, EC-20-2).
  noPreviousData,
}

/// Result of comparing spending between current calendar month and previous calendar month.
///
/// Implements FR-07, US-20, EC-20-1..3.
/// Pure Dart — zero dependencies.
class MonthComparisonResult {
  /// ISO 4217 currency code.
  final String currencyCode;

  /// Anchor timestamp for current calendar month (first day of month, UTC).
  final DateTime currentMonth;

  /// Anchor timestamp for previous calendar month (first day of month, UTC).
  final DateTime previousMonth;

  /// Total spending / projection for current month.
  final Money currentMonthTotal;

  /// Total spending / projection for previous month.
  final Money previousMonthTotal;

  /// Absolute monetary difference between current and previous month totals.
  final Money differenceAmount;

  /// Signed integer difference in minor units: `currentMonthTotal - previousMonthTotal`.
  final int signedDifferenceMinorUnits;

  /// Percentage change relative to previous month: `((current - previous) / previous) * 100`.
  /// Null if previous month was 0 or no previous data existed (prevents division by zero, EC-20-2).
  final double? percentageChange;

  /// Trend classification indicator (increasing, decreasing, unchanged, noPreviousData).
  final SpendTrend trend;

  const MonthComparisonResult({
    required this.currencyCode,
    required this.currentMonth,
    required this.previousMonth,
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.differenceAmount,
    required this.signedDifferenceMinorUnits,
    required this.percentageChange,
    required this.trend,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthComparisonResult &&
          runtimeType == other.runtimeType &&
          currencyCode == other.currencyCode &&
          currentMonth == other.currentMonth &&
          previousMonth == other.previousMonth &&
          currentMonthTotal == other.currentMonthTotal &&
          previousMonthTotal == other.previousMonthTotal &&
          differenceAmount == other.differenceAmount &&
          signedDifferenceMinorUnits == other.signedDifferenceMinorUnits &&
          _percentEqual(percentageChange, other.percentageChange) &&
          trend == other.trend;

  static bool _percentEqual(double? a, double? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return (a - b).abs() < 0.001;
  }

  @override
  int get hashCode =>
      currencyCode.hashCode ^
      currentMonth.hashCode ^
      previousMonth.hashCode ^
      currentMonthTotal.hashCode ^
      previousMonthTotal.hashCode ^
      differenceAmount.hashCode ^
      signedDifferenceMinorUnits.hashCode ^
      (percentageChange?.hashCode ?? 0) ^
      trend.hashCode;

  @override
  String toString() =>
      'MonthComparisonResult($currencyCode, current: $currentMonthTotal, previous: $previousMonthTotal, '
      'diff: $signedDifferenceMinorUnits, change: ${percentageChange != null ? "${percentageChange!.toStringAsFixed(1)}%" : "N/A"}, trend: $trend)';
}

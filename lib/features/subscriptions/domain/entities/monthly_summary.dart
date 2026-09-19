import 'package:sub_tracker/core/error/failures.dart';
import '../value_objects/money.dart';

/// Aggregated monthly and annual summary metrics for a specific currency.
///
/// Implements FR-06, BR-07, BR-08, BR-10, US-15.
/// Pure Dart — zero dependencies on UI or persistence.
class MonthlySummary {
  /// The 3-letter ISO 4217 uppercase currency code.
  final String currencyCode;

  /// Total monthly equivalent cost across all active subscriptions in this currency.
  final Money totalMonthlyEquivalent;

  /// Total annual equivalent cost (derived as monthly equivalent * 12).
  final Money totalAnnualEquivalent;

  /// Average monthly cost per active subscription (rounded to nearest minor unit).
  final Money averageMonthlyCost;

  /// Number of active subscriptions included in this summary.
  final int activeSubscriptionsCount;

  const MonthlySummary({
    required this.currencyCode,
    required this.totalMonthlyEquivalent,
    required this.totalAnnualEquivalent,
    required this.averageMonthlyCost,
    required this.activeSubscriptionsCount,
  });

  /// Factory validating domain invariants before construction.
  factory MonthlySummary.create({
    required String currencyCode,
    required Money totalMonthlyEquivalent,
    required Money totalAnnualEquivalent,
    required Money averageMonthlyCost,
    required int activeSubscriptionsCount,
  }) {
    if (activeSubscriptionsCount < 0) {
      throw const ValidationFailure(
        'activeSubscriptionsCount cannot be negative',
      );
    }
    return MonthlySummary(
      currencyCode: currencyCode,
      totalMonthlyEquivalent: totalMonthlyEquivalent,
      totalAnnualEquivalent: totalAnnualEquivalent,
      averageMonthlyCost: averageMonthlyCost,
      activeSubscriptionsCount: activeSubscriptionsCount,
    );
  }

  /// Creates a zeroed summary representing an empty state (EC-15-1..4).
  factory MonthlySummary.empty(String currencyCode) {
    return MonthlySummary(
      currencyCode: currencyCode,
      totalMonthlyEquivalent: Money.zero(currencyCode),
      totalAnnualEquivalent: Money.zero(currencyCode),
      averageMonthlyCost: Money.zero(currencyCode),
      activeSubscriptionsCount: 0,
    );
  }

  /// True if there are zero active subscriptions in this currency.
  bool get isEmpty => activeSubscriptionsCount == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummary &&
          runtimeType == other.runtimeType &&
          currencyCode == other.currencyCode &&
          totalMonthlyEquivalent == other.totalMonthlyEquivalent &&
          totalAnnualEquivalent == other.totalAnnualEquivalent &&
          averageMonthlyCost == other.averageMonthlyCost &&
          activeSubscriptionsCount == other.activeSubscriptionsCount;

  @override
  int get hashCode =>
      currencyCode.hashCode ^
      totalMonthlyEquivalent.hashCode ^
      totalAnnualEquivalent.hashCode ^
      averageMonthlyCost.hashCode ^
      activeSubscriptionsCount.hashCode;

  @override
  String toString() =>
      'MonthlySummary($currencyCode: monthly=${totalMonthlyEquivalent.amountMinorUnits}, '
      'annual=${totalAnnualEquivalent.amountMinorUnits}, '
      'avg=${averageMonthlyCost.amountMinorUnits}, count=$activeSubscriptionsCount)';
}

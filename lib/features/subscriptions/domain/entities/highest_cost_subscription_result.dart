import '../value_objects/money.dart';
import 'subscription.dart';

/// Details of the highest recurring cost subscription in a specific currency.
///
/// Implements FR-06, US-18, EC-18-1..3.
/// Pure Dart — zero dependencies.
class HighestCostSubscriptionResult {
  /// The detected subscription with highest monthly equivalent.
  final Subscription subscription;

  /// The normalized monthly equivalent cost of this subscription.
  final Money monthlyEquivalent;

  /// Percentage of total active monthly spending represented by this subscription (0.0 to 100.0).
  final double percentageOfTotal;

  /// True if another active subscription shares the exact same highest monthly cost (EC-18-1).
  final bool hasTie;

  /// True if this is the only active subscription in this currency (EC-18-2).
  final bool isSingleSubscription;

  const HighestCostSubscriptionResult({
    required this.subscription,
    required this.monthlyEquivalent,
    required this.percentageOfTotal,
    required this.hasTie,
    required this.isSingleSubscription,
  }) : assert(
         percentageOfTotal >= 0.0 && percentageOfTotal <= 100.0,
         'percentageOfTotal must be between 0.0 and 100.0',
       );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighestCostSubscriptionResult &&
          runtimeType == other.runtimeType &&
          subscription == other.subscription &&
          monthlyEquivalent == other.monthlyEquivalent &&
          (percentageOfTotal - other.percentageOfTotal).abs() < 0.001 &&
          hasTie == other.hasTie &&
          isSingleSubscription == other.isSingleSubscription;

  @override
  int get hashCode =>
      subscription.hashCode ^
      monthlyEquivalent.hashCode ^
      percentageOfTotal.hashCode ^
      hasTie.hashCode ^
      isSingleSubscription.hashCode;

  @override
  String toString() =>
      'HighestCostSubscriptionResult(${subscription.name}, monthly: $monthlyEquivalent, '
      'share: ${percentageOfTotal.toStringAsFixed(1)}%, tie: $hasTie, single: $isSingleSubscription)';
}

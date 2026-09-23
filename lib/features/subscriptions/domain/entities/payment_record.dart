import '../value_objects/money.dart';

/// Pure Dart entity representing an individual recorded payment/settlement.
///
/// Implements [FR-11] and [US-28].
class PaymentRecord {
  final String id;
  final String subscriptionId;
  final Money amount;
  final DateTime paidAt;
  final String cycleType;
  final String? note;

  const PaymentRecord({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.paidAt,
    required this.cycleType,
    this.note,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subscriptionId == other.subscriptionId &&
          amount == other.amount &&
          paidAt == other.paidAt &&
          cycleType == other.cycleType;

  @override
  int get hashCode =>
      id.hashCode ^
      subscriptionId.hashCode ^
      amount.hashCode ^
      paidAt.hashCode ^
      cycleType.hashCode;
}

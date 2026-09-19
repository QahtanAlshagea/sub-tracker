import '../value_objects/money.dart';

/// Represents a single scheduled billing occurrence within a calendar or rolling window.
///
/// Implements US-16, US-17, EC-16-1..3, EC-17-1..2.
/// Pure Dart — zero external dependencies.
class PaymentOccurrence {
  /// Unique identifier of the originating subscription.
  final String subscriptionId;

  /// Display name of the subscription.
  final String subscriptionName;

  /// The exact calendar date of this payment occurrence in UTC.
  final DateTime dueDate;

  /// The cost billed at this occurrence.
  final Money price;

  /// Indicates if this occurrence is past due relative to the reference anchor date (EC-16-3).
  final bool isOverdue;

  const PaymentOccurrence({
    required this.subscriptionId,
    required this.subscriptionName,
    required this.dueDate,
    required this.price,
    this.isOverdue = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentOccurrence &&
          runtimeType == other.runtimeType &&
          subscriptionId == other.subscriptionId &&
          subscriptionName == other.subscriptionName &&
          dueDate == other.dueDate &&
          price == other.price &&
          isOverdue == other.isOverdue;

  @override
  int get hashCode =>
      subscriptionId.hashCode ^
      subscriptionName.hashCode ^
      dueDate.hashCode ^
      price.hashCode ^
      isOverdue.hashCode;

  @override
  String toString() =>
      'PaymentOccurrence($subscriptionName, ${dueDate.toIso8601String().substring(0, 10)}, price: $price, overdue: $isOverdue)';
}

import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

/// Represents a historical price change entry for a subscription.
///
/// Enables tracking inflation, historical cost analysis, and visual price trends.
class PriceHistoryEntry {
  /// Unique entry identifier (UUID v4).
  final String id;

  /// The associated subscription identifier.
  final String subscriptionId;

  /// The previous monetary price.
  final Money oldPrice;

  /// The new monetary price after modification.
  final Money newPrice;

  /// UTC timestamp when the price change became effective.
  final DateTime changedAt;

  const PriceHistoryEntry({
    required this.id,
    required this.subscriptionId,
    required this.oldPrice,
    required this.newPrice,
    required this.changedAt,
  });

  /// Factory validating that currencies match between old and new price.
  factory PriceHistoryEntry.create({
    required String id,
    required String subscriptionId,
    required Money oldPrice,
    required Money newPrice,
    DateTime? changedAt,
  }) {
    if (oldPrice.currencyCode != newPrice.currencyCode) {
      throw ValidationFailure(
        'Currency mismatch in price history: old was ${oldPrice.currencyCode}, new is ${newPrice.currencyCode}.',
      );
    }

    return PriceHistoryEntry(
      id: id,
      subscriptionId: subscriptionId,
      oldPrice: oldPrice,
      newPrice: newPrice,
      changedAt: (changedAt ?? DateTime.now()).toUtc(),
    );
  }

  /// Calculates the absolute price difference.
  int get priceDeltaMinorUnits =>
      newPrice.amountMinorUnits - oldPrice.amountMinorUnits;

  /// Whether this change was a price increase.
  bool get isPriceIncrease => priceDeltaMinorUnits > 0;

  /// Whether this change was a price reduction.
  bool get isPriceDecrease => priceDeltaMinorUnits < 0;

  PriceHistoryEntry copyWith({
    String? id,
    String? subscriptionId,
    Money? oldPrice,
    Money? newPrice,
    DateTime? changedAt,
  }) {
    return PriceHistoryEntry(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      oldPrice: oldPrice ?? this.oldPrice,
      newPrice: newPrice ?? this.newPrice,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceHistoryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subscriptionId == other.subscriptionId &&
          oldPrice == other.oldPrice &&
          newPrice == other.newPrice &&
          changedAt.isAtSameMomentAs(other.changedAt);

  @override
  int get hashCode =>
      id.hashCode ^
      subscriptionId.hashCode ^
      oldPrice.hashCode ^
      newPrice.hashCode ^
      changedAt.hashCode;

  @override
  String toString() =>
      'PriceHistoryEntry(id: $id, sub: $subscriptionId, $oldPrice -> $newPrice, at: ${changedAt.toIso8601String()})';
}

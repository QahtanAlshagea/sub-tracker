import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/price_history_entry.dart';
import '../../domain/value_objects/money.dart';

/// Data Model for Price History Entries.
///
/// Handles bidirectional mapping between Drift generated database rows (`db.PriceHistoryData`),
/// companions (`db.PriceHistoryCompanion`), domain entities (`PriceHistoryEntry`), and JSON.
class PriceHistoryModel {
  final String id;
  final String subscriptionId;
  final int oldPriceMinorUnits;
  final int newPriceMinorUnits;
  final String currencyCode;
  final DateTime changedAt;

  const PriceHistoryModel({
    required this.id,
    required this.subscriptionId,
    required this.oldPriceMinorUnits,
    required this.newPriceMinorUnits,
    required this.currencyCode,
    required this.changedAt,
  });

  /// Creates a [PriceHistoryModel] from a pure domain [PriceHistoryEntry] entity.
  factory PriceHistoryModel.fromEntity(PriceHistoryEntry entity) {
    return PriceHistoryModel(
      id: entity.id,
      subscriptionId: entity.subscriptionId,
      oldPriceMinorUnits: entity.oldPrice.amountMinorUnits,
      newPriceMinorUnits: entity.newPrice.amountMinorUnits,
      currencyCode: entity.oldPrice.currencyCode,
      changedAt: entity.changedAt,
    );
  }

  /// Converts this model to a pure domain [PriceHistoryEntry] entity.
  PriceHistoryEntry toEntity() {
    return PriceHistoryEntry(
      id: id,
      subscriptionId: subscriptionId,
      oldPrice: Money(
        amountMinorUnits: oldPriceMinorUnits,
        currencyCode: currencyCode,
      ),
      newPrice: Money(
        amountMinorUnits: newPriceMinorUnits,
        currencyCode: currencyCode,
      ),
      changedAt: changedAt,
    );
  }

  /// Creates a [PriceHistoryModel] from a Drift generated [db.PriceHistoryData] row.
  factory PriceHistoryModel.fromData(db.PriceHistoryData data) {
    return PriceHistoryModel(
      id: data.id,
      subscriptionId: data.subscriptionId,
      oldPriceMinorUnits: data.oldPriceMinorUnits,
      newPriceMinorUnits: data.newPriceMinorUnits,
      currencyCode: data.currencyCode,
      changedAt: data.changedAt,
    );
  }

  /// Converts this model to a Drift [db.PriceHistoryCompanion].
  db.PriceHistoryCompanion toCompanion({bool forInsert = false}) {
    return db.PriceHistoryCompanion(
      id: Value(id),
      subscriptionId: Value(subscriptionId),
      oldPriceMinorUnits: Value(oldPriceMinorUnits),
      newPriceMinorUnits: Value(newPriceMinorUnits),
      currencyCode: Value(currencyCode),
      changedAt: Value(changedAt),
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'old_price_minor_units': oldPriceMinorUnits,
      'new_price_minor_units': newPriceMinorUnits,
      'currency_code': currencyCode,
      'changed_at': changedAt.toIso8601String(),
    };
  }

  /// Deserializes from a JSON map.
  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      id: json['id'] as String,
      subscriptionId: json['subscription_id'] as String,
      oldPriceMinorUnits: json['old_price_minor_units'] as int,
      newPriceMinorUnits: json['new_price_minor_units'] as int,
      currencyCode: json['currency_code'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String).toUtc(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceHistoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subscriptionId == other.subscriptionId &&
          oldPriceMinorUnits == other.oldPriceMinorUnits &&
          newPriceMinorUnits == other.newPriceMinorUnits &&
          currencyCode == other.currencyCode &&
          changedAt.isAtSameMomentAs(other.changedAt);

  @override
  int get hashCode =>
      id.hashCode ^
      subscriptionId.hashCode ^
      oldPriceMinorUnits.hashCode ^
      newPriceMinorUnits.hashCode ^
      currencyCode.hashCode ^
      changedAt.hashCode;

  @override
  String toString() =>
      'PriceHistoryModel(id: $id, sub: $subscriptionId, $oldPriceMinorUnits -> $newPriceMinorUnits $currencyCode)';
}

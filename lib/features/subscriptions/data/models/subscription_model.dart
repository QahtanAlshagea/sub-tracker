import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/subscription.dart';
import '../../domain/value_objects/billing_cycle.dart';
import '../../domain/value_objects/due_date.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/subscription_status.dart';

/// Data Model for Subscriptions.
///
/// Encapsulates all subscription properties, handling serialization,
/// Drift companion construction, and mapping to/from pure domain [Subscription] entities.
class SubscriptionModel {
  final String id;
  final String name;
  final int priceMinorUnits;
  final String currencyCode;
  final String cycleType;
  final int? customCycleDays;
  final DateTime startDate;
  final DateTime nextDueDate;
  final int originalAnchorDay;
  final String categoryId;
  final String status;
  final bool isTrial;
  final String? notes;
  final String? renewalUrl;
  final String? paymentMethodDesc;
  final bool reminderEnabled;
  final int reminderLeadDays;
  final int reminderTimeHour;
  final int reminderTimeMinute;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? archivedAt;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.priceMinorUnits,
    required this.currencyCode,
    required this.cycleType,
    this.customCycleDays,
    required this.startDate,
    required this.nextDueDate,
    required this.originalAnchorDay,
    required this.categoryId,
    this.status = 'active',
    this.isTrial = false,
    this.notes,
    this.renewalUrl,
    this.paymentMethodDesc,
    this.reminderEnabled = true,
    this.reminderLeadDays = 1,
    this.reminderTimeHour = 9,
    this.reminderTimeMinute = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.archivedAt,
  });

  /// Converts a pure domain [Subscription] entity into a [SubscriptionModel].
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      name: entity.name,
      priceMinorUnits: entity.price.amountMinorUnits,
      currencyCode: entity.price.currencyCode,
      cycleType: entity.cycle.name,
      customCycleDays: entity.cycle.customDays,
      startDate: entity.startDate,
      nextDueDate: entity.dueDate.date,
      originalAnchorDay: entity.dueDate.originalAnchorDay,
      categoryId: entity.categoryId,
      status: entity.status.name,
      isTrial: entity.isTrial,
      notes: entity.notes,
      renewalUrl: entity.renewalUrl,
      paymentMethodDesc: entity.paymentMethodDesc,
      reminderEnabled: entity.reminderEnabled,
      reminderLeadDays: entity.reminderLeadDays,
      reminderTimeHour: entity.reminderTimeHour,
      reminderTimeMinute: entity.reminderTimeMinute,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      archivedAt: entity.archivedAt,
    );
  }

  /// Converts this model back into a pure domain [Subscription] entity.
  Subscription toEntity() {
    return Subscription(
      id: id,
      name: name,
      price: Money(
        amountMinorUnits: priceMinorUnits,
        currencyCode: currencyCode,
      ),
      cycle: BillingCycle.fromString(cycleType, customCycleDays),
      dueDate: DueDate.create(
        date: nextDueDate,
        originalAnchorDay: originalAnchorDay,
      ),
      startDate: startDate,
      categoryId: categoryId,
      status: SubscriptionStatus.fromString(status),
      isTrial: isTrial,
      notes: notes,
      renewalUrl: renewalUrl,
      paymentMethodDesc: paymentMethodDesc,
      reminderEnabled: reminderEnabled,
      reminderLeadDays: reminderLeadDays,
      reminderTimeHour: reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      archivedAt: archivedAt,
    );
  }

  /// Creates a [SubscriptionModel] from a Drift generated [db.Subscription] row.
  factory SubscriptionModel.fromData(db.Subscription data) {
    return SubscriptionModel(
      id: data.id,
      name: data.name,
      priceMinorUnits: data.priceMinorUnits,
      currencyCode: data.currencyCode,
      cycleType: data.cycleType,
      customCycleDays: data.customCycleDays,
      startDate: data.startDate,
      nextDueDate: data.nextDueDate,
      originalAnchorDay: data.originalAnchorDay,
      categoryId: data.categoryId,
      status: data.status,
      isTrial: data.isTrial,
      notes: data.notes,
      renewalUrl: data.renewalUrl,
      paymentMethodDesc: data.paymentMethodDesc,
      reminderEnabled: data.reminderEnabled,
      reminderLeadDays: data.reminderLeadDays,
      reminderTimeHour: data.reminderTimeHour,
      reminderTimeMinute: data.reminderTimeMinute,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
      archivedAt: data.archivedAt,
    );
  }

  /// Converts this model to a Drift [db.SubscriptionsCompanion] for database writes.
  db.SubscriptionsCompanion toCompanion({bool forInsert = false}) {
    return db.SubscriptionsCompanion(
      id: Value(id),
      name: Value(name),
      priceMinorUnits: Value(priceMinorUnits),
      currencyCode: Value(currencyCode),
      cycleType: Value(cycleType),
      customCycleDays: Value(customCycleDays),
      startDate: Value(startDate),
      nextDueDate: Value(nextDueDate),
      originalAnchorDay: Value(originalAnchorDay),
      categoryId: Value(categoryId),
      status: Value(status),
      isTrial: Value(isTrial),
      notes: Value(notes),
      renewalUrl: Value(renewalUrl),
      paymentMethodDesc: Value(paymentMethodDesc),
      reminderEnabled: Value(reminderEnabled),
      reminderLeadDays: Value(reminderLeadDays),
      reminderTimeHour: Value(reminderTimeHour),
      reminderTimeMinute: Value(reminderTimeMinute),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      archivedAt: Value(archivedAt),
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_minor_units': priceMinorUnits,
      'currency_code': currencyCode,
      'cycle_type': cycleType,
      'custom_cycle_days': customCycleDays,
      'start_date': startDate.toIso8601String(),
      'next_due_date': nextDueDate.toIso8601String(),
      'original_anchor_day': originalAnchorDay,
      'category_id': categoryId,
      'status': status,
      'is_trial': isTrial,
      'notes': notes,
      'renewal_url': renewalUrl,
      'payment_method_desc': paymentMethodDesc,
      'reminder_enabled': reminderEnabled,
      'reminder_lead_days': reminderLeadDays,
      'reminder_time_hour': reminderTimeHour,
      'reminder_time_minute': reminderTimeMinute,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }

  /// Deserializes from a JSON map.
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      priceMinorUnits: json['price_minor_units'] as int,
      currencyCode: json['currency_code'] as String,
      cycleType: json['cycle_type'] as String,
      customCycleDays: json['custom_cycle_days'] as int?,
      startDate: DateTime.parse(json['start_date'] as String).toUtc(),
      nextDueDate: DateTime.parse(json['next_due_date'] as String).toUtc(),
      originalAnchorDay: json['original_anchor_day'] as int,
      categoryId: json['category_id'] as String,
      status: (json['status'] as String?) ?? 'active',
      isTrial: (json['is_trial'] as bool?) ?? false,
      notes: json['notes'] as String?,
      renewalUrl: json['renewal_url'] as String?,
      paymentMethodDesc: json['payment_method_desc'] as String?,
      reminderEnabled: (json['reminder_enabled'] as bool?) ?? true,
      reminderLeadDays: (json['reminder_lead_days'] as int?) ?? 1,
      reminderTimeHour: (json['reminder_time_hour'] as int?) ?? 9,
      reminderTimeMinute: (json['reminder_time_minute'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String).toUtc()
          : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String).toUtc()
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          priceMinorUnits == other.priceMinorUnits &&
          currencyCode == other.currencyCode &&
          cycleType == other.cycleType &&
          customCycleDays == other.customCycleDays &&
          categoryId == other.categoryId &&
          status == other.status &&
          isTrial == other.isTrial &&
          startDate.isAtSameMomentAs(other.startDate) &&
          nextDueDate.isAtSameMomentAs(other.nextDueDate) &&
          originalAnchorDay == other.originalAnchorDay;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      priceMinorUnits.hashCode ^
      currencyCode.hashCode ^
      cycleType.hashCode ^
      customCycleDays.hashCode ^
      categoryId.hashCode ^
      status.hashCode;

  @override
  String toString() =>
      'SubscriptionModel(id: $id, name: "$name", price: $priceMinorUnits $currencyCode)';
}

import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

/// Central domain entity representing a subscription or recurring bill.
///
/// Encapsulates business rules, recurrence logic, lifecycle state, and reminder settings.
/// Strictly Pure Dart with zero dependencies on persistence or UI.
class Subscription {
  /// Unique identifier (UUID v4).
  final String id;

  /// Trimmed, normalized name (1 to 60 characters).
  final String name;

  /// Recurring cost stored strictly as integer minor units.
  final Money price;

  /// Recurrence cycle (monthly, yearly, weekly, custom).
  final BillingCycle cycle;

  /// Calculated due date with original calendar anchor preservation.
  final DueDate dueDate;

  /// Date when the subscription was initially started.
  final DateTime startDate;

  /// Associated category identifier.
  final String categoryId;

  /// Current lifecycle state (active, archived, inTrash).
  final SubscriptionStatus status;

  /// Whether this subscription is a free trial.
  final bool isTrial;

  /// Optional user notes (up to 500 characters).
  final String? notes;

  /// Optional website URL for managing or canceling the subscription.
  final String? renewalUrl;

  /// Optional payment method description (e.g., "Visa 4242", max 50 chars).
  final String? paymentMethodDesc;

  /// Whether local reminder notifications are enabled.
  final bool reminderEnabled;

  /// Number of days before the due date to trigger the reminder (0 to 30).
  final int reminderLeadDays;

  /// Reminder trigger hour (0 to 23).
  final int reminderTimeHour;

  /// Reminder trigger minute (0 to 59).
  final int reminderTimeMinute;

  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC timestamp of last modification.
  final DateTime updatedAt;

  /// UTC timestamp when moved to trash, or null if not deleted.
  final DateTime? deletedAt;

  /// UTC timestamp when archived, or null if not archived.
  final DateTime? archivedAt;

  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.cycle,
    required this.dueDate,
    required this.startDate,
    required this.categoryId,
    this.status = SubscriptionStatus.active,
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

  /// Factory constructor enforcing all business invariants (US-01, US-02, EC-01..EC-04).
  factory Subscription.create({
    required String id,
    required String name,
    required Money price,
    required BillingCycle cycle,
    required DueDate dueDate,
    required DateTime startDate,
    required String categoryId,
    SubscriptionStatus status = SubscriptionStatus.active,
    bool isTrial = false,
    String? notes,
    String? renewalUrl,
    String? paymentMethodDesc,
    bool reminderEnabled = true,
    int reminderLeadDays = 1,
    int reminderTimeHour = 9,
    int reminderTimeMinute = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? archivedAt,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Subscription name cannot be empty.');
    }
    if (trimmedName.length > 60) {
      throw const ValidationFailure(
        'Subscription name cannot exceed 60 characters.',
      );
    }

    // [EC-01-4]: Zero price is only allowed for free trials
    if (price.isZero && !isTrial) {
      throw const ValidationFailure(
        'Subscription price can only be zero for free trials.',
      );
    }

    if (notes != null && notes.length > 500) {
      throw const ValidationFailure('Notes cannot exceed 500 characters.');
    }

    if (paymentMethodDesc != null && paymentMethodDesc.length > 50) {
      throw const ValidationFailure(
        'Payment method description cannot exceed 50 characters.',
      );
    }

    if (reminderLeadDays < 0 || reminderLeadDays > 30) {
      throw const ValidationFailure(
        'Reminder lead days must be between 0 and 30 days.',
      );
    }

    if (reminderTimeHour < 0 || reminderTimeHour > 23) {
      throw const ValidationFailure(
        'Reminder time hour must be between 0 and 23.',
      );
    }

    if (reminderTimeMinute < 0 || reminderTimeMinute > 59) {
      throw const ValidationFailure(
        'Reminder time minute must be between 0 and 59.',
      );
    }

    final nowUtc = DateTime.now().toUtc();
    final created = (createdAt ?? nowUtc).toUtc();
    final updated = (updatedAt ?? created).toUtc();

    return Subscription(
      id: id,
      name: trimmedName,
      price: price,
      cycle: cycle,
      dueDate: dueDate,
      startDate: startDate.toUtc(),
      categoryId: categoryId,
      status: status,
      isTrial: isTrial,
      notes: notes?.trim(),
      renewalUrl: renewalUrl?.trim(),
      paymentMethodDesc: paymentMethodDesc?.trim(),
      reminderEnabled: reminderEnabled,
      reminderLeadDays: reminderLeadDays,
      reminderTimeHour: reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute,
      createdAt: created,
      updatedAt: updated,
      deletedAt: deletedAt?.toUtc(),
      archivedAt: archivedAt?.toUtc(),
    );
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isArchived => status == SubscriptionStatus.archived;
  bool get isInTrash => status == SubscriptionStatus.inTrash;

  /// Advances this subscription's due date to the next recurring cycle.
  Subscription markAsRenewed({DateTime? at}) {
    final nowUtc = (at ?? DateTime.now()).toUtc();
    final nextDue = dueDate.nextOccurrence(cycle);
    return copyWith(dueDate: nextDue, updatedAt: nowUtc);
  }

  /// Archives this subscription.
  Subscription archive({DateTime? at}) {
    final nowUtc = (at ?? DateTime.now()).toUtc();
    return copyWith(
      status: SubscriptionStatus.archived,
      archivedAt: nowUtc,
      updatedAt: nowUtc,
    );
  }

  /// Restores this subscription from archive to active status.
  Subscription unarchive({DateTime? at}) {
    final nowUtc = (at ?? DateTime.now()).toUtc();
    return Subscription(
      id: id,
      name: name,
      price: price,
      cycle: cycle,
      dueDate: dueDate,
      startDate: startDate,
      categoryId: categoryId,
      status: SubscriptionStatus.active,
      isTrial: isTrial,
      notes: notes,
      renewalUrl: renewalUrl,
      paymentMethodDesc: paymentMethodDesc,
      reminderEnabled: reminderEnabled,
      reminderLeadDays: reminderLeadDays,
      reminderTimeHour: reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute,
      createdAt: createdAt,
      updatedAt: nowUtc,
      deletedAt: deletedAt,
      archivedAt: null,
    );
  }

  /// Moves this subscription to the trash bin (soft-delete).
  Subscription moveToTrash({DateTime? at}) {
    final nowUtc = (at ?? DateTime.now()).toUtc();
    return copyWith(
      status: SubscriptionStatus.inTrash,
      deletedAt: nowUtc,
      updatedAt: nowUtc,
    );
  }

  /// Restores this subscription from the trash bin back to active status.
  Subscription restoreFromTrash({DateTime? at}) {
    final nowUtc = (at ?? DateTime.now()).toUtc();
    return Subscription(
      id: id,
      name: name,
      price: price,
      cycle: cycle,
      dueDate: dueDate,
      startDate: startDate,
      categoryId: categoryId,
      status: SubscriptionStatus.active,
      isTrial: isTrial,
      notes: notes,
      renewalUrl: renewalUrl,
      paymentMethodDesc: paymentMethodDesc,
      reminderEnabled: reminderEnabled,
      reminderLeadDays: reminderLeadDays,
      reminderTimeHour: reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute,
      createdAt: createdAt,
      updatedAt: nowUtc,
      deletedAt: null,
      archivedAt: archivedAt,
    );
  }

  Subscription copyWith({
    String? id,
    String? name,
    Money? price,
    BillingCycle? cycle,
    DueDate? dueDate,
    DateTime? startDate,
    String? categoryId,
    SubscriptionStatus? status,
    bool? isTrial,
    String? notes,
    String? renewalUrl,
    String? paymentMethodDesc,
    bool? reminderEnabled,
    int? reminderLeadDays,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? archivedAt,
    bool clearDeletedAt = false,
    bool clearArchivedAt = false,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name != null ? name.trim() : this.name,
      price: price ?? this.price,
      cycle: cycle ?? this.cycle,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      isTrial: isTrial ?? this.isTrial,
      notes: notes != null ? notes.trim() : this.notes,
      renewalUrl: renewalUrl != null ? renewalUrl.trim() : this.renewalUrl,
      paymentMethodDesc: paymentMethodDesc != null
          ? paymentMethodDesc.trim()
          : this.paymentMethodDesc,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          cycle == other.cycle &&
          dueDate == other.dueDate &&
          startDate.isAtSameMomentAs(other.startDate) &&
          categoryId == other.categoryId &&
          status == other.status &&
          isTrial == other.isTrial;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      cycle.hashCode ^
      dueDate.hashCode ^
      startDate.hashCode ^
      categoryId.hashCode ^
      status.hashCode ^
      isTrial.hashCode;

  @override
  String toString() =>
      'Subscription(id: $id, name: "$name", price: $price, cycle: $cycle, nextDue: $dueDate, status: ${status.name})';
}

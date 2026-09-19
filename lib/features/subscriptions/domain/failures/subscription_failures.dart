import '../../../../core/error/failures.dart';

/// Base sealed class for all subscription-domain-specific failures.
/// Pure Dart — zero external dependencies.
sealed class SubscriptionDomainFailure extends Failure {
  const SubscriptionDomainFailure(super.message);
}

/// Validation failure specifically related to subscription attributes.
class SubscriptionValidationFailure extends SubscriptionDomainFailure {
  final SubscriptionValidationReason reason;

  const SubscriptionValidationFailure(this.reason, String message)
    : super(message);

  factory SubscriptionValidationFailure.emptyName() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.emptyName,
        'Subscription name cannot be empty.',
      );

  factory SubscriptionValidationFailure.nameTooLong() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.nameTooLong,
        'Subscription name cannot exceed 60 characters.',
      );

  factory SubscriptionValidationFailure.negativePrice() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.negativePrice,
        'Subscription price cannot be negative.',
      );

  factory SubscriptionValidationFailure.zeroPriceNonTrial() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.zeroPriceNonTrial,
        'Subscription price cannot be zero unless it is marked as a free trial.',
      );

  factory SubscriptionValidationFailure.priceTooHigh() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.priceTooHigh,
        'Subscription price exceeds the maximum limit of 999,999,999.99.',
      );

  factory SubscriptionValidationFailure.invalidCurrencyCode() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.invalidCurrencyCode,
        'Currency code must be a 3-letter uppercase ISO 4217 code.',
      );

  factory SubscriptionValidationFailure.invalidCustomCycleDays() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.invalidCustomCycleDays,
        'Custom cycle days must be between 1 and 3650 days.',
      );

  factory SubscriptionValidationFailure.notesTooLong() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.notesTooLong,
        'Notes cannot exceed 500 characters.',
      );

  factory SubscriptionValidationFailure.creditCardDetected() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.creditCardDetected,
        'Payment method description cannot contain payment card numbers.',
      );

  factory SubscriptionValidationFailure.paymentMethodDescTooLong() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.paymentMethodDescTooLong,
        'Payment method description cannot exceed 50 characters.',
      );

  factory SubscriptionValidationFailure.invalidUrl() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.invalidUrl,
        'Renewal URL must be a valid http or https URL.',
      );

  factory SubscriptionValidationFailure.invalidReminderLeadDays() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.invalidReminderLeadDays,
        'Reminder lead days must be between 0 and 30.',
      );

  factory SubscriptionValidationFailure.invalidReminderTime() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.invalidReminderTime,
        'Reminder time must have an hour (0-23) and minute (0-59).',
      );

  factory SubscriptionValidationFailure.leadDaysExceedCycle() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.leadDaysExceedCycle,
        'Reminder lead days cannot exceed billing cycle duration.',
      );

  factory SubscriptionValidationFailure.invalidAnchorDay() =>
      const SubscriptionValidationFailure(
        SubscriptionValidationReason.invalidAnchorDay,
        'Anchor day must be between 1 and 31.',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionValidationFailure &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ reason.hashCode ^ message.hashCode;
}

/// Enumeration of fine-grained validation failure reasons.
enum SubscriptionValidationReason {
  emptyName,
  nameTooLong,
  negativePrice,
  zeroPriceNonTrial,
  priceTooHigh,
  invalidCurrencyCode,
  invalidCustomCycleDays,
  notesTooLong,
  creditCardDetected,
  paymentMethodDescTooLong,
  invalidUrl,
  invalidReminderLeadDays,
  invalidReminderTime,
  leadDaysExceedCycle,
  invalidAnchorDay,
}

/// Category validation failures.
class CategoryValidationFailure extends SubscriptionDomainFailure {
  final CategoryValidationReason reason;

  const CategoryValidationFailure(this.reason, String message) : super(message);

  factory CategoryValidationFailure.emptyName() =>
      const CategoryValidationFailure(
        CategoryValidationReason.emptyName,
        'Category name cannot be empty.',
      );

  factory CategoryValidationFailure.nameTooLong() =>
      const CategoryValidationFailure(
        CategoryValidationReason.nameTooLong,
        'Category name cannot exceed 24 characters.',
      );

  factory CategoryValidationFailure.cannotModifySystemCategory() =>
      const CategoryValidationFailure(
        CategoryValidationReason.cannotModifySystemCategory,
        'The system uncategorized category is protected and cannot be modified or deleted.',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryValidationFailure &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ reason.hashCode ^ message.hashCode;
}

enum CategoryValidationReason {
  emptyName,
  nameTooLong,
  cannotModifySystemCategory,
}

/// Recurrence and calendar calculation failures.
class RecurrenceCalculationFailure extends SubscriptionDomainFailure {
  final RecurrenceFailureReason reason;

  const RecurrenceCalculationFailure(this.reason, String message)
    : super(message);

  factory RecurrenceCalculationFailure.clockTampered() =>
      const RecurrenceCalculationFailure(
        RecurrenceFailureReason.clockTampered,
        'System clock anomaly detected: device time has jumped backwards.',
      );

  factory RecurrenceCalculationFailure.invalidAnchorDay() =>
      const RecurrenceCalculationFailure(
        RecurrenceFailureReason.invalidAnchorDay,
        'Calendar day anchor must be between 1 and 31.',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceCalculationFailure &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ reason.hashCode ^ message.hashCode;
}

enum RecurrenceFailureReason { clockTampered, invalidAnchorDay }

/// Duplicate subscription detection failure.
class DuplicateSubscriptionFailure extends SubscriptionDomainFailure {
  const DuplicateSubscriptionFailure([
    super.message =
        'An active subscription with identical name, cycle, and due date already exists.',
  ]);
}

/// Lifecycle state machine transition failure.
class SubscriptionStateTransitionFailure extends SubscriptionDomainFailure {
  final StateTransitionReason reason;

  const SubscriptionStateTransitionFailure(this.reason, String message)
    : super(message);

  factory SubscriptionStateTransitionFailure.alreadyArchived() =>
      const SubscriptionStateTransitionFailure(
        StateTransitionReason.alreadyArchived,
        'Subscription is already archived.',
      );

  factory SubscriptionStateTransitionFailure.alreadyInTrash() =>
      const SubscriptionStateTransitionFailure(
        StateTransitionReason.alreadyInTrash,
        'Subscription is already in trash.',
      );

  factory SubscriptionStateTransitionFailure.cannotRenewInactive() =>
      const SubscriptionStateTransitionFailure(
        StateTransitionReason.cannotRenewInactive,
        'Cannot renew an inactive (archived or trashed) subscription.',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStateTransitionFailure &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ reason.hashCode ^ message.hashCode;
}

enum StateTransitionReason {
  alreadyArchived,
  alreadyInTrash,
  cannotRenewInactive,
}

/// Entity lookup failure when subscription ID is not found.
class SubscriptionNotFoundFailure extends SubscriptionDomainFailure {
  final String id;
  const SubscriptionNotFoundFailure(this.id)
    : super('Subscription with id "$id" was not found.');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionNotFoundFailure &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ id.hashCode ^ message.hashCode;
}

/// Entity lookup failure when category ID is not found.
class CategoryNotFoundFailure extends SubscriptionDomainFailure {
  final String id;
  const CategoryNotFoundFailure(this.id)
    : super('Category with id "$id" was not found.');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryNotFoundFailure &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ id.hashCode ^ message.hashCode;
}

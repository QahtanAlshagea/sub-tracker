import 'package:sub_tracker/core/error/failures.dart';

/// Supported billing recurrence cycle types.
enum CycleType { monthly, yearly, weekly, custom }

/// Represents the recurring renewal cycle for a subscription.
/// Pure Dart Value Object with self-guarding invariants.
class BillingCycle {
  /// The recurrence type.
  final CycleType type;

  /// Custom recurrence interval in days. Only non-null when [type] is [CycleType.custom].
  final int? customDays;

  const BillingCycle._(this.type, [this.customDays]);

  /// Creates a monthly renewal cycle.
  const factory BillingCycle.monthly() = _MonthlyBillingCycle;

  /// Creates a yearly renewal cycle.
  const factory BillingCycle.yearly() = _YearlyBillingCycle;

  /// Creates a weekly renewal cycle.
  const factory BillingCycle.weekly() = _WeeklyBillingCycle;

  /// Creates a custom recurrence cycle defined by a specific number of days (1 to 3650).
  factory BillingCycle.custom(int days) {
    if (days < 1 || days > 3650) {
      throw const ValidationFailure(
        'Custom cycle days must be between 1 and 3650 days (approx. 10 years).',
      );
    }
    return BillingCycle._(CycleType.custom, days);
  }

  /// Parses a cycle type from a raw string identifier with optional custom days.
  factory BillingCycle.fromString(String rawType, [int? customDays]) {
    final normalized = rawType.trim().toLowerCase();
    switch (normalized) {
      case 'monthly':
        return const BillingCycle.monthly();
      case 'yearly':
        return const BillingCycle.yearly();
      case 'weekly':
        return const BillingCycle.weekly();
      case 'custom':
        if (customDays == null) {
          throw const ValidationFailure(
            'Custom cycle requires specifying customDays.',
          );
        }
        return BillingCycle.custom(customDays);
      default:
        throw ValidationFailure('Unknown cycle type: "$rawType".');
    }
  }

  bool get isMonthly => type == CycleType.monthly;
  bool get isYearly => type == CycleType.yearly;
  bool get isWeekly => type == CycleType.weekly;
  bool get isCustom => type == CycleType.custom;

  /// Approximate duration in days for recurrence and reminder estimates.
  int get approximateDays => switch (type) {
    CycleType.monthly => 30,
    CycleType.yearly => 365,
    CycleType.weekly => 7,
    CycleType.custom => customDays ?? 30,
  };

  /// Serialized name identifier suitable for database storage and JSON models.
  String get name => type.name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingCycle &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          customDays == other.customDays;

  @override
  int get hashCode => type.hashCode ^ customDays.hashCode;

  @override
  String toString() => isCustom
      ? 'BillingCycle.custom($customDays days)'
      : 'BillingCycle.${type.name}';
}

class _MonthlyBillingCycle extends BillingCycle {
  const _MonthlyBillingCycle() : super._(CycleType.monthly);
}

class _YearlyBillingCycle extends BillingCycle {
  const _YearlyBillingCycle() : super._(CycleType.yearly);
}

class _WeeklyBillingCycle extends BillingCycle {
  const _WeeklyBillingCycle() : super._(CycleType.weekly);
}

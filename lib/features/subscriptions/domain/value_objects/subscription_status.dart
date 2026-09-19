import 'package:sub_tracker/core/error/failures.dart';

/// Represents the lifecycle state of a subscription in Sub Tracker.
enum SubscriptionStatus {
  /// Active and regularly billed subscription. Included in upcoming dues and analytics.
  active,

  /// Temporarily or permanently archived subscription. Excluded from active dues.
  archived,

  /// In the soft-delete trash bin. Eligible for restore or permanent purge.
  inTrash;

  bool get isActive => this == SubscriptionStatus.active;
  bool get isArchived => this == SubscriptionStatus.archived;
  bool get isInTrash => this == SubscriptionStatus.inTrash;

  /// Parses a status from its string identifier.
  static SubscriptionStatus fromString(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'archived':
        return SubscriptionStatus.archived;
      case 'in_trash':
      case 'intrash':
        return SubscriptionStatus.inTrash;
      default:
        throw ValidationFailure('Unknown subscription status: "$raw".');
    }
  }
}

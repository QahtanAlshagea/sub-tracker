import '../../../../core/localization/app_localizations.dart';
import '../../domain/value_objects/billing_cycle.dart';

/// Presentation formatter for dates, remaining days countdowns, and billing cycles.
///
/// Ensures full localization and consistent date displays across the application.
class DateFormatter {
  DateFormatter._();

  /// Formats a [DateTime] to standard `YYYY-MM-DD` representation.
  static String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Formats the days remaining until next renewal.
  ///
  /// - Positive: `daysRemaining(days)` (e.g., "باقٍ 5 يوم" or "5 days left")
  /// - Zero: `dueToday` (e.g., "يستحق اليوم" or "Due today")
  /// - Negative: `daysOverdue(days)` (e.g., "متأخر 3 يوم" or "3 days overdue")
  static String formatRemainingDays(int daysRemaining, AppLocalizations l10n) {
    if (daysRemaining > 0) {
      return l10n.daysRemaining(daysRemaining);
    } else if (daysRemaining == 0) {
      return l10n.dueToday;
    } else {
      return l10n.daysOverdue(daysRemaining.abs());
    }
  }

  /// Formats a [BillingCycle] into its localized description.
  static String formatCycle(BillingCycle cycle, AppLocalizations l10n) {
    return switch (cycle.type) {
      CycleType.monthly => l10n.monthly,
      CycleType.yearly => l10n.yearly,
      CycleType.weekly => l10n.weekly,
      CycleType.custom => l10n.customCycle,
    };
  }
}

import '../../domain/entities/subscription.dart';
import '../../domain/value_objects/billing_cycle.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/subscription_status.dart';

/// Value object representing aggregated expense and commitment analytics.
///
/// Encapsulates calculation of monthly and yearly equivalent totals (US-15, BR-07)
/// and handles multi-currency separation (EC-15-1).
class ExpenseSummary {
  /// Aggregated monthly equivalent total per currency code.
  final Map<String, Money> monthlyTotalsByCurrency;

  /// Aggregated yearly equivalent total per currency code.
  final Map<String, Money> yearlyTotalsByCurrency;

  /// Count of currently active subscriptions.
  final int activeCount;

  /// Count of active subscriptions in free trial.
  final int trialCount;

  /// Count of subscriptions due within the next 7 days.
  final int upcomingCount;

  /// The primary currency code for prominent dashboard display.
  final String primaryCurrency;

  const ExpenseSummary({
    required this.monthlyTotalsByCurrency,
    required this.yearlyTotalsByCurrency,
    required this.activeCount,
    required this.trialCount,
    required this.upcomingCount,
    this.primaryCurrency = 'USD',
  });

  /// Factory creating an empty/zero expense summary.
  factory ExpenseSummary.zero([String primaryCurrency = 'USD']) {
    return ExpenseSummary(
      monthlyTotalsByCurrency: {primaryCurrency: Money.zero(primaryCurrency)},
      yearlyTotalsByCurrency: {primaryCurrency: Money.zero(primaryCurrency)},
      activeCount: 0,
      trialCount: 0,
      upcomingCount: 0,
      primaryCurrency: primaryCurrency,
    );
  }

  /// Calculates aggregated summary from a list of subscriptions.
  ///
  /// Strictly adheres to BR-07:
  /// - Monthly cycle: full amount.
  /// - Yearly cycle: amount / 12.
  /// - Weekly cycle: (amount * 52) / 12.
  /// - Custom cycle: (amount * 30.4375) / customDays.
  factory ExpenseSummary.fromSubscriptions(
    List<Subscription> subscriptions, {
    String defaultCurrency = 'USD',
    DateTime? referenceDate,
  }) {
    final now = (referenceDate ?? DateTime.now()).toUtc();
    final sevenDaysLater = now.add(const Duration(days: 7));

    final monthlyMinors = <String, int>{};
    final yearlyMinors = <String, int>{};

    int active = 0;
    int trials = 0;
    int upcoming = 0;

    for (final sub in subscriptions) {
      if (sub.status != SubscriptionStatus.active) continue;

      active++;
      if (sub.isTrial) trials++;

      if (sub.dueDate.date.isAfter(now.subtract(const Duration(days: 1))) &&
          sub.dueDate.date.isBefore(sevenDaysLater)) {
        upcoming++;
      }

      final currency = sub.price.currencyCode;
      final minor = sub.price.amountMinorUnits;

      // Calculate monthly equivalent minor units
      final int monthlyMinor = switch (sub.cycle.type) {
        CycleType.monthly => minor,
        CycleType.yearly => (minor / 12.0).round(),
        CycleType.weekly => ((minor * 52.0) / 12.0).round(),
        CycleType.custom =>
          ((minor * 30.4375) / (sub.cycle.customDays ?? 30)).round(),
      };

      // Calculate yearly equivalent minor units
      final int yearlyMinor = switch (sub.cycle.type) {
        CycleType.yearly => minor,
        CycleType.monthly => minor * 12,
        CycleType.weekly => minor * 52,
        CycleType.custom =>
          ((minor * 365.25) / (sub.cycle.customDays ?? 30)).round(),
      };

      monthlyMinors[currency] = (monthlyMinors[currency] ?? 0) + monthlyMinor;
      yearlyMinors[currency] = (yearlyMinors[currency] ?? 0) + yearlyMinor;
    }

    final currencyKeys = monthlyMinors.keys.toList();
    final primaryCurr = currencyKeys.isNotEmpty
        ? currencyKeys.first
        : defaultCurrency;

    final monthlyMap = <String, Money>{};
    for (final entry in monthlyMinors.entries) {
      monthlyMap[entry.key] = Money(
        amountMinorUnits: entry.value,
        currencyCode: entry.key,
      );
    }
    if (monthlyMap.isEmpty) {
      monthlyMap[primaryCurr] = Money.zero(primaryCurr);
    }

    final yearlyMap = <String, Money>{};
    for (final entry in yearlyMinors.entries) {
      yearlyMap[entry.key] = Money(
        amountMinorUnits: entry.value,
        currencyCode: entry.key,
      );
    }
    if (yearlyMap.isEmpty) {
      yearlyMap[primaryCurr] = Money.zero(primaryCurr);
    }

    return ExpenseSummary(
      monthlyTotalsByCurrency: monthlyMap,
      yearlyTotalsByCurrency: yearlyMap,
      activeCount: active,
      trialCount: trials,
      upcomingCount: upcoming,
      primaryCurrency: primaryCurr,
    );
  }

  /// Primary monthly equivalent money object.
  Money get primaryMonthlyTotal =>
      monthlyTotalsByCurrency[primaryCurrency] ?? Money.zero(primaryCurrency);

  /// Primary yearly equivalent money object.
  Money get primaryYearlyTotal =>
      yearlyTotalsByCurrency[primaryCurrency] ?? Money.zero(primaryCurrency);

  /// Whether subscriptions span across more than one currency (EC-15-1).
  bool get hasMultipleCurrencies => monthlyTotalsByCurrency.length > 1;

  /// Whether there are zero active subscriptions.
  bool get isEmpty => activeCount == 0;
}

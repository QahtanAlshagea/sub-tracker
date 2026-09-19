import '../entities/category.dart';
import '../entities/category_distribution_item.dart';
import '../entities/highest_cost_subscription_result.dart';
import '../entities/month_comparison_result.dart';
import '../entities/monthly_summary.dart';
import '../entities/payment_occurrence.dart';
import '../entities/subscription.dart';
import '../entities/upcoming_projection.dart';
import '../validators/recurrence_calculator.dart';
import '../value_objects/billing_cycle.dart';
import '../value_objects/due_date.dart';
import '../value_objects/money.dart';

/// Pure domain calculation and analytics engine.
///
/// Implements FR-06, FR-07, BR-07, BR-08, BR-10, US-15..20, and all associated edge cases.
/// Strictly Pure Dart — 100% side-effect free, deterministic, and free of UI/database dependencies.
class FinancialCalculator {
  const FinancialCalculator._();

  /// Computes the normalized monthly equivalent cost for any recurring billing cycle (BR-07).
  ///
  /// Coefficients:
  /// - Monthly: 1.0 (exact price).
  /// - Yearly: Price / 12 (half-up rounded to minor units).
  /// - Weekly: Price * 4.348 (half-up rounded to minor units).
  /// - Custom: Price * (30.44 / days) (half-up rounded to minor units).
  static Money computeMonthlyEquivalent(Money price, BillingCycle cycle) {
    int minorUnits;
    switch (cycle.type) {
      case CycleType.monthly:
        minorUnits = price.amountMinorUnits;
        break;
      case CycleType.yearly:
        minorUnits = (price.amountMinorUnits / 12.0).round();
        break;
      case CycleType.weekly:
        minorUnits = (price.amountMinorUnits * 4.348).round();
        break;
      case CycleType.custom:
        final days = cycle.customDays ?? 30;
        if (days <= 0) {
          minorUnits = price.amountMinorUnits;
        } else {
          minorUnits = (price.amountMinorUnits * (30.44 / days)).round();
        }
        break;
    }

    return Money(
      amountMinorUnits: minorUnits,
      currencyCode: price.currencyCode,
    );
  }

  /// Computes the normalized annual equivalent derived from the monthly equivalent (BR-07, SRS §3.1).
  ///
  /// Guaranteed to be exactly 12 times the monthly equivalent in integer minor units.
  static Money computeAnnualEquivalent(Money price, BillingCycle cycle) {
    final monthly = computeMonthlyEquivalent(price, cycle);
    return Money(
      amountMinorUnits: monthly.amountMinorUnits * 12,
      currencyCode: price.currencyCode,
    );
  }

  /// Calculates monthly and annual summaries grouped strictly by currency (FR-06, BR-08, BR-10, US-15).
  ///
  /// Archived and trashed subscriptions are completely excluded (BR-10).
  /// Currencies are never mixed or aggregated together (BR-08, EC-15-1).
  static Map<String, MonthlySummary> calculateMonthlySummaries(
    Iterable<Subscription> subscriptions,
  ) {
    final activeSubs = subscriptions.where((s) => s.status.isActive);
    final grouped = <String, List<Subscription>>{};

    for (final sub in activeSubs) {
      grouped.putIfAbsent(sub.price.currencyCode, () => []).add(sub);
    }

    final summaries = <String, MonthlySummary>{};
    for (final entry in grouped.entries) {
      final currency = entry.key;
      final subs = entry.value;

      int totalMonthlyUnits = 0;
      for (final s in subs) {
        totalMonthlyUnits += computeMonthlyEquivalent(
          s.price,
          s.cycle,
        ).amountMinorUnits;
      }

      final count = subs.length;
      final avgUnits = count > 0 ? (totalMonthlyUnits / count).round() : 0;

      summaries[currency] = MonthlySummary(
        currencyCode: currency,
        totalMonthlyEquivalent: Money(
          amountMinorUnits: totalMonthlyUnits,
          currencyCode: currency,
        ),
        totalAnnualEquivalent: Money(
          amountMinorUnits: totalMonthlyUnits * 12,
          currencyCode: currency,
        ),
        averageMonthlyCost: Money(
          amountMinorUnits: avgUnits,
          currencyCode: currency,
        ),
        activeSubscriptionsCount: count,
      );
    }

    return summaries;
  }

  /// Generates all scheduled payment occurrences for a single subscription within a closed range [rangeStart, rangeEnd].
  static List<PaymentOccurrence> generateOccurrencesInRange({
    required Subscription subscription,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    DateTime? referenceDate,
  }) {
    if (!subscription.status.isActive) return const [];
    if (subscription.startDate.isAfter(rangeEnd)) return const [];

    final occurrences = <PaymentOccurrence>[];
    final ref = referenceDate ?? DateTime.now().toUtc();
    final refDayUtc = DateTime.utc(ref.year, ref.month, ref.day);

    // Jump directly to the first scheduled occurrence on or after rangeStart
    final firstDue = RecurrenceCalculator.computeNextDueDate(
      startDate: subscription.startDate,
      originalAnchorDay: subscription.originalAnchorDay,
      cycle: subscription.cycle,
      referenceDate: rangeStart,
    );

    var current = firstDue.dateTime;
    if (current.isBefore(subscription.startDate)) {
      current = subscription.startDate;
    }

    const maxOccurrencesLimit = 500;
    int safetyCounter = 0;

    while (!current.isAfter(rangeEnd) && safetyCounter < maxOccurrencesLimit) {
      safetyCounter++;
      if (!current.isBefore(rangeStart)) {
        final isOverdue = current.isBefore(refDayUtc);
        occurrences.add(
          PaymentOccurrence(
            subscriptionId: subscription.id,
            subscriptionName: subscription.name,
            dueDate: current,
            price: subscription.price,
            isOverdue: isOverdue,
          ),
        );
      }

      // Advance to the next occurrence according to cycle type
      switch (subscription.cycle.type) {
        case CycleType.weekly:
          current = current.add(const Duration(days: 7));
          break;
        case CycleType.custom:
          final days =
              (subscription.cycle.customDays != null &&
                  subscription.cycle.customDays! > 0)
              ? subscription.cycle.customDays!
              : 30;
          current = current.add(Duration(days: days));
          break;
        case CycleType.monthly:
        case CycleType.yearly:
          final nextRef = current.add(const Duration(days: 1));
          final nextDue = RecurrenceCalculator.computeNextDueDate(
            startDate: subscription.startDate,
            originalAnchorDay: subscription.originalAnchorDay,
            cycle: subscription.cycle,
            referenceDate: nextRef,
          );
          current = nextDue.dateTime;
          break;
      }
    }

    return occurrences;
  }

  /// Calculates actual scheduled payments falling within the current calendar month (FR-06, US-16, EC-16-1..4).
  ///
  /// Sums actual payment occurrences rather than fixed averages. Weekly subscriptions falling
  /// 4 or 5 times in the month are counted 4 or 5 times accordingly (EC-16-1).
  /// Due dates on the last day of the month are included inside the month (EC-16-2).
  static UpcomingProjection calculateCalendarMonthProjection(
    Iterable<Subscription> subscriptions, {
    required String currencyCode,
    required DateTime referenceDate,
  }) {
    final refUtc = referenceDate.toUtc();
    final year = refUtc.year;
    final month = refUtc.month;
    final daysInMonth = DueDate.daysInMonth(year, month);

    final monthStart = DateTime.utc(year, month, 1, 0, 0, 0);
    final monthEnd = DateTime.utc(year, month, daysInMonth, 23, 59, 59, 999);

    final activeSubs = subscriptions.where(
      (s) => s.status.isActive && s.price.currencyCode == currencyCode,
    );

    final allOccurrences = <PaymentOccurrence>[];
    for (final sub in activeSubs) {
      allOccurrences.addAll(
        generateOccurrencesInRange(
          subscription: sub,
          rangeStart: monthStart,
          rangeEnd: monthEnd,
          referenceDate: refUtc,
        ),
      );
    }

    allOccurrences.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    int totalUnits = 0;
    int overdueUnits = 0;
    int upcomingUnits = 0;

    for (final occ in allOccurrences) {
      totalUnits += occ.price.amountMinorUnits;
      if (occ.isOverdue) {
        overdueUnits += occ.price.amountMinorUnits;
      } else {
        upcomingUnits += occ.price.amountMinorUnits;
      }
    }

    return UpcomingProjection(
      currencyCode: currencyCode,
      windowStart: monthStart,
      windowEnd: monthEnd,
      totalProjected: Money(
        amountMinorUnits: totalUnits,
        currencyCode: currencyCode,
      ),
      overdueAmount: Money(
        amountMinorUnits: overdueUnits,
        currencyCode: currencyCode,
      ),
      upcomingAmount: Money(
        amountMinorUnits: upcomingUnits,
        currencyCode: currencyCode,
      ),
      occurrences: allOccurrences,
      isCalendarMonth: true,
    );
  }

  /// Calculates upcoming commitments over a rolling 30-day window starting today (FR-06, US-17, EC-17-1..3).
  ///
  /// Window: [referenceDate 00:00:00 UTC, referenceDate + 29 days 23:59:59 UTC].
  /// Exactly 30 calendar days (Day 0 through Day 29). Daily subscriptions yield exactly 30 occurrences (EC-17-1).
  /// Any commitment due at Day 30 or later is excluded (US-17, EC-17-2).
  static UpcomingProjection calculateRolling30DaysProjection(
    Iterable<Subscription> subscriptions, {
    required String currencyCode,
    required DateTime referenceDate,
  }) {
    final refUtc = referenceDate.toUtc();
    final windowStart = DateTime.utc(
      refUtc.year,
      refUtc.month,
      refUtc.day,
      0,
      0,
      0,
    );
    // 30 days window: Day 0 to Day 29 inclusive
    final windowEnd = DateTime.utc(
      windowStart.year,
      windowStart.month,
      windowStart.day + 29,
      23,
      59,
      59,
      999,
    );

    final activeSubs = subscriptions.where(
      (s) => s.status.isActive && s.price.currencyCode == currencyCode,
    );

    final allOccurrences = <PaymentOccurrence>[];
    for (final sub in activeSubs) {
      allOccurrences.addAll(
        generateOccurrencesInRange(
          subscription: sub,
          rangeStart: windowStart,
          rangeEnd: windowEnd,
          referenceDate: refUtc,
        ),
      );
    }

    allOccurrences.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    int totalUnits = 0;
    int overdueUnits = 0;
    int upcomingUnits = 0;

    for (final occ in allOccurrences) {
      totalUnits += occ.price.amountMinorUnits;
      if (occ.isOverdue) {
        overdueUnits += occ.price.amountMinorUnits;
      } else {
        upcomingUnits += occ.price.amountMinorUnits;
      }
    }

    return UpcomingProjection(
      currencyCode: currencyCode,
      windowStart: windowStart,
      windowEnd: windowEnd,
      totalProjected: Money(
        amountMinorUnits: totalUnits,
        currencyCode: currencyCode,
      ),
      overdueAmount: Money(
        amountMinorUnits: overdueUnits,
        currencyCode: currencyCode,
      ),
      upcomingAmount: Money(
        amountMinorUnits: upcomingUnits,
        currencyCode: currencyCode,
      ),
      occurrences: allOccurrences,
      isCalendarMonth: false,
    );
  }

  /// Identifies the subscription with the highest monthly equivalent cost in a currency (FR-06, US-18, EC-18-1..3).
  ///
  /// In case of a tie in cost, the older subscription (earlier createdAt) is prioritized (EC-18-1).
  /// If only one subscription exists, it reports 100% share with isSingleSubscription=true (EC-18-2).
  /// If zero subscriptions exist, returns null (EC-18-3).
  static HighestCostSubscriptionResult? findHighestCostSubscription(
    Iterable<Subscription> subscriptions, {
    required String currencyCode,
  }) {
    final activeSubs = subscriptions
        .where((s) => s.status.isActive && s.price.currencyCode == currencyCode)
        .toList();

    if (activeSubs.isEmpty) return null;

    final subEquivalents = activeSubs.map((s) {
      return (
        subscription: s,
        monthlyEquivalent: computeMonthlyEquivalent(s.price, s.cycle),
      );
    }).toList();

    int totalMonthlyUnits = 0;
    for (final item in subEquivalents) {
      totalMonthlyUnits += item.monthlyEquivalent.amountMinorUnits;
    }

    // Sort: 1) monthly equivalent descending, 2) createdAt ascending (older first), 3) id ascending
    subEquivalents.sort((a, b) {
      final costCmp = b.monthlyEquivalent.amountMinorUnits.compareTo(
        a.monthlyEquivalent.amountMinorUnits,
      );
      if (costCmp != 0) return costCmp;
      final dateCmp = a.subscription.createdAt.compareTo(
        b.subscription.createdAt,
      );
      if (dateCmp != 0) return dateCmp;
      return a.subscription.id.compareTo(b.subscription.id);
    });

    final highest = subEquivalents.first;
    final isSingle = subEquivalents.length == 1;
    final hasTie =
        subEquivalents.length > 1 &&
        subEquivalents[1].monthlyEquivalent.amountMinorUnits ==
            highest.monthlyEquivalent.amountMinorUnits;

    final double percentage = isSingle
        ? 100.0
        : (totalMonthlyUnits > 0
              ? (highest.monthlyEquivalent.amountMinorUnits /
                        totalMonthlyUnits) *
                    100.0
              : 0.0);

    return HighestCostSubscriptionResult(
      subscription: highest.subscription,
      monthlyEquivalent: highest.monthlyEquivalent,
      percentageOfTotal: percentage,
      hasTie: hasTie,
      isSingleSubscription: isSingle,
    );
  }

  /// Calculates spending distribution across categories for a given currency (FR-07, US-19, EC-19-1..3).
  ///
  /// Subscriptions without a valid category are mapped to the protected «غير مصنّف» category (EC-19-1..3).
  /// Categories with small shares (<1%) are preserved without truncation (EC-19-2).
  /// Empty list returns empty result with isEmpty=true (EC-19-3).
  static CategoryDistributionResult calculateCategoryDistribution(
    Iterable<Subscription> subscriptions, {
    required String currencyCode,
    required Iterable<Category> categories,
  }) {
    final activeSubs = subscriptions
        .where((s) => s.status.isActive && s.price.currencyCode == currencyCode)
        .toList();

    if (activeSubs.isEmpty) {
      return CategoryDistributionResult.empty(currencyCode);
    }

    final categoryMap = {for (final c in categories) c.id: c};
    final uncategorizedSystem = Category.systemUncategorized();

    final groupedSubs = <String, List<Subscription>>{};
    for (final sub in activeSubs) {
      final targetCatId = categoryMap.containsKey(sub.categoryId)
          ? sub.categoryId
          : uncategorizedSystem.id;
      groupedSubs.putIfAbsent(targetCatId, () => []).add(sub);
    }

    int grandTotalUnits = 0;
    final categoryTotals = <String, int>{};

    for (final entry in groupedSubs.entries) {
      int catUnits = 0;
      for (final s in entry.value) {
        catUnits += computeMonthlyEquivalent(s.price, s.cycle).amountMinorUnits;
      }
      categoryTotals[entry.key] = catUnits;
      grandTotalUnits += catUnits;
    }

    final items = <CategoryDistributionItem>[];
    for (final entry in groupedSubs.entries) {
      final catId = entry.key;
      final subs = entry.value;
      final catUnits = categoryTotals[catId] ?? 0;
      final category = categoryMap[catId] ?? uncategorizedSystem;

      final double percentage = grandTotalUnits > 0
          ? (catUnits / grandTotalUnits) * 100.0
          : 0.0;

      items.add(
        CategoryDistributionItem(
          categoryId: category.id,
          categoryName: category.name,
          colorValue: category.colorValue,
          iconCode: category.iconCode,
          totalMonthlyEquivalent: Money(
            amountMinorUnits: catUnits,
            currencyCode: currencyCode,
          ),
          percentage: percentage,
          subscriptionsCount: subs.length,
          isUncategorized:
              category.isSystem || category.id == uncategorizedSystem.id,
        ),
      );
    }

    // Sort descending by totalMonthlyEquivalent
    items.sort(
      (a, b) => b.totalMonthlyEquivalent.amountMinorUnits.compareTo(
        a.totalMonthlyEquivalent.amountMinorUnits,
      ),
    );

    return CategoryDistributionResult(
      currencyCode: currencyCode,
      totalMonthlyEquivalent: Money(
        amountMinorUnits: grandTotalUnits,
        currencyCode: currencyCode,
      ),
      items: items,
    );
  }

  /// Compares current calendar month spending against the previous calendar month (FR-07, US-20, EC-20-1..3).
  ///
  /// Zero previous month spending reports SpendTrend.noPreviousData with null percentage (prevents division by zero, EC-20-2).
  /// Identical spending reports SpendTrend.unchanged (EC-20-3).
  static MonthComparisonResult compareMonthOverMonth(
    Iterable<Subscription> subscriptions, {
    required String currencyCode,
    required DateTime referenceDate,
  }) {
    final refUtc = referenceDate.toUtc();
    final currentMonthAnchor = DateTime.utc(refUtc.year, refUtc.month, 1);

    final prevYear = refUtc.month == 1 ? refUtc.year - 1 : refUtc.year;
    final prevMonth = refUtc.month == 1 ? 12 : refUtc.month - 1;
    final previousMonthAnchor = DateTime.utc(prevYear, prevMonth, 1);

    final currentProjection = calculateCalendarMonthProjection(
      subscriptions,
      currencyCode: currencyCode,
      referenceDate: currentMonthAnchor,
    );

    final previousProjection = calculateCalendarMonthProjection(
      subscriptions,
      currencyCode: currencyCode,
      referenceDate: previousMonthAnchor,
    );

    final currentTotal = currentProjection.totalProjected;
    final previousTotal = previousProjection.totalProjected;

    final signedDiff =
        currentTotal.amountMinorUnits - previousTotal.amountMinorUnits;
    final differenceAmount = Money(
      amountMinorUnits: signedDiff.abs(),
      currencyCode: currencyCode,
    );

    SpendTrend trend;
    double? percentageChange;

    if (previousTotal.amountMinorUnits == 0) {
      if (currentTotal.amountMinorUnits == 0) {
        trend = SpendTrend.unchanged;
        percentageChange = 0.0;
      } else {
        trend = SpendTrend.noPreviousData;
        percentageChange = null;
      }
    } else {
      if (signedDiff == 0) {
        trend = SpendTrend.unchanged;
        percentageChange = 0.0;
      } else if (signedDiff > 0) {
        trend = SpendTrend.increasing;
        percentageChange =
            (signedDiff / previousTotal.amountMinorUnits) * 100.0;
      } else {
        trend = SpendTrend.decreasing;
        percentageChange =
            (signedDiff / previousTotal.amountMinorUnits) * 100.0;
      }
    }

    return MonthComparisonResult(
      currencyCode: currencyCode,
      currentMonth: currentMonthAnchor,
      previousMonth: previousMonthAnchor,
      currentMonthTotal: currentTotal,
      previousMonthTotal: previousTotal,
      differenceAmount: differenceAmount,
      signedDifferenceMinorUnits: signedDiff,
      percentageChange: percentageChange,
      trend: trend,
    );
  }
}

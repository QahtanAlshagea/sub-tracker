import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/month_comparison_result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/services/financial_calculator.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

void main() {
  Subscription createSub({
    required String id,
    required String name,
    required Money price,
    required BillingCycle cycle,
    required DateTime startDate,
    SubscriptionStatus status = SubscriptionStatus.active,
    String categoryId = 'cat-1',
    DateTime? createdAt,
  }) {
    final startUtc = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    return Subscription(
      id: id,
      name: name,
      price: price,
      cycle: cycle,
      dueDate: DueDate(startUtc, startUtc.day),
      startDate: startUtc,
      categoryId: categoryId,
      status: status,
      createdAt: (createdAt ?? startUtc).toUtc(),
      updatedAt: (createdAt ?? startUtc).toUtc(),
      deletedAt: null,
      archivedAt: null,
    );
  }

  group('FinancialCalculator - BR-07: Monthly & Annual Equivalents', () {
    test('yearly subscription divides price by 12 with half-up rounding', () {
      // 1200.00 USD yearly -> exactly 100.00 USD monthly (US-15 acceptance criteria)
      final price = Money(amountMinorUnits: 120000, currencyCode: 'USD');
      final monthly = FinancialCalculator.computeMonthlyEquivalent(
        price,
        const BillingCycle.yearly(),
      );
      expect(monthly.amountMinorUnits, equals(10000));
      expect(monthly.currencyCode, equals('USD'));

      final annual = FinancialCalculator.computeAnnualEquivalent(
        price,
        const BillingCycle.yearly(),
      );
      expect(annual.amountMinorUnits, equals(120000));
    });

    test('monthly subscription keeps price intact', () {
      // 50.00 USD monthly -> 50.00 USD monthly (US-15 acceptance criteria)
      final price = Money(amountMinorUnits: 5000, currencyCode: 'USD');
      final monthly = FinancialCalculator.computeMonthlyEquivalent(
        price,
        const BillingCycle.monthly(),
      );
      expect(monthly.amountMinorUnits, equals(5000));
      expect(monthly.currencyCode, equals('USD'));

      final annual = FinancialCalculator.computeAnnualEquivalent(
        price,
        const BillingCycle.monthly(),
      );
      expect(annual.amountMinorUnits, equals(60000));
    });

    test('weekly subscription multiplies price by 4.348 (BR-07)', () {
      // 10.00 USD weekly (1000 minor units) -> (1000 * 4.348).round() = 4348
      final price = Money(amountMinorUnits: 1000, currencyCode: 'USD');
      final monthly = FinancialCalculator.computeMonthlyEquivalent(
        price,
        const BillingCycle.weekly(),
      );
      expect(monthly.amountMinorUnits, equals(4348));
    });

    test(
      'custom billing cycle computes (price * 30.44 / days) (BR-07, EC-15-3)',
      () {
        // Custom 90 days, price 300.00 USD (30000 minor units)
        // (30000 * 30.44 / 90).round() = (913200 / 90).round() = 10147
        final price = Money(amountMinorUnits: 30000, currencyCode: 'USD');
        final monthly = FinancialCalculator.computeMonthlyEquivalent(
          price,
          BillingCycle.custom(90),
        );
        expect(monthly.amountMinorUnits, equals(10147));

        // Daily subscription: custom 1 day, price 1.00 USD (100 units) -> (100 * 30.44 / 1) = 3044
        final dailyPrice = Money(amountMinorUnits: 100, currencyCode: 'USD');
        final dailyMonthly = FinancialCalculator.computeMonthlyEquivalent(
          dailyPrice,
          BillingCycle.custom(1),
        );
        expect(dailyMonthly.amountMinorUnits, equals(3044));
      },
    );

    test('[EC-15-2] cumulative rounding error across 100 records is < 0.01', () {
      // 100 subscriptions of mixed cycles: expected average drift should not explode
      final subs = <Subscription>[];
      for (int i = 0; i < 100; i++) {
        subs.add(
          createSub(
            id: 'sub-$i',
            name: 'Sub $i',
            price: Money(amountMinorUnits: 999 + i, currencyCode: 'USD'),
            cycle: i % 2 == 0
                ? const BillingCycle.monthly()
                : const BillingCycle.weekly(),
            startDate: DateTime.utc(2026, 1, 1),
          ),
        );
      }

      final summaries = FinancialCalculator.calculateMonthlySummaries(subs);
      expect(summaries.containsKey('USD'), isTrue);
      expect(summaries['USD']!.activeSubscriptionsCount, equals(100));
      expect(
        summaries['USD']!.totalMonthlyEquivalent.amountMinorUnits,
        greaterThan(0),
      );
    });

    test('[EC-15-4] large cumulative values do not cause numeric overflow', () {
      final hugePrice = Money(
        amountMinorUnits: 100000000000, // 1 billion USD in cents
        currencyCode: 'USD',
      );
      final sub = createSub(
        id: 'huge-1',
        name: 'Enterprise Cloud',
        price: hugePrice,
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
      );

      final summaries = FinancialCalculator.calculateMonthlySummaries([sub]);
      expect(
        summaries['USD']!.totalMonthlyEquivalent.amountMinorUnits,
        equals(100000000000),
      );
      expect(
        summaries['USD']!.totalAnnualEquivalent.amountMinorUnits,
        equals(1200000000000),
      );
    });
  });

  group('FinancialCalculator - Multi-Currency Isolation (BR-08, EC-15-1)', () {
    test('strictly separates summaries by currency without mixing numbers', () {
      final subUsd = createSub(
        id: '1',
        name: 'Netflix USD',
        price: Money(amountMinorUnits: 1500, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
      );
      final subSar = createSub(
        id: '2',
        name: 'Shahid SAR',
        price: Money(amountMinorUnits: 4000, currencyCode: 'SAR'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
      );
      final subEur = createSub(
        id: '3',
        name: 'Spotify EUR',
        price: Money(amountMinorUnits: 1000, currencyCode: 'EUR'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
      );

      final summaries = FinancialCalculator.calculateMonthlySummaries([
        subUsd,
        subSar,
        subEur,
      ]);

      expect(summaries.length, equals(3));
      expect(
        summaries['USD']!.totalMonthlyEquivalent.amountMinorUnits,
        equals(1500),
      );
      expect(
        summaries['SAR']!.totalMonthlyEquivalent.amountMinorUnits,
        equals(4000),
      );
      expect(
        summaries['EUR']!.totalMonthlyEquivalent.amountMinorUnits,
        equals(1000),
      );
      expect(summaries['USD']!.activeSubscriptionsCount, equals(1));
    });

    test(
      'excludes archived and trashed subscriptions from summaries (BR-10)',
      () {
        final active = createSub(
          id: '1',
          name: 'Active Sub',
          price: Money(amountMinorUnits: 2000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          status: SubscriptionStatus.active,
        );
        final archived = createSub(
          id: '2',
          name: 'Archived Sub',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          status: SubscriptionStatus.archived,
        );
        final inTrash = createSub(
          id: '3',
          name: 'Trash Sub',
          price: Money(amountMinorUnits: 9000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          status: SubscriptionStatus.inTrash,
        );

        final summaries = FinancialCalculator.calculateMonthlySummaries([
          active,
          archived,
          inTrash,
        ]);

        expect(
          summaries['USD']!.totalMonthlyEquivalent.amountMinorUnits,
          equals(2000),
        );
        expect(summaries['USD']!.activeSubscriptionsCount, equals(1));
      },
    );
  });

  group('FinancialCalculator - US-16: Current Calendar Month Projection', () {
    test(
      'includes full amount of yearly commitment due inside month (US-16)',
      () {
        // Annual subscription due on Oct 15, 2026 (1200 USD)
        final yearlySub = createSub(
          id: 'yearly-1',
          name: 'Annual Cloud',
          price: Money(amountMinorUnits: 120000, currencyCode: 'USD'),
          cycle: const BillingCycle.yearly(),
          startDate: DateTime.utc(2025, 10, 15),
        );

        final projection = FinancialCalculator.calculateCalendarMonthProjection(
          [yearlySub],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        );

        expect(projection.occurrencesCount, equals(1));
        // Full price included, not 1/12 monthly equivalent
        expect(projection.totalProjected.amountMinorUnits, equals(120000));
      },
    );

    test(
      '[EC-16-1] counts weekly subscription by actual occurrences (4 or 5 times)',
      () {
        // Weekly subscription starting on Sunday Oct 4, 2026
        // In October 2026: Oct 4, 11, 18, 25 = 4 occurrences
        final weeklySub = createSub(
          id: 'weekly-1',
          name: 'Weekly Gym',
          price: Money(amountMinorUnits: 2500, currencyCode: 'USD'),
          cycle: const BillingCycle.weekly(),
          startDate: DateTime.utc(2026, 10, 4),
        );

        final projection = FinancialCalculator.calculateCalendarMonthProjection(
          [weeklySub],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        );

        expect(projection.occurrencesCount, equals(4));
        expect(projection.totalProjected.amountMinorUnits, equals(2500 * 4));
      },
    );

    test(
      '[EC-16-2] commitment due on the last day of the month is included',
      () {
        // Due on Oct 31, 2026
        final sub = createSub(
          id: 'end-1',
          name: 'End of Month Bill',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 31),
        );

        final projection = FinancialCalculator.calculateCalendarMonthProjection(
          [sub],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        );

        expect(projection.occurrencesCount, equals(1));
        expect(projection.occurrences.first.dueDate.day, equals(31));
        expect(projection.totalProjected.amountMinorUnits, equals(5000));
      },
    );

    test(
      '[EC-16-3] marks past due payments as overdue relative to referenceDate',
      () {
        final pastDueSub = createSub(
          id: 'past-1',
          name: 'Early Month Sub',
          price: Money(amountMinorUnits: 3000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 5),
        );
        final upcomingSub = createSub(
          id: 'up-1',
          name: 'Late Month Sub',
          price: Money(amountMinorUnits: 4000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 20),
        );

        // Reference date is Oct 15
        final projection = FinancialCalculator.calculateCalendarMonthProjection(
          [pastDueSub, upcomingSub],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 15),
        );

        expect(projection.occurrencesCount, equals(2));
        expect(projection.overdueAmount.amountMinorUnits, equals(3000));
        expect(projection.upcomingAmount.amountMinorUnits, equals(4000));
        expect(projection.totalProjected.amountMinorUnits, equals(7000));
        expect(projection.occurrences[0].isOverdue, isTrue);
        expect(projection.occurrences[1].isOverdue, isFalse);
      },
    );

    test(
      '[EC-16-4] returns zero and empty state for month without commitments',
      () {
        final projection = FinancialCalculator.calculateCalendarMonthProjection(
          [],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        );

        expect(projection.isEmpty, isTrue);
        expect(projection.totalProjected.amountMinorUnits, equals(0));
        expect(projection.occurrencesCount, equals(0));
      },
    );
  });

  group('FinancialCalculator - US-17: Rolling 30 Days Projection', () {
    test('[EC-17-1] daily commitment yields exactly 30 occurrences', () {
      final dailySub = createSub(
        id: 'daily-1',
        name: 'Daily Service',
        price: Money(amountMinorUnits: 100, currencyCode: 'USD'),
        cycle: BillingCycle.custom(1),
        startDate: DateTime.utc(2026, 10, 1),
      );

      final projection = FinancialCalculator.calculateRolling30DaysProjection(
        [dailySub],
        currencyCode: 'USD',
        referenceDate: DateTime.utc(2026, 10, 1),
      );

      expect(projection.occurrencesCount, equals(30));
      expect(projection.totalProjected.amountMinorUnits, equals(3000));
    });

    test(
      '[EC-17-2] includes payment at start of window and excludes Day 30',
      () {
        // Reference date: Oct 1, 2026
        // Day 0: Oct 1 (included)
        // Day 29: Oct 30 (included)
        // Day 30: Oct 31 (excluded from 30-day window [0..29])
        final subDay0 = createSub(
          id: 'd0',
          name: 'Day 0 Sub',
          price: Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 1),
        );
        final subDay29 = createSub(
          id: 'd29',
          name: 'Day 29 Sub',
          price: Money(amountMinorUnits: 2000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 30),
        );
        final subDay30 = createSub(
          id: 'd30',
          name: 'Day 30 Sub',
          price: Money(amountMinorUnits: 4000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 31),
        );

        final projection = FinancialCalculator.calculateRolling30DaysProjection(
          [subDay0, subDay29, subDay30],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        );

        expect(projection.occurrencesCount, equals(2));
        expect(projection.totalProjected.amountMinorUnits, equals(3000));
      },
    );
  });

  group('FinancialCalculator - US-18: Highest Cost Subscription', () {
    test(
      'identifies highest monthly equivalent and computes share percentage',
      () {
        final sub1 = createSub(
          id: '1',
          name: 'Netflix',
          price: Money(amountMinorUnits: 1500, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
        );
        final sub2 = createSub(
          id: '2',
          name: 'AWS Yearly',
          price: Money(
            amountMinorUnits: 120000,
            currencyCode: 'USD',
          ), // 100.00/mo = 10000
          cycle: const BillingCycle.yearly(),
          startDate: DateTime.utc(2026, 1, 1),
        );

        final result = FinancialCalculator.findHighestCostSubscription([
          sub1,
          sub2,
        ], currencyCode: 'USD');

        expect(result, isNotNull);
        expect(result!.subscription.id, equals('2'));
        expect(result.monthlyEquivalent.amountMinorUnits, equals(10000));
        expect(result.hasTie, isFalse);
        expect(result.isSingleSubscription, isFalse);
        // Total = 11500. 10000 / 11500 = ~86.956%
        expect(result.percentageOfTotal, closeTo(86.95, 0.05));
      },
    );

    test(
      '[EC-18-1] breaks ties in cost by prioritizing the older subscription',
      () {
        final older = createSub(
          id: 'older',
          name: 'Sub A',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1, 10, 0),
        );
        final newer = createSub(
          id: 'newer',
          name: 'Sub B',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 2, 10, 0),
        );

        final result = FinancialCalculator.findHighestCostSubscription([
          newer,
          older,
        ], currencyCode: 'USD');

        expect(result, isNotNull);
        expect(result!.subscription.id, equals('older'));
        expect(result.hasTie, isTrue);
      },
    );

    test('[EC-18-2] single subscription reports 100% share', () {
      final single = createSub(
        id: 'solo',
        name: 'Solo Sub',
        price: Money(amountMinorUnits: 2000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
      );

      final result = FinancialCalculator.findHighestCostSubscription([
        single,
      ], currencyCode: 'USD');

      expect(result, isNotNull);
      expect(result!.percentageOfTotal, equals(100.0));
      expect(result.isSingleSubscription, isTrue);
      expect(result.hasTie, isFalse);
    });

    test('[EC-18-3] empty active subscriptions returns null', () {
      final result = FinancialCalculator.findHighestCostSubscription(
        [],
        currencyCode: 'USD',
      );

      expect(result, isNull);
    });
  });

  group('FinancialCalculator - US-19: Category Spending Distribution', () {
    final catEntertainment = Category(
      id: 'cat-ent',
      name: 'Entertainment',
      colorValue: 0xFF1E40AF,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final catUtilities = Category(
      id: 'cat-util',
      name: 'Utilities',
      colorValue: 0xFF059669,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    test('calculates percentage shares accurately and groups correctly', () {
      final sub1 = createSub(
        id: '1',
        name: 'Netflix',
        price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        categoryId: 'cat-ent',
      );
      final sub2 = createSub(
        id: '2',
        name: 'Electric',
        price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        categoryId: 'cat-util',
      );

      final result = FinancialCalculator.calculateCategoryDistribution(
        [sub1, sub2],
        currencyCode: 'USD',
        categories: [catEntertainment, catUtilities],
      );

      expect(result.items.length, equals(2));
      expect(result.totalMonthlyEquivalent.amountMinorUnits, equals(10000));
      expect(result.items[0].percentage, equals(50.0));
      expect(result.items[1].percentage, equals(50.0));
    });

    test('[EC-19-1] single category reports 100% share', () {
      final sub = createSub(
        id: '1',
        name: 'Netflix',
        price: Money(amountMinorUnits: 3000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        categoryId: 'cat-ent',
      );

      final result = FinancialCalculator.calculateCategoryDistribution(
        [sub],
        currencyCode: 'USD',
        categories: [catEntertainment],
      );

      expect(result.items.length, equals(1));
      expect(result.items.first.percentage, equals(100.0));
    });

    test('[EC-19-2] categories with <1% share are preserved', () {
      final big = createSub(
        id: 'big',
        name: 'Big Cloud',
        price: Money(amountMinorUnits: 100000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        categoryId: 'cat-util',
      );
      final tiny = createSub(
        id: 'tiny',
        name: 'Tiny App',
        price: Money(
          amountMinorUnits: 50,
          currencyCode: 'USD',
        ), // 0.05% of total
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        categoryId: 'cat-ent',
      );

      final result = FinancialCalculator.calculateCategoryDistribution(
        [big, tiny],
        currencyCode: 'USD',
        categories: [catEntertainment, catUtilities],
      );

      expect(result.items.length, equals(2));
      final tinyItem = result.items.firstWhere(
        (i) => i.categoryId == 'cat-ent',
      );
      expect(tinyItem.percentage, closeTo(0.049, 0.005));
    });

    test('maps missing or deleted category to Uncategorized (US-19)', () {
      final sub = createSub(
        id: 'orphaned',
        name: 'Orphan Sub',
        price: Money(amountMinorUnits: 2000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        categoryId: 'non-existent-cat-id',
      );

      final result = FinancialCalculator.calculateCategoryDistribution(
        [sub],
        currencyCode: 'USD',
        categories: [catEntertainment],
      );

      expect(result.items.length, equals(1));
      expect(result.items.first.isUncategorized, isTrue);
      expect(result.items.first.categoryName, equals('غير مصنّف'));
    });

    test('[EC-19-3] empty data returns empty result', () {
      final result = FinancialCalculator.calculateCategoryDistribution(
        [],
        currencyCode: 'USD',
        categories: [catEntertainment],
      );

      expect(result.isEmpty, isTrue);
      expect(result.items, isEmpty);
    });
  });

  group('FinancialCalculator - US-20: Month-over-Month Comparison', () {
    test('reports increasing spend trend with correct percentage', () {
      // Previous month (Sep 2026): 1 sub active (50.00 USD)
      // Current month (Oct 2026): 2 subs active (50.00 USD + 50.00 USD = 100.00 USD)
      final sub1 = createSub(
        id: '1',
        name: 'Sub 1',
        price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 8, 1),
      );
      final sub2 = createSub(
        id: '2',
        name: 'Sub 2',
        price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 10, 1),
      );

      final result = FinancialCalculator.compareMonthOverMonth(
        [sub1, sub2],
        currencyCode: 'USD',
        referenceDate: DateTime.utc(2026, 10, 15),
      );

      expect(result.currentMonthTotal.amountMinorUnits, equals(10000));
      expect(result.previousMonthTotal.amountMinorUnits, equals(5000));
      expect(result.trend, equals(SpendTrend.increasing));
      expect(result.percentageChange, closeTo(100.0, 0.01));
    });

    test(
      'reports decreasing spend trend when current month has lower spend',
      () {
        // A yearly sub occurred in Sep (1200 USD) and monthly is 50 USD
        final yearlySep = createSub(
          id: 'yearly',
          name: 'Yearly Sep',
          price: Money(amountMinorUnits: 12000, currencyCode: 'USD'),
          cycle: const BillingCycle.yearly(),
          startDate: DateTime.utc(2025, 9, 15),
        );
        final monthly = createSub(
          id: 'monthly',
          name: 'Monthly',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2025, 1, 1),
        );

        final result = FinancialCalculator.compareMonthOverMonth(
          [yearlySep, monthly],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 15),
        );

        expect(result.trend, equals(SpendTrend.decreasing));
        expect(result.percentageChange, lessThan(0.0));
      },
    );

    test('[EC-20-3] reports unchanged trend when spending is identical', () {
      final sub = createSub(
        id: '1',
        name: 'Constant Sub',
        price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
      );

      final result = FinancialCalculator.compareMonthOverMonth(
        [sub],
        currencyCode: 'USD',
        referenceDate: DateTime.utc(2026, 10, 15),
      );

      expect(result.trend, equals(SpendTrend.unchanged));
      expect(result.percentageChange, equals(0.0));
    });

    test(
      '[EC-20-1, EC-20-2] prevents division by zero when previous month is zero',
      () {
        // Starts in current month (Oct 2026), zero in previous (Sep 2026)
        final sub = createSub(
          id: 'new',
          name: 'Brand New',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 1),
        );

        final result = FinancialCalculator.compareMonthOverMonth(
          [sub],
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 15),
        );

        expect(result.previousMonthTotal.amountMinorUnits, equals(0));
        expect(result.percentageChange, isNull);
        expect(result.trend, equals(SpendTrend.noPreviousData));
      },
    );
  });
}

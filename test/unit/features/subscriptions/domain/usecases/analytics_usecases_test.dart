import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/month_comparison_result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_category_distribution_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_highest_cost_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_month_comparison_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_upcoming_projections_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

import 'fake_category_repository.dart';
import 'fake_subscription_repository.dart';

void main() {
  late FakeSubscriptionRepository subRepo;
  late FakeCategoryRepository catRepo;

  late GetMonthlySummaryUseCase getMonthlySummaryUseCase;
  late GetUpcomingProjectionsUseCase getUpcomingProjectionsUseCase;
  late GetHighestCostSubscriptionUseCase getHighestCostSubscriptionUseCase;
  late GetCategoryDistributionUseCase getCategoryDistributionUseCase;
  late GetMonthComparisonUseCase getMonthComparisonUseCase;

  Subscription createSub({
    required String id,
    required String name,
    required Money price,
    required BillingCycle cycle,
    required DateTime startDate,
    SubscriptionStatus status = SubscriptionStatus.active,
    String categoryId = 'cat-1',
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
      createdAt: startUtc,
      updatedAt: startUtc,
      deletedAt: null,
      archivedAt: null,
    );
  }

  setUp(() {
    subRepo = FakeSubscriptionRepository();
    catRepo = FakeCategoryRepository();

    getMonthlySummaryUseCase = GetMonthlySummaryUseCase(subRepo);
    getUpcomingProjectionsUseCase = GetUpcomingProjectionsUseCase(subRepo);
    getHighestCostSubscriptionUseCase = GetHighestCostSubscriptionUseCase(
      subRepo,
    );
    getCategoryDistributionUseCase = GetCategoryDistributionUseCase(
      subscriptionRepository: subRepo,
      categoryRepository: catRepo,
    );
    getMonthComparisonUseCase = GetMonthComparisonUseCase(subRepo);
  });

  group('GetMonthlySummaryUseCase', () {
    test(
      'returns summaries for all currencies when currencyCode is null',
      () async {
        await subRepo.createSubscription(
          createSub(
            id: '1',
            name: 'Netflix USD',
            price: Money(amountMinorUnits: 1500, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: DateTime.utc(2026, 1, 1),
          ),
        );
        await subRepo.createSubscription(
          createSub(
            id: '2',
            name: 'Shahid SAR',
            price: Money(amountMinorUnits: 4000, currencyCode: 'SAR'),
            cycle: const BillingCycle.monthly(),
            startDate: DateTime.utc(2026, 1, 1),
          ),
        );

        final result = await getMonthlySummaryUseCase(
          GetMonthlySummaryParams.all,
        );

        expect(result.isSuccess, isTrue);
        final summaries = result.dataOrNull!;
        expect(summaries.length, equals(2));
        expect(summaries.containsKey('USD'), isTrue);
        expect(summaries.containsKey('SAR'), isTrue);
        expect(
          summaries['USD']!.totalMonthlyEquivalent.amountMinorUnits,
          equals(1500),
        );
        expect(
          summaries['SAR']!.totalMonthlyEquivalent.amountMinorUnits,
          equals(4000),
        );
      },
    );

    test(
      'returns single currency summary when currencyCode is specified',
      () async {
        await subRepo.createSubscription(
          createSub(
            id: '1',
            name: 'Netflix USD',
            price: Money(amountMinorUnits: 1500, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: DateTime.utc(2026, 1, 1),
          ),
        );

        final result = await getMonthlySummaryUseCase(
          const GetMonthlySummaryParams(currencyCode: 'USD'),
        );

        expect(result.isSuccess, isTrue);
        final summaries = result.dataOrNull!;
        expect(summaries.length, equals(1));
        expect(
          summaries['USD']!.totalMonthlyEquivalent.amountMinorUnits,
          equals(1500),
        );
      },
    );

    test('returns empty summary for non-existent currency', () async {
      final result = await getMonthlySummaryUseCase(
        const GetMonthlySummaryParams(currencyCode: 'EUR'),
      );

      expect(result.isSuccess, isTrue);
      final summaries = result.dataOrNull!;
      expect(summaries['EUR']!.isEmpty, isTrue);
    });

    test('propagates repository failure', () async {
      subRepo.injectedFailure = const DatabaseFailure('DB error');
      final result = await getMonthlySummaryUseCase(
        GetMonthlySummaryParams.all,
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('GetUpcomingProjectionsUseCase', () {
    test('returns calendar month projection successfully', () async {
      await subRepo.createSubscription(
        createSub(
          id: '1',
          name: 'Cloud Sub',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 10, 10),
        ),
      );

      final result = await getUpcomingProjectionsUseCase(
        GetUpcomingProjectionsParams.calendarMonth(
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        ),
      );

      expect(result.isSuccess, isTrue);
      final projection = result.dataOrNull!;
      expect(projection.isCalendarMonth, isTrue);
      expect(projection.totalProjected.amountMinorUnits, equals(5000));
      expect(projection.occurrencesCount, equals(1));
    });

    test('returns rolling 30-day projection successfully', () async {
      await subRepo.createSubscription(
        createSub(
          id: '1',
          name: 'Weekly Sub',
          price: Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.weekly(),
          startDate: DateTime.utc(2026, 10, 1),
        ),
      );

      final result = await getUpcomingProjectionsUseCase(
        GetUpcomingProjectionsParams.rolling30Days(
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 1),
        ),
      );

      expect(result.isSuccess, isTrue);
      final projection = result.dataOrNull!;
      expect(projection.isCalendarMonth, isFalse);
      expect(projection.occurrencesCount, greaterThan(0));
    });

    test('propagates repository error', () async {
      subRepo.injectedFailure = const DatabaseFailure('DB error');
      final result = await getUpcomingProjectionsUseCase(
        GetUpcomingProjectionsParams.calendarMonth(currencyCode: 'USD'),
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('GetHighestCostSubscriptionUseCase', () {
    test('returns highest cost subscription and share', () async {
      await subRepo.createSubscription(
        createSub(
          id: '1',
          name: 'Small Sub',
          price: Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
        ),
      );
      await subRepo.createSubscription(
        createSub(
          id: '2',
          name: 'Big Sub',
          price: Money(amountMinorUnits: 9000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
        ),
      );

      final result = await getHighestCostSubscriptionUseCase(
        const GetHighestCostSubscriptionParams(currencyCode: 'USD'),
      );

      expect(result.isSuccess, isTrue);
      final highest = result.dataOrNull!;
      expect(highest, isNotNull);
      expect(highest.subscription.id, equals('2'));
      expect(highest.percentageOfTotal, equals(90.0));
    });

    test(
      'returns null when no active subscriptions exist for currency',
      () async {
        final result = await getHighestCostSubscriptionUseCase(
          const GetHighestCostSubscriptionParams(currencyCode: 'USD'),
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNull);
      },
    );

    test('propagates repository error', () async {
      subRepo.injectedFailure = const DatabaseFailure('DB error');
      final result = await getHighestCostSubscriptionUseCase(
        const GetHighestCostSubscriptionParams(currencyCode: 'USD'),
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('GetCategoryDistributionUseCase', () {
    test('generates distribution with proper category names', () async {
      final category = Category(
        id: 'cat-media',
        name: 'Media',
        colorValue: 0xFF123456,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await catRepo.createCategory(category);

      await subRepo.createSubscription(
        createSub(
          id: '1',
          name: 'Spotify',
          price: Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          categoryId: 'cat-media',
        ),
      );

      final result = await getCategoryDistributionUseCase(
        const GetCategoryDistributionParams(currencyCode: 'USD'),
      );

      expect(result.isSuccess, isTrue);
      final dist = result.dataOrNull!;
      expect(dist.items.length, equals(1));
      expect(dist.items.first.categoryName, equals('Media'));
      expect(dist.items.first.percentage, equals(100.0));
    });

    test('propagates repository error from subscriptions', () async {
      subRepo.injectedFailure = const DatabaseFailure('DB error');
      final result = await getCategoryDistributionUseCase(
        const GetCategoryDistributionParams(currencyCode: 'USD'),
      );

      expect(result.isFailure, isTrue);
    });

    test('propagates repository error from categories', () async {
      catRepo.injectedFailure = const DatabaseFailure('DB error');
      final result = await getCategoryDistributionUseCase(
        const GetCategoryDistributionParams(currencyCode: 'USD'),
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('GetMonthComparisonUseCase', () {
    test('computes month-over-month comparison accurately', () async {
      await subRepo.createSubscription(
        createSub(
          id: '1',
          name: 'Continuous Sub',
          price: Money(amountMinorUnits: 5000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 8, 1),
        ),
      );

      final result = await getMonthComparisonUseCase(
        GetMonthComparisonParams(
          currencyCode: 'USD',
          referenceDate: DateTime.utc(2026, 10, 15),
        ),
      );

      expect(result.isSuccess, isTrue);
      final comp = result.dataOrNull!;
      expect(comp.currentMonthTotal.amountMinorUnits, equals(5000));
      expect(comp.previousMonthTotal.amountMinorUnits, equals(5000));
      expect(comp.trend, equals(SpendTrend.unchanged));
      expect(comp.percentageChange, equals(0.0));
    });

    test('propagates repository failure', () async {
      subRepo.injectedFailure = const DatabaseFailure('DB error');
      final result = await getMonthComparisonUseCase(
        GetMonthComparisonParams(currencyCode: 'USD'),
      );

      expect(result.isFailure, isTrue);
    });
  });
}

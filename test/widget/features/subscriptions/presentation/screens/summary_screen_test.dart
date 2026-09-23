import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category_distribution_item.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/highest_cost_subscription_result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/monthly_summary.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/upcoming_projection.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_category_distribution_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_highest_cost_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_upcoming_projections_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/summary_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/summary_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_empty_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_error_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_loading_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/category_distribution_bar.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/category_pie_chart.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/metric_card.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/monthly_comparison_chart.dart';

// Fake UseCases
class FakeGetMonthlySummaryUseCase implements GetMonthlySummaryUseCase {
  Map<String, MonthlySummary> summariesToReturn = {};
  bool shouldFail = false;

  @override
  Future<Result<Map<String, MonthlySummary>>> call(
    GetMonthlySummaryParams params,
  ) async {
    if (shouldFail) {
      return const Error(DatabaseFailure('فشل حساب الملخص المالي'));
    }
    return Success(summariesToReturn);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetUpcomingProjectionsUseCase
    implements GetUpcomingProjectionsUseCase {
  UpcomingProjection? projectionToReturn;

  @override
  Future<Result<UpcomingProjection>> call(
    GetUpcomingProjectionsParams params,
  ) async {
    return Success(
      projectionToReturn ??
          UpcomingProjection(
            currencyCode: params.currencyCode,
            windowStart: DateTime.utc(2026, 9, 1),
            windowEnd: DateTime.utc(2026, 9, 30),
            totalProjected: const Money(
              amountMinorUnits: 4500,
              currencyCode: 'USD',
            ),
            overdueAmount: const Money(
              amountMinorUnits: 0,
              currencyCode: 'USD',
            ),
            upcomingAmount: const Money(
              amountMinorUnits: 4500,
              currencyCode: 'USD',
            ),
            occurrences: const [],
            isCalendarMonth: true,
          ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetCategoryDistributionUseCase
    implements GetCategoryDistributionUseCase {
  CategoryDistributionResult? distToReturn;

  @override
  Future<Result<CategoryDistributionResult>> call(
    GetCategoryDistributionParams params,
  ) async {
    return Success(
      distToReturn ??
          CategoryDistributionResult(
            currencyCode: params.currencyCode,
            items: [
              const CategoryDistributionItem(
                categoryId: 'cat-1',
                categoryName: 'ترفيه',
                colorValue: 0xFFFF0000,
                totalMonthlyEquivalent: Money(
                  amountMinorUnits: 3000,
                  currencyCode: 'USD',
                ),
                percentage: 60.0,
                subscriptionsCount: 2,
              ),
              const CategoryDistributionItem(
                categoryId: 'cat-2',
                categoryName: 'عمل',
                colorValue: 0xFF00FF00,
                totalMonthlyEquivalent: Money(
                  amountMinorUnits: 2000,
                  currencyCode: 'USD',
                ),
                percentage: 40.0,
                subscriptionsCount: 1,
              ),
            ],
            totalMonthlyEquivalent: const Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
          ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetHighestCostSubscriptionUseCase
    implements GetHighestCostSubscriptionUseCase {
  HighestCostSubscriptionResult? highestToReturn;

  @override
  Future<Result<HighestCostSubscriptionResult>> call(
    GetHighestCostSubscriptionParams params,
  ) async {
    return Success(
      highestToReturn ??
          HighestCostSubscriptionResult(
            subscription: Subscription.create(
              id: 'sub-1',
              name: 'Netflix Premium',
              price: const Money(amountMinorUnits: 2000, currencyCode: 'USD'),
              cycle: const BillingCycle.monthly(),
              startDate: DateTime.utc(2026, 1, 1),
              dueDate: DueDate(DateTime.utc(2026, 10, 1)),
              categoryId: 'cat-1',
            ),
            monthlyEquivalent: const Money(
              amountMinorUnits: 2000,
              currencyCode: 'USD',
            ),
            percentageOfTotal: 40.0,
            hasTie: false,
            isSingleSubscription: false,
          ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SummaryScreen Four View States & Financial Analytics', () {
    late FakeGetMonthlySummaryUseCase fakeSummaryUseCase;
    late FakeGetUpcomingProjectionsUseCase fakeProjectionsUseCase;
    late FakeGetCategoryDistributionUseCase fakeCategoryDistUseCase;
    late FakeGetHighestCostSubscriptionUseCase fakeHighestCostUseCase;
    late SummaryController controller;

    setUp(() {
      fakeSummaryUseCase = FakeGetMonthlySummaryUseCase();
      fakeProjectionsUseCase = FakeGetUpcomingProjectionsUseCase();
      fakeCategoryDistUseCase = FakeGetCategoryDistributionUseCase();
      fakeHighestCostUseCase = FakeGetHighestCostSubscriptionUseCase();

      controller = SummaryController(
        getMonthlySummaryUseCase: fakeSummaryUseCase,
        getUpcomingProjectionsUseCase: fakeProjectionsUseCase,
        getCategoryDistributionUseCase: fakeCategoryDistUseCase,
        getHighestCostSubscriptionUseCase: fakeHighestCostUseCase,
      );
    });

    Widget createWidget() {
      return MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: SummaryScreen(controller: controller),
      );
    }

    testWidgets('1. Loading State: displays AppLoadingView while computing', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      expect(find.byType(AppLoadingView), findsOneWidget);
    });

    testWidgets(
      '2. Empty State: US-15 / EC-15-1 displays designed AppEmptyView when zero records exist',
      (tester) async {
        fakeSummaryUseCase.summariesToReturn = {};
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AppEmptyView), findsOneWidget);
        expect(find.text('لا توجد بيانات كافية للتحليل'), findsOneWidget);
        expect(find.text('إضافة أول اشتراك'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Error State: US-15 / EC-15-4 displays AppErrorView with retry button when calculation fails',
      (tester) async {
        fakeSummaryUseCase.shouldFail = true;
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AppErrorView), findsOneWidget);
        expect(find.text('فشل حساب الملخص المالي'), findsOneWidget);
      },
    );

    testWidgets(
      '4. Data State: renders MetricCards, Highest Cost Card, and CategoryDistributionBar',
      (tester) async {
        fakeSummaryUseCase.summariesToReturn = {
          'USD': const MonthlySummary(
            currencyCode: 'USD',
            totalMonthlyEquivalent: Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            totalAnnualEquivalent: Money(
              amountMinorUnits: 60000,
              currencyCode: 'USD',
            ),
            averageMonthlyCost: Money(
              amountMinorUnits: 1667,
              currencyCode: 'USD',
            ),
            activeSubscriptionsCount: 3,
          ),
        };

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Metric Cards
        expect(find.byType(MetricCard), findsNWidgets(4));
        expect(find.text('المكافئ الشهري'), findsOneWidget);
        expect(find.text('المكافئ السنوي'), findsOneWidget);
        expect(find.text('الاشتراكات النشطة'), findsOneWidget);

        // Highest cost card
        expect(find.text('الاشتراك الأعلى كلفة'), findsOneWidget);
        expect(find.text('Netflix Premium'), findsOneWidget);

        // Category Distribution & Charts
        expect(find.text('توزيع الإنفاق حسب الفئات'), findsOneWidget);
        expect(find.byType(CategoryPieChart), findsOneWidget);
        expect(find.byType(MonthlyComparisonChart), findsOneWidget);
        expect(find.byType(CategoryDistributionBar), findsNWidgets(2));
        expect(
          find.descendant(
            of: find.byType(CategoryDistributionBar),
            matching: find.text('ترفيه'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(CategoryDistributionBar),
            matching: find.text('عمل'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '5. Multi-Currency Support: renders currency selector choice chips when multiple currencies exist',
      (tester) async {
        fakeSummaryUseCase.summariesToReturn = {
          'USD': const MonthlySummary(
            currencyCode: 'USD',
            totalMonthlyEquivalent: Money(
              amountMinorUnits: 5000,
              currencyCode: 'USD',
            ),
            totalAnnualEquivalent: Money(
              amountMinorUnits: 60000,
              currencyCode: 'USD',
            ),
            averageMonthlyCost: Money(
              amountMinorUnits: 2500,
              currencyCode: 'USD',
            ),
            activeSubscriptionsCount: 2,
          ),
          'SAR': const MonthlySummary(
            currencyCode: 'SAR',
            totalMonthlyEquivalent: Money(
              amountMinorUnits: 25000,
              currencyCode: 'SAR',
            ),
            totalAnnualEquivalent: Money(
              amountMinorUnits: 300000,
              currencyCode: 'SAR',
            ),
            averageMonthlyCost: Money(
              amountMinorUnits: 25000,
              currencyCode: 'SAR',
            ),
            activeSubscriptionsCount: 1,
          ),
        };

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ChoiceChip), findsNWidgets(2));
        expect(find.text('USD'), findsOneWidget);
        expect(find.text('SAR'), findsOneWidget);
      },
    );
  });
}

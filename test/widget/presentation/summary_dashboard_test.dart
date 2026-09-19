import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/expense_summary.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_view_state.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/summary_dashboard.dart';

void main() {
  Widget buildTestWidget({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('SummaryDashboard Widget & Math Verification (US-15, EC-15-1)', () {
    testWidgets(
      '1. US-15 Criteria: 1200 yearly + 50 monthly calculates exactly 150.00/mo',
      (tester) async {
        final yearlySub = Subscription.create(
          id: 'sub-yearly',
          name: 'اشتراك سنوي',
          price: Money.create(
            amountMinorUnits: 120000,
            currencyCode: 'USD',
          ), // $1200.00
          cycle: const BillingCycle.yearly(),
          dueDate: DueDate.create(date: DateTime.utc(2027, 1, 1)),
          startDate: DateTime.utc(2026, 1, 1),
          categoryId: 'cat-1',
        );

        final monthlySub = Subscription.create(
          id: 'sub-monthly',
          name: 'اشتراك شهري',
          price: Money.create(
            amountMinorUnits: 5000,
            currencyCode: 'USD',
          ), // $50.00
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 1)),
          startDate: DateTime.utc(2026, 9, 1),
          categoryId: 'cat-1',
        );

        final summary = ExpenseSummary.fromSubscriptions([
          yearlySub,
          monthlySub,
        ]);

        await tester.pumpWidget(
          buildTestWidget(child: SummaryDashboard(summary: summary)),
        );

        // Verify Monthly Equivalent is exactly 150.00 $
        expect(find.text('150.00 \$'), findsOneWidget);
        expect(find.text('2 نشط'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Empty State: displays empty summary when activeCount is zero',
      (tester) async {
        final emptySummary = ExpenseSummary.zero();

        await tester.pumpWidget(
          buildTestWidget(child: SummaryDashboard(summary: emptySummary)),
        );

        expect(find.text('ملخص المصروفات الشهرية'), findsOneWidget);
        expect(
          find.text('لا توجد اشتراكات نشطة حالياً لاحتساب الإجمالي.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '3. Multi-currency separation [EC-15-1]: displays separate indicators',
      (tester) async {
        final usdSub = Subscription.create(
          id: 'sub-usd',
          name: 'Netflix',
          price: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 1)),
          startDate: DateTime.utc(2026, 9, 1),
          categoryId: 'cat-1',
        );

        final sarSub = Subscription.create(
          id: 'sub-sar',
          name: 'فاتورة اتصالات',
          price: Money.create(amountMinorUnits: 20000, currencyCode: 'SAR'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 5)),
          startDate: DateTime.utc(2026, 9, 5),
          categoryId: 'cat-2',
        );

        final summary = ExpenseSummary.fromSubscriptions([usdSub, sarSub]);

        await tester.pumpWidget(
          buildTestWidget(child: SummaryDashboard(summary: summary)),
        );

        // Primary is USD ($15.00)
        expect(find.text('15.00 \$'), findsOneWidget);

        // Secondary currency breakdown shows SAR
        expect(find.text('تفصيل العملات الأخرى:'), findsOneWidget);
        expect(find.text('200.00 ر.س / شهر'), findsOneWidget);
      },
    );

    testWidgets('4. Loading & Error states passed via SubscriptionsViewState', (
      tester,
    ) async {
      // Test Loading state
      await tester.pumpWidget(
        buildTestWidget(
          child: const SummaryDashboard(state: SubscriptionsLoading()),
        ),
      );
      expect(find.byType(Container), findsWidgets);

      // Test Error state
      bool retryClicked = false;
      await tester.pumpWidget(
        buildTestWidget(
          child: SummaryDashboard(
            state: SubscriptionsError(
              message: 'تعطّل الخوارزمية الحسابية',
              onRetry: () => retryClicked = true,
            ),
          ),
        ),
      );

      expect(
        find.text('تعذّر حساب الملخص المالي: تعطّل الخوارزمية الحسابية'),
        findsOneWidget,
      );
      expect(find.text('إعادة'), findsOneWidget);

      await tester.tap(find.text('إعادة'));
      await tester.pump();
      expect(retryClicked, isTrue);
    });
  });
}

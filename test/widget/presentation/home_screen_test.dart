import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/expense_summary.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_view_state.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/empty_state_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/error_state_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/loading_shimmer_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/summary_dashboard.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
    ThemeData? theme,
    double textScale = 1.0,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: child,
      ),
    );
  }

  group('HomeScreen Four States Verification (C-16, US-05)', () {
    testWidgets(
      '1. Loading State: renders LoadingShimmerView without blank white screen',
      (tester) async {
        final controller = SubscriptionsController(
          initialState: const SubscriptionsLoading(),
        );

        await tester.pumpWidget(
          buildTestWidget(child: HomeScreen(controller: controller)),
        );

        // Verify LoadingShimmerView is present
        expect(find.byType(LoadingShimmerView), findsOneWidget);
        expect(find.byKey(const Key('home_loading_view')), findsOneWidget);

        // Verify no Empty, Error, or Data views are rendered
        expect(find.byType(EmptyStateView), findsNothing);
        expect(find.byType(ErrorStateView), findsNothing);
        expect(find.byType(SubscriptionCard), findsNothing);

        controller.dispose();
      },
    );

    testWidgets(
      '2. Empty State: renders EmptyStateView with guidance text and CTA (EC-05-1)',
      (tester) async {
        final controller = SubscriptionsController(
          initialState: const SubscriptionsEmpty(),
        );

        bool addTriggered = false;
        await tester.pumpWidget(
          buildTestWidget(
            child: HomeScreen(
              controller: controller,
              onAddSubscription: () => addTriggered = true,
            ),
          ),
        );

        // Verify EmptyStateView is visible
        expect(find.byType(EmptyStateView), findsOneWidget);
        expect(find.text('لا توجد التزامات دورية بعد'), findsOneWidget);
        expect(find.byKey(const Key('empty_state_cta_button')), findsOneWidget);

        // Tap Empty CTA and verify action
        await tester.tap(find.byKey(const Key('empty_state_cta_button')));
        await tester.pump();
        expect(addTriggered, isTrue);

        controller.dispose();
      },
    );

    testWidgets(
      '3. Error State: renders ErrorStateView with message and working Retry button (EC-05-4)',
      (tester) async {
        bool retryCalled = false;
        final controller = SubscriptionsController(
          initialState: SubscriptionsError(
            message: 'فشل الاتصال بقاعدة البيانات المحلية',
            onRetry: () => retryCalled = true,
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(child: HomeScreen(controller: controller)),
        );

        // Verify ErrorStateView
        expect(find.byType(ErrorStateView), findsOneWidget);
        expect(
          find.text('فشل الاتصال بقاعدة البيانات المحلية'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('error_retry_button')), findsOneWidget);

        // Tap Retry button
        await tester.tap(find.byKey(const Key('error_retry_button')));
        await tester.pump();
        expect(retryCalled, isTrue);

        controller.dispose();
      },
    );

    testWidgets(
      '4. Data State: renders SummaryDashboard and SubscriptionCards in list',
      (tester) async {
        final category = Category.create(
          id: 'cat-stream',
          name: 'ترفيه',
          colorValue: 0xFF6366F1,
        );

        final subscription = Subscription.create(
          id: 'sub-netflix',
          name: 'Netflix Premium',
          price: Money.create(amountMinorUnits: 1599, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 1)),
          startDate: DateTime.utc(2026, 9, 1),
          categoryId: category.id,
        );

        final summary = ExpenseSummary.fromSubscriptions([subscription]);

        final controller = SubscriptionsController(
          initialState: SubscriptionsData(
            subscriptions: [subscription],
            categories: {category.id: category},
            summary: summary,
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(child: HomeScreen(controller: controller)),
        );

        // Verify Summary and Subscription Cards exist
        expect(find.byType(SummaryDashboard), findsOneWidget);
        expect(find.byType(SubscriptionCard), findsOneWidget);
        expect(find.text('Netflix Premium'), findsOneWidget);
        expect(find.text('ترفيه'), findsOneWidget);

        controller.dispose();
      },
    );

    testWidgets(
      '5. RTL Directionality and 200% Font Scale without overflow (NFR-04)',
      (tester) async {
        final category = Category.create(
          id: 'cat-work',
          name: 'العمل والإنتاجية',
          colorValue: 0xFF10B981,
        );

        final subscription = Subscription.create(
          id: 'sub-adobe',
          name: 'Adobe Creative Cloud',
          price: Money.create(amountMinorUnits: 5499, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 9, 25)),
          startDate: DateTime.utc(2026, 8, 25),
          categoryId: category.id,
        );

        final controller = SubscriptionsController(
          initialState: SubscriptionsData(
            subscriptions: [subscription],
            categories: {category.id: category},
            summary: ExpenseSummary.fromSubscriptions([subscription]),
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(
            theme: AppTheme.dark,
            textScale: 2.0,
            child: HomeScreen(controller: controller),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Adobe Creative Cloud'), findsOneWidget);

        controller.dispose();
      },
    );
  });
}

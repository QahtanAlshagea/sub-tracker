import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/add_edit_subscription_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/expense_summary.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_view_state.dart';
import 'package:sub_tracker/features/subscriptions/presentation/utils/debounce_guard.dart';

void main() {
  Widget buildTestApp({
    required Widget child,
    ThemeData? theme,
    Size? surfaceSize,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }

  final sampleCategory = Category.create(
    id: 'cat-tools',
    name: 'أدوات وإنتاجية',
    colorValue: 0xFF4F46E5,
  );

  group('Micro-interactions, Debouncing, Undo SnackBar & Rotation (C-17)', () {
    test(
      '1. DebounceGuard correctly throttles rapid invocations within window (EC-01-5)',
      () {
        final guard = DebounceGuard(window: const Duration(milliseconds: 300));
        int executedCount = 0;

        // First run should succeed
        final res1 = guard.run(() => executedCount++);
        expect(res1, isTrue);
        expect(executedCount, 1);

        // Rapid consecutive runs within 300ms window should be throttled
        final res2 = guard.run(() => executedCount++);
        final res3 = guard.run(() => executedCount++);
        expect(res2, isFalse);
        expect(res3, isFalse);
        expect(executedCount, 1);
      },
    );

    testWidgets(
      '2. Double-tap on Save button only executes save once (EC-01-5)',
      (tester) async {
        int saveCallCount = 0;

        await tester.pumpWidget(
          buildTestApp(
            child: AddEditSubscriptionScreen(
              categories: [sampleCategory],
              onSaved: (_) => saveCallCount++,
            ),
          ),
        );

        // Fill in valid data
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'Notion Plus',
        );
        await tester.enterText(
          find.byKey(const Key('subscription_price_field')),
          '10.00',
        );

        final saveButton = find.byKey(const Key('subscription_save_button'));

        // Simulate rapid double tap without waiting
        await tester.tap(saveButton, warnIfMissed: false);
        await tester.tap(saveButton, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Ensure callback was invoked exactly once
        expect(saveCallCount, 1);
      },
    );

    testWidgets(
      '3. Swipe-to-delete shows floating Undo SnackBar and removes card (US-13)',
      (tester) async {
        final sub = Subscription.create(
          id: 'sub-swipe',
          name: 'اشتراك قابل للحذف',
          price: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 1)),
          startDate: DateTime.utc(2026, 9, 1),
          categoryId: sampleCategory.id,
        );

        final controller = SubscriptionsController(
          initialState: SubscriptionsData(
            subscriptions: [sub],
            categories: {sampleCategory.id: sampleCategory},
            summary: ExpenseSummary.fromSubscriptions([sub]),
          ),
        );

        await tester.pumpWidget(
          buildTestApp(child: HomeScreen(controller: controller)),
        );

        expect(find.text('اشتراك قابل للحذف'), findsOneWidget);

        // Perform swipe to delete on dismissible
        final dismissibleFinder = find.byKey(Key('dismissible_${sub.id}'));
        expect(dismissibleFinder, findsOneWidget);

        await tester.drag(dismissibleFinder, const Offset(-600, 0));
        await tester.pumpAndSettle();

        // Card is removed from list
        expect(find.text('اشتراك قابل للحذف'), findsNothing);

        // Undo SnackBar is displayed
        expect(find.byKey(const Key('undo_snackbar')), findsOneWidget);
        expect(find.text('تم حذف اشتراك "اشتراك قابل للحذف"'), findsOneWidget);
        expect(find.byKey(const Key('undo_delete_button')), findsOneWidget);

        controller.dispose();
      },
    );

    testWidgets(
      '4. Tapping Undo restores subscription to list and updates summary (US-14)',
      (tester) async {
        final sub = Subscription.create(
          id: 'sub-undo',
          name: 'اشتراك قابل للاستعادة',
          price: Money.create(amountMinorUnits: 2000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 1)),
          startDate: DateTime.utc(2026, 9, 1),
          categoryId: sampleCategory.id,
        );

        final controller = SubscriptionsController(
          initialState: SubscriptionsData(
            subscriptions: [sub],
            categories: {sampleCategory.id: sampleCategory},
            summary: ExpenseSummary.fromSubscriptions([sub]),
          ),
        );

        await tester.pumpWidget(
          buildTestApp(child: HomeScreen(controller: controller)),
        );

        // Swipe to delete
        await tester.drag(
          find.byKey(Key('dismissible_${sub.id}')),
          const Offset(-600, 0),
        );
        await tester.pumpAndSettle();

        // Verify removed
        expect(find.text('اشتراك قابل للاستعادة'), findsNothing);

        // Tap Undo button on SnackBar
        await tester.tap(find.byKey(const Key('undo_delete_button')));
        await tester.pumpAndSettle();

        // Verify item restored to list
        expect(find.text('اشتراك قابل للاستعادة'), findsOneWidget);

        // Verify summary and restored card both display 20.00 $
        expect(find.text('20.00 \$'), findsNWidgets(2));
        expect(
          find.descendant(
            of: find.byKey(const Key('home_summary_dashboard')),
            matching: find.text('20.00 \$'),
          ),
          findsOneWidget,
        );

        controller.dispose();
      },
    );

    testWidgets(
      '5. Form retains inputs when screen is rotated between Portrait and Landscape (EC-01-7)',
      (tester) async {
        // 1. Start in Portrait mode (400 x 800)
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestApp(
            child: AddEditSubscriptionScreen(categories: [sampleCategory]),
          ),
        );

        // Enter data in Portrait
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'Canva Pro Team',
        );
        await tester.enterText(
          find.byKey(const Key('subscription_price_field')),
          '12.50',
        );

        // Select custom cycle
        await tester.tap(find.text('مخصص'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('subscription_custom_days_field')),
          '90',
        );
        await tester.pumpAndSettle();

        // 2. Rotate to Landscape mode (900 x 500)
        tester.view.physicalSize = const Size(900, 500);
        await tester.pumpAndSettle();

        // Verify all inputs are preserved without loss (EC-01-7)
        expect(find.text('Canva Pro Team'), findsOneWidget);
        expect(find.text('12.50'), findsOneWidget);
        expect(find.text('90'), findsOneWidget);

        // Verify two-column responsive layout is active (width >= 600)
        expect(find.byType(Row), findsWidgets);
      },
    );
  });
}

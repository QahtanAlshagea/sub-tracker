import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/add_edit_subscription_screen.dart';

void main() {
  Widget buildTestWidget({required Widget child, ThemeData? theme}) {
    return MaterialApp(theme: theme ?? AppTheme.light, home: child);
  }

  final testCategories = [
    Category.create(id: 'cat-stream', name: 'بث رقمي', colorValue: 0xFF6366F1),
    Category.create(
      id: 'cat-bills',
      name: 'فواتير وخدمات',
      colorValue: 0xFF10B981,
    ),
  ];

  group('AddEditSubscriptionScreen Widget Tests (US-01, US-02, US-03, US-07)', () {
    testWidgets('1. Renders all form fields and save button', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: AddEditSubscriptionScreen(categories: testCategories),
        ),
      );

      expect(find.byKey(const Key('subscription_name_field')), findsOneWidget);
      expect(find.byKey(const Key('subscription_price_field')), findsOneWidget);
      expect(
        find.byKey(const Key('subscription_currency_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription_trial_switch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription_cycle_selector')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription_category_dropdown')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription_start_date_picker')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('subscription_due_date_picker')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('subscription_save_button')), findsOneWidget);
    });

    testWidgets(
      '2. Displays inline validation error under empty name field (US-01, EC-01-1)',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: AddEditSubscriptionScreen(categories: testCategories),
          ),
        );

        // Tap save without filling name
        await tester.tap(find.byKey(const Key('subscription_save_button')));
        await tester.pumpAndSettle();

        // Verify inline error under name field
        expect(find.text('Subscription name cannot be empty.'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Rejects zero price for non-trial and shows inline error (US-02, EC-02-1)',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: AddEditSubscriptionScreen(categories: testCategories),
          ),
        );

        // Enter valid name
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'Disney Plus',
        );

        // Enter zero price
        await tester.enterText(
          find.byKey(const Key('subscription_price_field')),
          '0.00',
        );

        // Tap save
        await tester.tap(find.byKey(const Key('subscription_save_button')));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Subscription price cannot be zero unless it is marked as a free trial.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '4. Free trial switch allows 0.00 price without error (EC-01-4, US-02)',
      (tester) async {
        Subscription? savedSub;

        await tester.pumpWidget(
          buildTestWidget(
            child: AddEditSubscriptionScreen(
              categories: testCategories,
              onSaved: (sub) => savedSub = sub,
            ),
          ),
        );

        // Enter name
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'Audible Free Trial',
        );

        // Toggle free trial switch
        await tester.tap(find.byKey(const Key('subscription_trial_switch')));
        await tester.pumpAndSettle();

        // Tap save
        await tester.tap(find.byKey(const Key('subscription_save_button')));
        await tester.pumpAndSettle();

        // Verify subscription was successfully created with price 0
        expect(savedSub, isNotNull);
        expect(savedSub!.isTrial, isTrue);
        expect(savedSub!.price.amountMinorUnits, 0);
      },
    );

    testWidgets(
      '5. Custom cycle selection dynamically reveals custom days field (US-03, EC-03-1)',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: AddEditSubscriptionScreen(categories: testCategories),
          ),
        );

        // Initially custom days field is not visible
        expect(
          find.byKey(const Key('subscription_custom_days_field')),
          findsNothing,
        );

        // Tap 'مخصص' in segmented button
        await tester.tap(find.text('مخصص'));
        await tester.pumpAndSettle();

        // Verify custom days field appeared
        expect(
          find.byKey(const Key('subscription_custom_days_field')),
          findsOneWidget,
        );

        // Enter invalid custom days (0)
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'Custom Service',
        );
        await tester.enterText(
          find.byKey(const Key('subscription_price_field')),
          '10.00',
        );
        await tester.enterText(
          find.byKey(const Key('subscription_custom_days_field')),
          '0',
        );

        await tester.tap(find.byKey(const Key('subscription_save_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Custom cycle days must be between 1 and 3650 days.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '6. Submitting valid form calls onSaved callback and creates Subscription',
      (tester) async {
        Subscription? savedSub;

        await tester.pumpWidget(
          buildTestWidget(
            child: AddEditSubscriptionScreen(
              categories: testCategories,
              onSaved: (sub) => savedSub = sub,
            ),
          ),
        );

        // Fill valid data
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'ChatGPT Plus',
        );
        await tester.enterText(
          find.byKey(const Key('subscription_price_field')),
          '20.00',
        );

        await tester.tap(find.byKey(const Key('subscription_save_button')));
        await tester.pumpAndSettle();

        expect(savedSub, isNotNull);
        expect(savedSub!.name, 'ChatGPT Plus');
        expect(savedSub!.price.amountMinorUnits, 2000);
        expect(savedSub!.price.currencyCode, 'USD');
      },
    );

    testWidgets(
      '7. Unsaved changes confirmation dialog appears on back when dirty (US-07)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditSubscriptionScreen(
                            categories: testCategories,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Form'),
                  ),
                );
              },
            ),
          ),
        );

        // Open screen
        await tester.tap(find.text('Open Form'));
        await tester.pumpAndSettle();

        // Edit a field to make it dirty
        await tester.enterText(
          find.byKey(const Key('subscription_name_field')),
          'Draft Name',
        );
        await tester.pumpAndSettle();

        // Simulate system back
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();

        // Verify confirmation dialog appeared
        expect(find.text('تجاهل التغييرات؟'), findsOneWidget);
        expect(find.text('البقاء'), findsOneWidget);
        expect(find.text('تجاهل والخروج'), findsOneWidget);

        // Tap 'البقاء'
        await tester.tap(find.text('البقاء'));
        await tester.pumpAndSettle();

        // Still on screen
        expect(
          find.byKey(const Key('subscription_name_field')),
          findsOneWidget,
        );
      },
    );
  });
}

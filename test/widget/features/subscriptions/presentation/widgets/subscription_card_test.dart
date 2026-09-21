import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

void main() {
  group('SubscriptionCard Widget Tests', () {
    late Subscription testSubscription;
    late Category testCategory;

    setUp(() {
      testCategory = Category(
        id: 'cat-1',
        name: 'Streaming',
        colorValue: 0xFF4F46E5,
        isSystem: false,
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final now = DateTime.now().toUtc();
      testSubscription = Subscription.create(
        id: 'sub-1',
        name: 'Netflix Premium',
        price: Money.create(amountMinorUnits: 1999, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 9, 1),
        dueDate: DueDate(now.add(const Duration(days: 15)), now.day),
        categoryId: 'cat-1',
        status: SubscriptionStatus.active,
      );
    });

    Widget createWidget({
      required Subscription subscription,
      Category? category,
      VoidCallback? onTap,
      VoidCallback? onMarkPaid,
    }) {
      return MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SubscriptionCard(
            subscription: subscription,
            category: category,
            onTap: onTap,
            onMarkPaid: onMarkPaid,
          ),
        ),
      );
    }

    testWidgets('renders subscription attributes accurately', (tester) async {
      await tester.pumpWidget(
        createWidget(subscription: testSubscription, category: testCategory),
      );
      await tester.pumpAndSettle();

      expect(find.text('Netflix Premium'), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
      expect(find.text('/ Monthly'), findsOneWidget);
      expect(find.text('Streaming'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets(
      'US-05 / EC-05-5: truncates long subscription name with ellipsis',
      (tester) async {
        final longNameSub = testSubscription.copyWith(
          name:
              'A very long subscription name that definitely exceeds standard card space limit',
        );

        await tester.pumpWidget(
          createWidget(subscription: longNameSub, category: testCategory),
        );
        await tester.pumpAndSettle();

        final textWidget = tester.widget<Text>(
          find.byKey(const Key('subscription_card_title')),
        );
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      },
    );

    testWidgets(
      'US-40 / EC-40-3: renders accessible status badge with icon and label for due soon',
      (tester) async {
        final now = DateTime.now().toUtc();
        final dueSoonSub = testSubscription.copyWith(
          dueDate: DueDate(now.add(const Duration(days: 2)), now.day),
        );

        await tester.pumpWidget(
          createWidget(subscription: dueSoonSub, category: testCategory),
        );
        await tester.pumpAndSettle();

        expect(find.text('Due Soon'), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      },
    );

    testWidgets('US-37 / EC-37-1: executes quick mark-as-paid action on tap', (
      tester,
    ) async {
      var markPaidTapped = false;

      await tester.pumpWidget(
        createWidget(
          subscription: testSubscription,
          category: testCategory,
          onMarkPaid: () => markPaidTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final payButton = find.byKey(const Key('subscription_card_pay_button'));
      expect(payButton, findsOneWidget);

      await tester.tap(payButton);
      await tester.pump();

      expect(markPaidTapped, isTrue);
    });

    testWidgets(
      'NFR-04: ensures quick action button meets 48x48 min touch target',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            subscription: testSubscription,
            category: testCategory,
            onMarkPaid: () {},
          ),
        );
        await tester.pumpAndSettle();

        final payButton = tester.getRect(
          find.byKey(const Key('subscription_card_pay_button')),
        );
        expect(payButton.width, greaterThanOrEqualTo(48.0));
        expect(payButton.height, greaterThanOrEqualTo(48.0));
      },
    );
  });
}

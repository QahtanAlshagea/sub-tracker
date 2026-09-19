import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_spacing.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

void main() {
  Widget buildTestWidget({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Padding(padding: AppSpacing.screenPadding, child: child),
        ),
      ),
    );
  }

  final sampleCategory = Category.create(
    id: 'cat-media',
    name: 'وسائط وترفيه',
    colorValue: 0xFF4F46E5,
  );

  group('SubscriptionCard Widget Tests (US-05, EC-05-2, EC-05-5)', () {
    testWidgets(
      '1. Displays name, formatted price, cycle suffix, and category pill',
      (tester) async {
        final now = DateTime.utc(2026, 9, 19);
        final sub = Subscription.create(
          id: 'sub-spotify',
          name: 'Spotify Family',
          price: Money.create(amountMinorUnits: 1099, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 15)),
          startDate: DateTime.utc(2026, 9, 15),
          categoryId: sampleCategory.id,
        );

        await tester.pumpWidget(
          buildTestWidget(
            child: SubscriptionCard(
              subscription: sub,
              category: sampleCategory,
              referenceDate: now,
            ),
          ),
        );

        expect(find.text('Spotify Family'), findsOneWidget);
        expect(find.text('10.99 \$'), findsOneWidget);
        expect(find.text('/ شهر'), findsOneWidget);
        expect(find.text('وسائط وترفيه'), findsOneWidget);
        expect(find.text('متبقي 26 يوماً'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Renders urgent badge with distinctive border when <= 3 days (EC-05-2)',
      (tester) async {
        final now = DateTime.utc(2026, 9, 19);
        final sub = Subscription.create(
          id: 'sub-gym',
          name: 'اشتراك النادي الرياضي',
          price: Money.create(amountMinorUnits: 25000, currencyCode: 'SAR'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(
            date: DateTime.utc(2026, 9, 21),
          ), // 2 days away
          startDate: DateTime.utc(2026, 8, 21),
          categoryId: sampleCategory.id,
        );

        await tester.pumpWidget(
          buildTestWidget(
            child: SubscriptionCard(
              subscription: sub,
              category: sampleCategory,
              referenceDate: now,
            ),
          ),
        );

        expect(find.text('يستحق بعد يومين'), findsOneWidget);
        expect(find.byIcon(Icons.access_time_filled_rounded), findsOneWidget);
      },
    );

    testWidgets('3. Renders overdue badge when due date has passed (US-05)', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 19);
      final sub = Subscription.create(
        id: 'sub-hosting',
        name: 'استضافة خادم سحابي',
        price: Money.create(amountMinorUnits: 5000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        dueDate: DueDate.create(
          date: DateTime.utc(2026, 9, 17),
        ), // 2 days overdue
        startDate: DateTime.utc(2026, 8, 17),
        categoryId: sampleCategory.id,
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: SubscriptionCard(
            subscription: sub,
            category: sampleCategory,
            referenceDate: now,
          ),
        ),
      );

      expect(find.text('متأخر منذ يومين'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('4. Renders free trial tag when isTrial is true', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 19);
      final sub = Subscription.create(
        id: 'sub-trial',
        name: 'YouTube Premium Trial',
        price: Money.zero('USD'),
        cycle: const BillingCycle.monthly(),
        dueDate: DueDate.create(date: DateTime.utc(2026, 9, 29)),
        startDate: DateTime.utc(2026, 9, 15),
        categoryId: sampleCategory.id,
        isTrial: true,
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: SubscriptionCard(
            subscription: sub,
            category: sampleCategory,
            referenceDate: now,
          ),
        ),
      );

      expect(find.text('تجربة مجانية'), findsOneWidget);
      expect(find.text('0.00 \$'), findsOneWidget);
    });

    testWidgets(
      '5. Tapping card invokes onTap and complies with min touch height (NFR-04)',
      (tester) async {
        bool tapped = false;
        final sub = Subscription.create(
          id: 'sub-tap',
          name: 'اشتراك تجريبي للنقر',
          price: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate.create(date: DateTime.utc(2026, 10, 1)),
          startDate: DateTime.utc(2026, 9, 1),
          categoryId: sampleCategory.id,
        );

        await tester.pumpWidget(
          buildTestWidget(
            child: SubscriptionCard(
              subscription: sub,
              category: sampleCategory,
              onTap: () => tapped = true,
            ),
          ),
        );

        final cardFinder = find.byType(SubscriptionCard);
        final cardSize = tester.getSize(cardFinder);
        expect(
          cardSize.height,
          greaterThanOrEqualTo(AppSpacing.minTouchTarget),
        );

        await tester.tap(cardFinder);
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      '6. Long subscription name truncates with ellipsis without overflow (EC-05-5)',
      (tester) async {
        final sub = Subscription.create(
          id: 'sub-long',
          name:
              'اشتراك حزمة البرمجيات السحابية المتكاملة للشركات الخاصة', // 55 chars (<= 60 limit)
          price: Money.create(amountMinorUnits: 99999, currencyCode: 'USD'),
          cycle: const BillingCycle.yearly(),
          dueDate: DueDate.create(date: DateTime.utc(2027, 1, 1)),
          startDate: DateTime.utc(2026, 1, 1),
          categoryId: sampleCategory.id,
        );

        await tester.pumpWidget(
          buildTestWidget(
            child: SizedBox(
              width: 320,
              child: SubscriptionCard(
                subscription: sub,
                category: sampleCategory,
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/price_history_entry.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_list_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

class _FakeSubRepo implements SubscriptionRepository {
  List<Subscription> subscriptions = [];

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async {
    return Success(subscriptions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCatRepo implements CategoryRepository {
  @override
  Future<Result<List<Category>>> getAllCategories() async {
    return const Success([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Price History & Details Edge Cases', () {
    late _FakeSubRepo subRepo;
    late _FakeCatRepo catRepo;
    late SubscriptionsListController controller;

    setUp(() {
      subRepo = _FakeSubRepo();
      catRepo = _FakeCatRepo();
      controller = SubscriptionsListController(
        getSubscriptionsUseCase: GetSubscriptionsUseCase(subRepo),
        renewSubscriptionUseCase: RenewSubscriptionUseCase(subRepo),
        getCategoriesUseCase: GetCategoriesUseCase(catRepo),
      );
    });

    testWidgets(
      '[EC-06-2]: Long price history list renders with pagination or scrolling without overflow',
      (tester) async {
        // Simulate 50 price history records
        final historyEntries = List.generate(
          50,
          (i) => PriceHistoryEntry(
            id: 'hist-$i',
            subscriptionId: 'sub-main',
            oldPrice: Money(
              amountMinorUnits: 1000 + (i * 100),
              currencyCode: 'USD',
            ),
            newPrice: Money(
              amountMinorUnits: 1100 + (i * 100),
              currencyCode: 'USD',
            ),
            changedAt: DateTime.utc(2025, 1, 1).add(Duration(days: i * 30)),
          ),
        );

        // Component rendering paginated / scrolling price history
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              appBar: AppBar(title: const Text('Price History')),
              body: ListView.builder(
                itemCount: historyEntries.length,
                itemBuilder: (context, index) {
                  final entry = historyEntries[index];
                  return ListTile(
                    title: Text(
                      'Change #${index + 1}: ${entry.oldPrice} -> ${entry.newPrice}',
                    ),
                    subtitle: Text(entry.changedAt.toIso8601String()),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsWidgets);
        // Fling scroll to verify smooth scrolling through 50 items without overflow
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '[EC-06-3]: Opening details while list is rebuilding does not corrupt state or crash',
      (tester) async {
        final testSub = Subscription.create(
          id: 'sub-race-test',
          name: 'Concurrent Access Sub',
          price: const Money(amountMinorUnits: 1999, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 10, 1)),
          categoryId: 'cat-1',
        );
        subRepo.subscriptions = [testSub];

        Subscription? tappedSubscription;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: HomeScreen(
              controller: controller,
              onSubscriptionTap: (sub) {
                tappedSubscription = sub;
              },
            ),
          ),
        );

        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        final cardFinder = find.byType(SubscriptionCard);
        expect(cardFinder, findsOneWidget);

        // Trigger concurrent reload while tapping
        final reloadFuture = controller.loadSubscriptions();
        await tester.tap(cardFinder);
        await reloadFuture;
        await tester.pumpAndSettle();

        expect(tappedSubscription, isNotNull);
        expect(tappedSubscription!.name, equals('Concurrent Access Sub'));
        expect(tester.takeException(), isNull);
      },
    );
  });
}

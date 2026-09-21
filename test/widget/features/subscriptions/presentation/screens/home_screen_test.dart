import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/core/error/failures.dart';
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
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_empty_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_error_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_loading_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

// Fake implementations for testing all 4 view states
class FakeSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> subscriptionsToReturn = [];
  bool shouldFail = false;

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async {
    if (shouldFail) {
      return const Error(DatabaseFailure('Failed to load subscriptions'));
    }
    return Success(subscriptionsToReturn);
  }

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async {
    final sub = subscriptionsToReturn.firstWhere((s) => s.id == id);
    return Success(sub);
  }

  @override
  Future<Result<Subscription>> updateSubscription(
    Subscription subscription,
  ) async {
    return Success(subscription);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCategoryRepository implements CategoryRepository {
  @override
  Future<Result<List<Category>>> getAllCategories() async {
    return const Success([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('HomeScreen Four View States & Interactions', () {
    late FakeSubscriptionRepository fakeSubRepo;
    late FakeCategoryRepository fakeCatRepo;
    late SubscriptionsListController controller;

    setUp(() {
      fakeSubRepo = FakeSubscriptionRepository();
      fakeCatRepo = FakeCategoryRepository();
      controller = SubscriptionsListController(
        getSubscriptionsUseCase: GetSubscriptionsUseCase(fakeSubRepo),
        renewSubscriptionUseCase: RenewSubscriptionUseCase(fakeSubRepo),
        getCategoriesUseCase: GetCategoriesUseCase(fakeCatRepo),
      );
    });

    Widget createWidget({VoidCallback? onAddSubscription}) {
      return MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: HomeScreen(
          controller: controller,
          onAddSubscription: onAddSubscription ?? () {},
        ),
      );
    }

    testWidgets('1. Loading State: displays AppLoadingView while fetching', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      // Before loading completes, shows loading state
      expect(find.byType(AppLoadingView), findsOneWidget);
    });

    testWidgets(
      '2. Empty State: US-05 / EC-05-1 displays designed AppEmptyView when zero records exist',
      (tester) async {
        fakeSubRepo.subscriptionsToReturn = [];
        await tester.pumpWidget(createWidget());
        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        expect(find.byType(AppEmptyView), findsOneWidget);
        expect(find.text('لا توجد اشتراكات مضافة بعد'), findsOneWidget);
        expect(find.text('إضافة أول اشتراك'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Error State: US-05 / EC-05-4 displays AppErrorView with retry button when read fails',
      (tester) async {
        fakeSubRepo.shouldFail = true;
        await tester.pumpWidget(createWidget());
        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        expect(find.byType(AppErrorView), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);

        // Now fix failure and tap retry
        fakeSubRepo.shouldFail = false;
        fakeSubRepo.subscriptionsToReturn = [
          Subscription.create(
            id: 'sub-1',
            name: 'Netflix',
            price: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: DateTime.utc(2026, 9, 1),
            dueDate: DueDate(DateTime.utc(2026, 10, 1), 1),
            categoryId: 'cat-1',
          ),
        ];

        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();

        expect(find.byType(AppErrorView), findsNothing);
        expect(find.byType(SubscriptionCard), findsOneWidget);
      },
    );

    testWidgets('4. Data State: renders SubscriptionCard for active records', (
      tester,
    ) async {
      fakeSubRepo.subscriptionsToReturn = [
        Subscription.create(
          id: 'sub-1',
          name: 'Spotify',
          price: Money.create(amountMinorUnits: 999, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 9, 1),
          dueDate: DueDate(DateTime.utc(2026, 10, 1), 1),
          categoryId: 'cat-1',
        ),
      ];

      await tester.pumpWidget(createWidget());
      await controller.loadSubscriptions();
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionCard), findsOneWidget);
      expect(find.text('Spotify'), findsOneWidget);
    });

    testWidgets(
      'NFR-04: Floating Action Button (+) has min 48x48 touch target',
      (tester) async {
        fakeSubRepo.subscriptionsToReturn = [];
        await tester.pumpWidget(createWidget());
        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        final fabFinder = find.byKey(const Key('home_fab_add'));
        expect(fabFinder, findsOneWidget);

        final fabRect = tester.getRect(fabFinder);
        expect(fabRect.width, greaterThanOrEqualTo(48.0));
        expect(fabRect.height, greaterThanOrEqualTo(48.0));
      },
    );
  });
}

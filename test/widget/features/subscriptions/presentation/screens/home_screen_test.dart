import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/payment_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/obligation_type.dart';
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

class FakePaymentRepository implements PaymentRepository {
  Map<String, int> paymentCounts = {};

  @override
  Future<Result<Map<String, int>>> getAllPaymentCounts() async {
    return Success(paymentCounts);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('HomeScreen Four View States & Interactions', () {
    late FakeSubscriptionRepository fakeSubRepo;
    late FakeCategoryRepository fakeCatRepo;
    late FakePaymentRepository fakePaymentRepo;
    late SubscriptionsListController controller;

    setUp(() {
      fakeSubRepo = FakeSubscriptionRepository();
      fakeCatRepo = FakeCategoryRepository();
      fakePaymentRepo = FakePaymentRepository();
      controller = SubscriptionsListController(
        getSubscriptionsUseCase: GetSubscriptionsUseCase(fakeSubRepo),
        renewSubscriptionUseCase: RenewSubscriptionUseCase(fakeSubRepo),
        getCategoriesUseCase: GetCategoriesUseCase(fakeCatRepo),
        paymentRepository: fakePaymentRepo,
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

    testWidgets(
      '5. Filter Chips: filters subscriptions by due soon and settled',
      (tester) async {
        final now = DateTime.now();
        fakeSubRepo.subscriptionsToReturn = [
          Subscription.create(
            id: 'sub-due',
            name: 'Due Soon Sub',
            price: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: now.subtract(const Duration(days: 30)),
            dueDate: DueDate(now.add(const Duration(days: 2)), now.day),
            categoryId: 'cat-1',
          ),
          Subscription.create(
            id: 'sub-settled',
            name: 'Settled Sub',
            price: Money.create(amountMinorUnits: 2000, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: now.subtract(const Duration(days: 10)),
            dueDate: DueDate(now.add(const Duration(days: 25)), now.day),
            categoryId: 'cat-1',
          ),
        ];
        fakePaymentRepo.paymentCounts = {'sub-settled': 1};

        await tester.pumpWidget(createWidget());
        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        // 1. All tab (default)
        expect(find.text('Due Soon Sub'), findsOneWidget);
        expect(find.text('Settled Sub'), findsOneWidget);

        // 2. Tap Due Soon chip
        await tester.tap(find.byKey(const Key('filter_chip_due_soon')));
        await tester.pumpAndSettle();

        expect(find.text('Due Soon Sub'), findsOneWidget);
        expect(find.text('Settled Sub'), findsNothing);

        // 3. Tap Settled chip
        await tester.tap(find.byKey(const Key('filter_chip_settled')));
        await tester.pumpAndSettle();

        expect(find.text('Due Soon Sub'), findsNothing);
        expect(find.text('Settled Sub'), findsOneWidget);
      },
    );

    testWidgets('6. Overdue Filter: displays only overdue commitments', (
      tester,
    ) async {
      final now = DateTime.now();
      fakeSubRepo.subscriptionsToReturn = [
        Subscription.create(
          id: 'sub-active',
          name: 'Active Sub',
          price: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: now.subtract(const Duration(days: 10)),
          dueDate: DueDate(now.add(const Duration(days: 20)), now.day),
          categoryId: 'cat-1',
        ),
        Subscription.create(
          id: 'sub-overdue',
          name: 'Overdue Rent',
          price: Money.create(amountMinorUnits: 50000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: now.subtract(const Duration(days: 40)),
          dueDate: DueDate(now.subtract(const Duration(days: 5)), now.day),
          categoryId: 'cat-1',
          obligationType: ObligationType.rent,
        ),
      ];

      await tester.pumpWidget(createWidget());
      await controller.loadSubscriptions();
      await tester.pumpAndSettle();

      // Tap Overdue chip
      final overdueChip = find.byKey(const Key('filter_chip_overdue'));
      await tester.ensureVisible(overdueChip);
      await tester.tap(overdueChip);
      await tester.pumpAndSettle();

      expect(find.text('Overdue Rent'), findsOneWidget);
      expect(find.text('Active Sub'), findsNothing);
    });

    testWidgets(
      '7. Search Bar: filters commitments in real-time by search query',
      (tester) async {
        final now = DateTime.now();
        fakeSubRepo.subscriptionsToReturn = [
          Subscription.create(
            id: 'sub-1',
            name: 'Netflix Premium',
            price: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: now,
            dueDate: DueDate(now.add(const Duration(days: 15)), now.day),
            categoryId: 'cat-1',
          ),
          Subscription.create(
            id: 'sub-2',
            name: 'Electricity Bill',
            price: Money.create(amountMinorUnits: 8000, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: now,
            dueDate: DueDate(now.add(const Duration(days: 5)), now.day),
            categoryId: 'cat-1',
            obligationType: ObligationType.bill,
          ),
        ];

        await tester.pumpWidget(createWidget());
        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        expect(find.text('Netflix Premium'), findsOneWidget);
        expect(find.text('Electricity Bill'), findsOneWidget);

        // Enter search text
        await tester.enterText(
          find.byKey(const Key('home_search_field')),
          'elect',
        );
        await tester.pumpAndSettle();

        expect(find.text('Electricity Bill'), findsOneWidget);
        expect(find.text('Netflix Premium'), findsNothing);
      },
    );

    testWidgets(
      '8. Obligation Type Chips: filters subscriptions by obligation type',
      (tester) async {
        final now = DateTime.now();
        fakeSubRepo.subscriptionsToReturn = [
          Subscription.create(
            id: 'sub-1',
            name: 'Spotify Music',
            price: Money.create(amountMinorUnits: 999, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: now,
            dueDate: DueDate(now.add(const Duration(days: 10)), now.day),
            categoryId: 'cat-1',
            obligationType: ObligationType.subscription,
          ),
          Subscription.create(
            id: 'sub-2',
            name: 'Apartment Rent',
            price: Money.create(amountMinorUnits: 50000, currencyCode: 'USD'),
            cycle: const BillingCycle.monthly(),
            startDate: now,
            dueDate: DueDate(now.add(const Duration(days: 10)), now.day),
            categoryId: 'cat-1',
            obligationType: ObligationType.rent,
          ),
        ];

        await tester.pumpWidget(createWidget());
        await controller.loadSubscriptions();
        await tester.pumpAndSettle();

        // Tap Rent type filter
        await tester.tap(find.byKey(const Key('type_filter_rent')));
        await tester.pumpAndSettle();

        expect(find.text('Apartment Rent'), findsOneWidget);
        expect(find.text('Spotify Music'), findsNothing);

        // Tap All type filter
        await tester.tap(find.byKey(const Key('type_filter_all')));
        await tester.pumpAndSettle();

        expect(find.text('Apartment Rent'), findsOneWidget);
        expect(find.text('Spotify Music'), findsOneWidget);
      },
    );
  });
}

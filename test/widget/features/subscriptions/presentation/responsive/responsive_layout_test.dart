import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_category_distribution_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_highest_cost_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_upcoming_projections_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/add_edit_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/summary_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/add_edit_subscription_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_list_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/summary_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/metric_card.dart';

class ResponsiveFakeSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> subscriptions = [];

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async => Success(subscriptions);

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async =>
      Success(subscriptions.firstWhere((s) => s.id == id));

  @override
  Future<Result<Subscription>> createSubscription(
    Subscription subscription,
  ) async {
    subscriptions.add(subscription);
    return Success(subscription);
  }

  @override
  Future<Result<Subscription>> updateSubscription(
    Subscription subscription,
  ) async => Success(subscription);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ResponsiveFakeCategoryRepository implements CategoryRepository {
  List<Category> categories = [];

  @override
  Future<Result<List<Category>>> getAllCategories() async =>
      Success(categories);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Responsive Layout Tests (C-17 / flutter-build-responsive-layout)', () {
    late ResponsiveFakeSubscriptionRepository fakeSubRepo;
    late ResponsiveFakeCategoryRepository fakeCatRepo;

    final testSub = Subscription(
      id: 'sub-resp-1',
      name: 'Google One 2TB',
      price: const Money(amountMinorUnits: 999, currencyCode: 'USD'),
      cycle: const BillingCycle.monthly(),
      startDate: DateTime.utc(2026, 1, 1),
      dueDate: DueDate(DateTime.utc(2026, 10, 15)),
      status: SubscriptionStatus.active,
      categoryId: 'cat-1',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() {
      fakeSubRepo = ResponsiveFakeSubscriptionRepository();
      fakeCatRepo = ResponsiveFakeCategoryRepository();
      fakeSubRepo.subscriptions = [testSub];
      fakeCatRepo.categories = [
        Category(
          id: 'cat-1',
          name: 'Cloud',
          colorValue: 0xFF2196F3,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ];
    });

    testWidgets(
      '1. HomeScreen switches between ListView (<600dp) and GridView (>=600dp)',
      (tester) async {
        final controller = SubscriptionsListController(
          getSubscriptionsUseCase: GetSubscriptionsUseCase(fakeSubRepo),
          renewSubscriptionUseCase: RenewSubscriptionUseCase(fakeSubRepo),
          getCategoriesUseCase: GetCategoriesUseCase(fakeCatRepo),
        );
        await controller.loadSubscriptions();

        // Narrow screen (Phone: 400x800)
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            theme: AppTheme.light,
            home: HomeScreen(controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        // On mobile width (<600 dp), ListView should be present, GridView absent
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(GridView), findsNothing);

        // Resize to Tablet / Wide window (900x1200)
        tester.view.physicalSize = const Size(900, 1200);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            theme: AppTheme.light,
            home: HomeScreen(controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        // On tablet width (>=600 dp), GridView should be present
        expect(find.byType(GridView), findsOneWidget);
      },
    );

    testWidgets(
      '2. SummaryScreen renders MetricCards responsively without overflow across breakpoints',
      (tester) async {
        final summaryController = SummaryController(
          getMonthlySummaryUseCase: GetMonthlySummaryUseCase(fakeSubRepo),
          getUpcomingProjectionsUseCase: GetUpcomingProjectionsUseCase(
            fakeSubRepo,
          ),
          getCategoryDistributionUseCase: GetCategoryDistributionUseCase(
            subscriptionRepository: fakeSubRepo,
            categoryRepository: fakeCatRepo,
          ),
          getHighestCostSubscriptionUseCase: GetHighestCostSubscriptionUseCase(
            fakeSubRepo,
          ),
        );
        await summaryController.loadSummary(preferredCurrency: 'USD');

        // Test wide screen (900x1200)
        tester.view.physicalSize = const Size(900, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            theme: AppTheme.light,
            home: SummaryScreen(controller: summaryController),
          ),
        );
        await tester.pumpAndSettle();

        // All 4 MetricCards should render without overflow
        expect(find.byType(MetricCard), findsNWidgets(4));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '3. AddEditSubscriptionScreen constrains form width to centered 600dp on large screens',
      (tester) async {
        final addEditController = AddEditSubscriptionController(
          createSubscriptionUseCase: CreateSubscriptionUseCase(fakeSubRepo),
          updateSubscriptionUseCase: UpdateSubscriptionUseCase(fakeSubRepo),
          getSubscriptionByIdUseCase: GetSubscriptionByIdUseCase(fakeSubRepo),
          getCategoriesUseCase: GetCategoriesUseCase(fakeCatRepo),
        );
        await addEditController.initialize();

        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            theme: AppTheme.light,
            home: AddEditSubscriptionScreen(controller: addEditController),
          ),
        );
        await tester.pumpAndSettle();

        // Check that ConstrainedBox limits form width
        final constrainedBoxes = tester.widgetList<ConstrainedBox>(
          find.byType(ConstrainedBox),
        );
        final formConstraint = constrainedBoxes.firstWhere(
          (b) => b.constraints.maxWidth == 600.0,
        );
        expect(formConstraint, isNotNull);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

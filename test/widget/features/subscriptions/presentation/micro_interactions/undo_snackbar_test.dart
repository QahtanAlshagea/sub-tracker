import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/move_subscription_to_trash_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/restore_subscription_from_trash_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/subscriptions_list_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_empty_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_card.dart';

class MockSafeDeletionSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> activeSubscriptions = [];
  List<Subscription> trashedSubscriptions = [];
  int deleteCallCount = 0;

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async {
    if (status == SubscriptionStatus.inTrash) {
      return Success(trashedSubscriptions);
    }
    return Success(activeSubscriptions);
  }

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async {
    final active = activeSubscriptions.where((s) => s.id == id);
    if (active.isNotEmpty) return Success(active.first);

    final trashed = trashedSubscriptions.where((s) => s.id == id);
    if (trashed.isNotEmpty) return Success(trashed.first);

    return const Error(DatabaseFailure('Not found'));
  }

  @override
  Future<Result<void>> moveToTrash(String id) async {
    deleteCallCount++;
    final sub = activeSubscriptions.firstWhere((s) => s.id == id);
    activeSubscriptions.removeWhere((s) => s.id == id);
    trashedSubscriptions.add(sub.copyWith(status: SubscriptionStatus.inTrash));
    return const Success(null);
  }

  @override
  Future<Result<void>> restoreFromTrash(String id) async {
    final sub = trashedSubscriptions.firstWhere((s) => s.id == id);
    trashedSubscriptions.removeWhere((s) => s.id == id);
    activeSubscriptions.add(sub.copyWith(status: SubscriptionStatus.active));
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<Result<List<Category>>> getAllCategories() async => const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Safe Deletion & Undo SnackBar Micro-interactions (US-12 / C-17)', () {
    late MockSafeDeletionSubscriptionRepository fakeRepo;
    late MockCategoryRepository fakeCatRepo;
    late SubscriptionsListController controller;

    final sub1 = Subscription(
      id: 'sub-1',
      name: 'Netflix Premium',
      price: const Money(amountMinorUnits: 5400, currencyCode: 'USD'),
      cycle: const BillingCycle.monthly(),
      startDate: DateTime.utc(2026, 1, 1),
      dueDate: DueDate(DateTime.utc(2026, 10, 1)),
      status: SubscriptionStatus.active,
      categoryId: 'cat-1',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    final sub2 = Subscription(
      id: 'sub-2',
      name: 'Spotify Family',
      price: const Money(amountMinorUnits: 1600, currencyCode: 'USD'),
      cycle: const BillingCycle.monthly(),
      startDate: DateTime.utc(2026, 1, 1),
      dueDate: DueDate(DateTime.utc(2026, 10, 5)),
      status: SubscriptionStatus.active,
      categoryId: 'cat-1',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        theme: AppTheme.light,
        home: HomeScreen(controller: controller),
      );
    }

    setUp(() {
      fakeRepo = MockSafeDeletionSubscriptionRepository();
      fakeCatRepo = MockCategoryRepository();
      controller = SubscriptionsListController(
        getSubscriptionsUseCase: GetSubscriptionsUseCase(fakeRepo),
        renewSubscriptionUseCase: RenewSubscriptionUseCase(fakeRepo),
        getCategoriesUseCase: GetCategoriesUseCase(fakeCatRepo),
        moveSubscriptionToTrashUseCase: MoveSubscriptionToTrashUseCase(
          fakeRepo,
        ),
        restoreSubscriptionFromTrashUseCase:
            RestoreSubscriptionFromTrashUseCase(fakeRepo),
      );
    });

    testWidgets(
      '1. [EC-12-3] Dialog double-tap prevention: tapping delete button multiple times only triggers deletion once',
      (tester) async {
        fakeRepo.activeSubscriptions = [sub1];
        await controller.loadSubscriptions();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SubscriptionCard), findsOneWidget);

        // Tap delete icon button on card
        final deleteBtn = find.byKey(
          const Key('subscription_card_delete_button_sub-1'),
        );
        expect(deleteBtn, findsOneWidget);
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        // Dialog should be displayed with subscription name
        expect(find.textContaining('Netflix Premium'), findsWidgets);
        final confirmBtn = find.byKey(
          const Key('confirm_delete_dialog_button'),
        );
        expect(confirmBtn, findsOneWidget);

        // Tap delete button rapidly twice (simulating double-tap [EC-12-3])
        await tester.tap(confirmBtn);
        await tester.tap(confirmBtn, warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(fakeRepo.deleteCallCount, equals(1));
      },
    );

    testWidgets(
      '2. [EC-12-1] Undo SnackBar appears with 5s duration and allows restoring subscription',
      (tester) async {
        fakeRepo.activeSubscriptions = [sub1, sub2];
        await controller.loadSubscriptions();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SubscriptionCard), findsNWidgets(2));

        // Delete sub1
        await tester.tap(
          find.byKey(const Key('subscription_card_delete_button_sub-1')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('confirm_delete_dialog_button')));
        await tester.pumpAndSettle();

        // sub1 should be gone from the list
        expect(
          find.byKey(const Key('subscription_card_delete_button_sub-1')),
          findsNothing,
        );
        expect(find.byType(SnackBar), findsOneWidget);

        // Tap "تراجع" (Undo) on the SnackBar
        final undoBtn = find.text('تراجع');
        expect(undoBtn, findsOneWidget);
        await tester.tap(undoBtn);
        await tester.pumpAndSettle();

        // sub1 should be restored back to active list
        expect(
          find.byKey(const Key('subscription_card_delete_button_sub-1')),
          findsOneWidget,
        );
        expect(fakeRepo.activeSubscriptions.length, equals(2));
      },
    );

    testWidgets(
      '3. [EC-12-2] Consecutive deletions handle undo actions cleanly without conflicting state',
      (tester) async {
        fakeRepo.activeSubscriptions = [sub1, sub2];
        await controller.loadSubscriptions();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete sub1
        await tester.tap(
          find.byKey(const Key('subscription_card_delete_button_sub-1')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_delete_dialog_button')));
        await tester.pumpAndSettle();

        // Delete sub2 immediately
        await tester.tap(
          find.byKey(const Key('subscription_card_delete_button_sub-2')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_delete_dialog_button')));
        await tester.pumpAndSettle();

        // Active list should be empty and SnackBar active
        expect(find.byType(SnackBar), findsOneWidget);
        expect(fakeRepo.activeSubscriptions.isEmpty, isTrue);
      },
    );

    testWidgets(
      '4. [EC-12-4] Deleting last subscription displays AppEmptyView immediately',
      (tester) async {
        fakeRepo.activeSubscriptions = [sub1];
        await controller.loadSubscriptions();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SubscriptionCard), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('subscription_card_delete_button_sub-1')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_delete_dialog_button')));
        await tester.pumpAndSettle();

        // Immediate transition to AppEmptyView
        expect(find.byType(AppEmptyView), findsOneWidget);
        expect(find.byType(SubscriptionCard), findsNothing);
      },
    );
  });
}

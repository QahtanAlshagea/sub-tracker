import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/accessibility/accessibility_widgets.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/add_edit_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/add_edit_subscription_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_error_view.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/app_loading_view.dart';

class FakeSubscriptionRepository implements SubscriptionRepository {
  final Map<String, Subscription> storage = {};
  bool shouldFailGet = false;
  bool shouldFailSave = false;

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async {
    if (shouldFailGet) {
      return const Error(NotFoundFailure('الاشتراك غير موجود'));
    }
    final sub = storage[id];
    if (sub == null) return const Error(NotFoundFailure('غير موجود'));
    return Success(sub);
  }

  @override
  Future<Result<List<Subscription>>> getAllSubscriptions({
    SubscriptionStatus? status,
    String? categoryId,
  }) async {
    return Success(storage.values.toList());
  }

  @override
  Future<Result<Subscription>> createSubscription(
    Subscription subscription,
  ) async {
    if (shouldFailSave) {
      return const Error(DatabaseFailure('فشل حفظ الاشتراك'));
    }
    storage[subscription.id] = subscription;
    return Success(subscription);
  }

  @override
  Future<Result<Subscription>> updateSubscription(
    Subscription subscription,
  ) async {
    if (shouldFailSave) {
      return const Error(DatabaseFailure('فشل تحديث الاشتراك'));
    }
    storage[subscription.id] = subscription;
    return Success(subscription);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCategoryRepository implements CategoryRepository {
  List<Category> categories = [
    Category(
      id: 'cat-1',
      name: 'الترفيه',
      colorValue: 0xFFFF0000,
      iconCode: 'movie',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    Category(
      id: 'cat-2',
      name: 'العمل والإنتاجية',
      colorValue: 0xFF00FF00,
      iconCode: 'work',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
  ];

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    return Success(categories);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AddEditSubscriptionScreen View States & Behavior', () {
    late FakeSubscriptionRepository fakeSubRepo;
    late FakeCategoryRepository fakeCatRepo;
    late AddEditSubscriptionController controller;

    setUp(() {
      fakeSubRepo = FakeSubscriptionRepository();
      fakeCatRepo = FakeCategoryRepository();
      controller = AddEditSubscriptionController(
        createSubscriptionUseCase: CreateSubscriptionUseCase(fakeSubRepo),
        updateSubscriptionUseCase: UpdateSubscriptionUseCase(fakeSubRepo),
        getSubscriptionByIdUseCase: GetSubscriptionByIdUseCase(fakeSubRepo),
        getCategoriesUseCase: GetCategoriesUseCase(fakeCatRepo),
      );
    });

    Widget createWidget({String? subscriptionId}) {
      return MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: AddEditSubscriptionScreen(
          controller: controller,
          subscriptionId: subscriptionId,
        ),
      );
    }

    testWidgets(
      '1. Loading State: displays AppLoadingView while initializing',
      (tester) async {
        await tester.pumpWidget(createWidget());
        expect(find.byType(AppLoadingView), findsOneWidget);
      },
    );

    testWidgets(
      '2. Error State: displays AppErrorView with retry when subscription not found in edit mode',
      (tester) async {
        fakeSubRepo.shouldFailGet = true;
        await tester.pumpWidget(
          createWidget(subscriptionId: 'non-existent-id'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppErrorView), findsOneWidget);
        expect(find.text('الاشتراك غير موجود'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Add Mode: Form renders and client-side validation prevents submitting empty fields',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('add_edit_name_field')), findsOneWidget);
        expect(find.byKey(const Key('add_edit_price_field')), findsOneWidget);
        expect(find.byKey(const Key('add_edit_save_button')), findsOneWidget);

        // Tap save without filling required fields
        await tester.tap(find.byKey(const Key('add_edit_save_button')));
        await tester.pumpAndSettle();

        // Expect validation error messages
        expect(find.text('يرجى إدخال اسم الاشتراك'), findsOneWidget);
        expect(find.text('يجب أن يكون المبلغ أكبر من صفر'), findsOneWidget);
        expect(fakeSubRepo.storage.isEmpty, isTrue);
      },
    );

    testWidgets(
      '4. Add Mode: Valid inputs persist subscription to repository',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('add_edit_name_field')),
          'Netflix Premium',
        );
        await tester.enterText(
          find.byKey(const Key('add_edit_price_field')),
          '14.99',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('add_edit_save_button')));
        await tester.pumpAndSettle();

        expect(fakeSubRepo.storage.length, equals(1));
        final saved = fakeSubRepo.storage.values.first;
        expect(saved.name, equals('Netflix Premium'));
        expect(saved.price.amountMinorUnits, equals(1499));
        expect(saved.price.currencyCode, equals('USD'));
      },
    );

    testWidgets('5. Edit Mode: Pre-populates existing subscription data', (
      tester,
    ) async {
      final existingSub = Subscription.create(
        id: 'sub-edit-1',
        name: 'Spotify Family',
        price: const Money(amountMinorUnits: 999, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        dueDate: DueDate(DateTime.utc(2026, 2, 1)),
        categoryId: 'cat-1',
        status: SubscriptionStatus.active,
      );
      fakeSubRepo.storage['sub-edit-1'] = existingSub;

      await tester.pumpWidget(createWidget(subscriptionId: 'sub-edit-1'));
      await tester.pumpAndSettle();

      expect(find.text('Spotify Family'), findsOneWidget);
      expect(find.text('9.99'), findsOneWidget);
      expect(find.text('تعديل الاشتراك'), findsOneWidget);
    });

    testWidgets('6. NFR-04: Save button meets minimum 48x48 dp touch target', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final targetFinder = find.ancestor(
        of: find.byKey(const Key('add_edit_save_button')),
        matching: find.byType(MinTouchTarget),
      );
      expect(targetFinder, findsOneWidget);
      final size = tester.getSize(targetFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
      '7. Reminder controls: toggles reminders and allows lead days selection',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();

        final reminderSwitch = find.byKey(
          const Key('add_edit_reminder_switch'),
        );
        expect(reminderSwitch, findsOneWidget);

        // Toggling switch off hides lead days chips
        await tester.tap(reminderSwitch);
        await tester.pumpAndSettle();
        expect(find.text('تنبيهي قبل موعد الفاتورة بـ:'), findsNothing);

        // Toggling switch on displays lead days chips
        await tester.tap(reminderSwitch);
        await tester.pumpAndSettle();
        expect(find.text('تنبيهي قبل موعد الفاتورة بـ:'), findsOneWidget);
        expect(find.text('يومين'), findsOneWidget);
      },
    );
  });
}

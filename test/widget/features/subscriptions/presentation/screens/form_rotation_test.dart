import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/add_edit_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/add_edit_subscription_controller.dart';

class RotationFakeSubscriptionRepository implements SubscriptionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RotationFakeCategoryRepository implements CategoryRepository {
  @override
  Future<Result<List<Category>>> getAllCategories() async {
    return Success([
      Category(
        id: 'cat-stream',
        name: 'Streaming',
        colorValue: 0xFF9C27B0,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group(
    'Form State Preservation across Rotation / Orientation (EC-01-7, EC-40-2)',
    () {
      late RotationFakeSubscriptionRepository subRepo;
      late RotationFakeCategoryRepository catRepo;
      late AddEditSubscriptionController controller;

      setUp(() {
        subRepo = RotationFakeSubscriptionRepository();
        catRepo = RotationFakeCategoryRepository();
        controller = AddEditSubscriptionController(
          createSubscriptionUseCase: CreateSubscriptionUseCase(subRepo),
          updateSubscriptionUseCase: UpdateSubscriptionUseCase(subRepo),
          getSubscriptionByIdUseCase: GetSubscriptionByIdUseCase(subRepo),
          getCategoriesUseCase: GetCategoriesUseCase(catRepo),
        );
      });

      testWidgets(
        '[EC-01-7] & [EC-40-2] Entered form data survives screen rotation without loss or error',
        (tester) async {
          await controller.initialize();

          // Start in Portrait mode: 400 x 800
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('ar'),
              theme: AppTheme.light,
              home: AddEditSubscriptionScreen(controller: controller),
            ),
          );
          await tester.pumpAndSettle();

          // 1. Enter values into form fields in portrait
          await tester.enterText(
            find.byKey(const Key('add_edit_name_field')),
            'Disney+ Premium Annual',
          );
          await tester.enterText(
            find.byKey(const Key('add_edit_price_field')),
            '139.99',
          );
          await tester.pumpAndSettle();

          expect(find.text('Disney+ Premium Annual'), findsOneWidget);
          expect(find.text('139.99'), findsOneWidget);

          // 2. Rotate device to Landscape: 800 x 400
          tester.view.physicalSize = const Size(800, 400);
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('ar'),
              theme: AppTheme.light,
              home: AddEditSubscriptionScreen(controller: controller),
            ),
          );
          await tester.pumpAndSettle();

          // 3. Verify inputs are fully preserved
          expect(find.text('Disney+ Premium Annual'), findsOneWidget);
          expect(find.text('139.99'), findsOneWidget);
          expect(controller.formState.name, equals('Disney+ Premium Annual'));
          expect(controller.formState.priceText, equals('139.99'));

          // Zero layout overflow errors
          expect(tester.takeException(), isNull);
        },
      );
    },
  );
}

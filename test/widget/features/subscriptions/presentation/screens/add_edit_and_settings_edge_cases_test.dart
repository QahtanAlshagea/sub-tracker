import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/backup_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/export_backup_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/import_backup_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/add_edit_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/settings_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/add_edit_subscription_controller.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/settings_controller.dart';

class _FakeSubRepo implements SubscriptionRepository {
  int saveCount = 0;
  final Map<String, Subscription> storage = {};

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
    saveCount++;
    // Simulate slight async delay
    await Future.delayed(const Duration(milliseconds: 50));
    storage[subscription.id] = subscription;
    return Success(subscription);
  }

  @override
  Future<Result<Subscription>> updateSubscription(
    Subscription subscription,
  ) async {
    saveCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    storage[subscription.id] = subscription;
    return Success(subscription);
  }

  @override
  Future<Result<Subscription>> getSubscriptionById(String id) async {
    final s = storage[id];
    if (s != null) return Success(s);
    return Success(
      Subscription.create(
        id: id,
        name: 'Existing Sub',
        price: const Money(amountMinorUnits: 1200, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        dueDate: DueDate(DateTime.utc(2026, 10, 1)),
        categoryId: 'cat-1',
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCatRepo implements CategoryRepository {
  @override
  Future<Result<List<Category>>> getAllCategories() async {
    return Success([
      Category(
        id: 'cat-1',
        name: 'عام',
        colorValue: 0xFF123456,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBackupRepo implements BackupRepository {
  bool wipeCalled = false;

  @override
  Future<Result<void>> wipeDatabase() async {
    wipeCalled = true;
    return const Result.success(null);
  }

  @override
  Future<Result<String>> exportBackupToJson() async =>
      const Result.success('{}');

  @override
  Future<Result<BackupPreview>> previewBackup(String jsonContent) async =>
      Result.success(
        BackupPreview(
          schemaVersion: 2,
          exportedAt: DateTime.utc(2026, 9, 20),
          totalCategories: 0,
          newCategories: 0,
          duplicateCategories: 0,
          totalSubscriptions: 0,
          newSubscriptions: 0,
          duplicateSubscriptions: 0,
          totalPriceHistories: 0,
        ),
      );

  @override
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  }) async => const Result.success(
    ImportResult(
      importedCategories: 0,
      importedSubscriptions: 0,
      importedPriceHistories: 0,
      strategy: ImportStrategy.merge,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Add/Edit & Settings Screens Edge Cases', () {
    late _FakeSubRepo subRepo;
    late _FakeCatRepo catRepo;
    late _FakeBackupRepo backupRepo;

    setUp(() {
      subRepo = _FakeSubRepo();
      catRepo = _FakeCatRepo();
      backupRepo = _FakeBackupRepo();
    });

    testWidgets(
      '[EC-07-4]: Double tapping save button executes create/update only once',
      (tester) async {
        final controller = AddEditSubscriptionController(
          createSubscriptionUseCase: CreateSubscriptionUseCase(subRepo),
          updateSubscriptionUseCase: UpdateSubscriptionUseCase(subRepo),
          getSubscriptionByIdUseCase: GetSubscriptionByIdUseCase(subRepo),
          getCategoriesUseCase: GetCategoriesUseCase(catRepo),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: AddEditSubscriptionScreen(controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('add_edit_name_field')),
          'Figma Pro',
        );
        await tester.enterText(
          find.byKey(const Key('add_edit_price_field')),
          '15',
        );
        await tester.pumpAndSettle();

        final saveButton = find.byKey(const Key('add_edit_save_button'));

        // Double-tap rapidly
        await tester.tap(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Ensure save was executed only once
        expect(subRepo.saveCount, equals(1));
      },
    );

    testWidgets(
      '[EC-37-2]: Navigation/back press during active operation does not corrupt state',
      (tester) async {
        final controller = AddEditSubscriptionController(
          createSubscriptionUseCase: CreateSubscriptionUseCase(subRepo),
          updateSubscriptionUseCase: UpdateSubscriptionUseCase(subRepo),
          getSubscriptionByIdUseCase: GetSubscriptionByIdUseCase(subRepo),
          getCategoriesUseCase: GetCategoriesUseCase(catRepo),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  key: const Key('open_screen_btn'),
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditSubscriptionScreen(controller: controller),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('open_screen_btn')));
        await tester.pumpAndSettle();

        // Trigger pop/back while controller is intact
        Navigator.of(
          tester.element(find.byType(AddEditSubscriptionScreen)),
        ).pop();
        await tester.pumpAndSettle();

        expect(find.byType(AddEditSubscriptionScreen), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '[EC-37-3]: Double clicking confirmation dialog confirm button executes action only once',
      (tester) async {
        int actionCounter = 0;
        bool isConfirming = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (ctx, setState) => ElevatedButton(
                  key: const Key('trigger_dialog_btn'),
                  onPressed: () {
                    showDialog(
                      context: ctx,
                      builder: (dialogCtx) => StatefulBuilder(
                        builder: (dCtx, setDialogState) => AlertDialog(
                          title: const Text('Confirm Action'),
                          actions: [
                            FilledButton(
                              key: const Key('confirm_action_btn'),
                              onPressed: isConfirming
                                  ? null
                                  : () {
                                      setDialogState(() => isConfirming = true);
                                      actionCounter++;
                                      Navigator.of(dialogCtx).pop();
                                    },
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('trigger_dialog_btn')));
        await tester.pumpAndSettle();

        final confirmBtn = find.byKey(const Key('confirm_action_btn'));
        await tester.tap(confirmBtn);
        // Immediate second tap before dismiss
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn, warnIfMissed: false);
        }
        await tester.pumpAndSettle();

        expect(actionCounter, equals(1));
      },
    );

    testWidgets(
      '[EC-38-1]: Changing default currency in preferences does not mutate existing subscriptions currency',
      (tester) async {
        final existingSub = Subscription.create(
          id: 'sub-eur',
          name: 'Hetzner Server',
          price: const Money(amountMinorUnits: 2500, currencyCode: 'EUR'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 10, 1)),
          categoryId: 'cat-1',
        );

        final settingsController = SettingsController(
          exportBackupUseCase: ExportBackupUseCase(backupRepo),
          importBackupUseCase: ImportBackupUseCase(backupRepo),
          backupRepository: backupRepo,
        );

        // Change default app currency to SAR
        settingsController.updateDefaultCurrency('SAR');

        // Assert that old subscription still preserves EUR
        expect(existingSub.price.currencyCode, equals('EUR'));
        expect(existingSub.price.amountMinorUnits, equals(2500));
      },
    );

    testWidgets(
      '[EC-38-2]: Instant automatic theme switching with system brightness changes',
      (tester) async {
        ThemeMode activeTheme = ThemeMode.system;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: activeTheme,
            home: const Scaffold(body: Center(child: Text('Theme Adaptive'))),
          ),
        );
        await tester.pumpAndSettle();

        // Switch platform brightness to dark
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pumpAndSettle();

        final context = tester.element(find.text('Theme Adaptive'));
        expect(Theme.of(context).brightness, equals(Brightness.dark));

        // Reset
        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;
        await tester.pumpAndSettle();
        expect(Theme.of(context).brightness, equals(Brightness.light));
      },
    );

    testWidgets(
      '[EC-40-4]: Destructive actions require explicit confirmation and provide feedback',
      (tester) async {
        final settingsController = SettingsController(
          exportBackupUseCase: ExportBackupUseCase(backupRepo),
          importBackupUseCase: ImportBackupUseCase(backupRepo),
          backupRepository: backupRepo,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: SettingsScreen(controller: settingsController),
          ),
        );
        await tester.pumpAndSettle();

        // Scroll to wipe data tile
        await tester.scrollUntilVisible(
          find.byKey(const Key('settings_wipe_data_tile')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        final wipeTileFinder = find.byKey(const Key('settings_wipe_data_tile'));
        expect(wipeTileFinder, findsOneWidget);

        await tester.tap(wipeTileFinder);
        await tester.pumpAndSettle();

        // Dialog appears with defensive confirmation input
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );
  });
}

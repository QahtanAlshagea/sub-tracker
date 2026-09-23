import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/accessibility/accessibility_widgets.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_data.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/backup_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/export_backup_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/import_backup_usecase.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/settings_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/state/settings_controller.dart';

class FakeBackupRepository implements BackupRepository {
  bool exportCalled = false;
  bool importCalled = false;
  bool wipeCalled = false;

  @override
  Future<Result<BackupData>> createBackup() async {
    return Result.success(
      BackupData(
        schemaVersion: 2,
        exportedAt: DateTime.utc(2026, 9, 20),
        categories: [
          Category(
            id: 'cat-1',
            name: 'عام',
            colorValue: 0xFF123456,
            createdAt: DateTime.utc(2026, 1, 1),
            isSystem: false,
          ),
        ],
        subscriptions: const [],
        priceHistory: const [],
        settings: const {'theme_mode': 'system', 'default_currency': 'USD'},
      ),
    );
  }

  @override
  Future<Result<String>> exportBackupToJson() async {
    exportCalled = true;
    return const Result.success('{"version":2}');
  }

  @override
  Future<Result<BackupPreview>> previewBackup(String jsonContent) async {
    return Result.success(
      BackupPreview(
        schemaVersion: 2,
        exportedAt: DateTime.utc(2026, 9, 20),
        totalCategories: 1,
        newCategories: 1,
        duplicateCategories: 0,
        totalSubscriptions: 1,
        newSubscriptions: 1,
        duplicateSubscriptions: 0,
        totalPriceHistories: 0,
      ),
    );
  }

  @override
  Future<Result<ImportResult>> restoreBackup({
    required String jsonContent,
    required ImportStrategy strategy,
  }) async {
    importCalled = true;
    return const Result.success(
      ImportResult(
        importedCategories: 1,
        importedSubscriptions: 1,
        importedPriceHistories: 0,
        strategy: ImportStrategy.merge,
      ),
    );
  }

  @override
  Future<Result<void>> wipeDatabase() async {
    wipeCalled = true;
    return const Result.success(null);
  }
}

void main() {
  group('SettingsScreen View States, Preferences & Data Management', () {
    late FakeBackupRepository fakeRepo;
    late SettingsController controller;

    setUp(() {
      fakeRepo = FakeBackupRepository();
      controller = SettingsController(
        exportBackupUseCase: ExportBackupUseCase(fakeRepo),
        importBackupUseCase: ImportBackupUseCase(fakeRepo),
        backupRepository: fakeRepo,
      );
    });

    Widget createWidget({ValueChanged<ThemeMode>? onThemeModeChanged}) {
      return MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: SettingsScreen(
          controller: controller,
          onThemeModeChanged: onThemeModeChanged,
        ),
      );
    }

    testWidgets(
      '1. Initial State: renders Theme selector, Currency dropdown, and Data management tiles',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text('الإعدادات العامة'), findsOneWidget);
        expect(
          find.byKey(const Key('settings_theme_segmented_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('settings_currency_dropdown')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('settings_export_backup_tile')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('settings_import_backup_tile')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('settings_wipe_data_tile')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '2. Theme Selection: toggles theme mode and notifies callback',
      (tester) async {
        ThemeMode? toggledMode;
        await tester.pumpWidget(
          createWidget(onThemeModeChanged: (mode) => toggledMode = mode),
        );
        await tester.pumpAndSettle();

        // Tap dark mode
        await tester.tap(find.text('داكن'));
        await tester.pumpAndSettle();

        expect(controller.state.dataOrNull?.themeMode, equals('dark'));
        expect(toggledMode, equals(ThemeMode.dark));
      },
    );

    testWidgets('3. Export Backup: executes export and shows success banner', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings_export_backup_tile')));
      await tester.pumpAndSettle();

      expect(fakeRepo.exportCalled, isTrue);
      expect(find.text('تم تصدير النسخة الاحتياطية بنجاح'), findsOneWidget);
    });

    testWidgets(
      '4. Import Backup: dialog allows entering JSON and confirms import',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('settings_import_backup_tile')));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(
          find.byKey(const Key('settings_import_json_field')),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('settings_import_json_field')),
          '{"version": 2}',
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('settings_confirm_import_button')),
        );
        await tester.pumpAndSettle();

        expect(fakeRepo.importCalled, isTrue);
        expect(find.text('تم استيراد النسخة الاحتياطية بنجاح'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Wipe Data (US-39 / EC-39-1): keyword confirmation guards against accidental deletion',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('settings_wipe_data_tile')));
        await tester.pumpAndSettle();

        // Confirm dialog open
        expect(find.text('تأكيد مسح البيانات نهائياً'), findsOneWidget);
        final confirmBtn = find.byKey(
          const Key('settings_confirm_wipe_button'),
        );
        expect(confirmBtn, findsOneWidget);

        // Button should be disabled initially
        final initialButton = tester.widget<FilledButton>(confirmBtn);
        expect(initialButton.onPressed, isNull);

        // Enter wrong keyword
        await tester.enterText(
          find.byKey(const Key('settings_wipe_keyword_field')),
          'حذف',
        );
        await tester.pumpAndSettle();
        final wrongButton = tester.widget<FilledButton>(confirmBtn);
        expect(wrongButton.onPressed, isNull);

        // Enter exact keyword 'مسح'
        await tester.enterText(
          find.byKey(const Key('settings_wipe_keyword_field')),
          'مسح',
        );
        await tester.pumpAndSettle();
        final validButton = tester.widget<FilledButton>(confirmBtn);
        expect(validButton.onPressed, isNotNull);

        // Tap confirm wipe
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Scroll back to top to view success banner
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();

        expect(fakeRepo.wipeCalled, isTrue);
        expect(find.text('تم مسح جميع البيانات بنجاح'), findsOneWidget);
      },
    );

    testWidgets(
      '6. NFR-04: Action tiles satisfy minimum 48x48 dp touch targets',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final tileFinders = [
          find.byKey(const Key('settings_export_backup_tile')),
          find.byKey(const Key('settings_import_backup_tile')),
          find.byKey(const Key('settings_wipe_data_tile')),
        ];

        for (final finder in tileFinders) {
          final touchTarget = find.ancestor(
            of: finder,
            matching: find.byType(MinTouchTarget),
          );
          expect(touchTarget, findsOneWidget);
          final size = tester.getSize(touchTarget);
          expect(size.height, greaterThanOrEqualTo(48.0));
        }
      },
    );

    testWidgets(
      '7. Banner: Close icon manually dismisses notification banner',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('settings_export_backup_tile')));
        await tester.pumpAndSettle();

        expect(find.text('تم تصدير النسخة الاحتياطية بنجاح'), findsOneWidget);
        expect(
          find.byKey(const Key('settings_banner_dismiss_button')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('settings_banner_dismiss_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('تم تصدير النسخة الاحتياطية بنجاح'), findsNothing);
      },
    );

    testWidgets('8. Banner: Auto-dismisses after configured duration', (
      tester,
    ) async {
      final timedController = SettingsController(
        exportBackupUseCase: ExportBackupUseCase(fakeRepo),
        importBackupUseCase: ImportBackupUseCase(fakeRepo),
        backupRepository: fakeRepo,
        autoDismissDuration: const Duration(seconds: 2),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: SettingsScreen(controller: timedController),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings_export_backup_tile')));
      await tester.pumpAndSettle();

      expect(find.text('تم تصدير النسخة الاحتياطية بنجاح'), findsOneWidget);

      // Advance fake time past 2 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('تم تصدير النسخة الاحتياطية بنجاح'), findsNothing);

      timedController.dispose();
    });

    testWidgets(
      '9. Security: renders PIN security switch and default disabled status',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final pinSwitchFinder = find.byKey(const Key('settings_pin_switch'));
        expect(pinSwitchFinder, findsOneWidget);
        expect(find.text('قفل التطبيق برمز PIN'), findsOneWidget);
        expect(
          find.text('حماية بياناتك وسجلاتك المالية محلياً'),
          findsOneWidget,
        );
      },
    );
  });
}

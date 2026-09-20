import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/theme/app_theme_extension.dart';
import 'package:sub_tracker/core/theme/tokens/app_colors.dart';
import 'package:sub_tracker/core/theme/tokens/app_spacing.dart';

void main() {
  group('AppTheme Widget & ThemeData Integration Tests (C-15, NFR-04)', () {
    testWidgets(
      'AppTheme.light builds with valid ColorScheme and AppThemeExtension',
      (WidgetTester tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return Scaffold(
                  appBar: AppBar(title: const Text('Light Test')),
                  body: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Action'),
                  ),
                );
              },
            ),
          ),
        );

        final theme = Theme.of(capturedContext);
        expect(theme.brightness, equals(Brightness.light));
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.primary, equals(AppColors.lightPrimary));

        // Verify extension is registered
        final ext = capturedContext.appTheme;
        expect(ext.statusPaid, equals(AppColors.lightSuccess));
        expect(ext.statusDueSoon, equals(AppColors.lightWarning));
        expect(ext.statusOverdue, equals(AppColors.lightError));

        // Verify ElevatedButton size meets minimum touch target 48dp
        final buttonFinder = find.byType(ElevatedButton);
        final buttonSize = tester.getSize(buttonFinder);
        expect(
          buttonSize.height,
          greaterThanOrEqualTo(AppSpacing.touchTargetMin),
        );
      },
    );

    testWidgets(
      'AppTheme.dark builds with valid ColorScheme and AppThemeExtension',
      (WidgetTester tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return Scaffold(
                  appBar: AppBar(title: const Text('Dark Test')),
                  body: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Action'),
                  ),
                );
              },
            ),
          ),
        );

        final theme = Theme.of(capturedContext);
        expect(theme.brightness, equals(Brightness.dark));
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.primary, equals(AppColors.darkPrimary));

        // Verify extension is registered
        final ext = capturedContext.appTheme;
        expect(ext.statusPaid, equals(AppColors.darkSuccess));
        expect(ext.statusDueSoon, equals(AppColors.darkWarning));
        expect(ext.statusOverdue, equals(AppColors.darkError));

        // Verify OutlinedButton size meets minimum touch target 48dp
        final buttonFinder = find.byType(OutlinedButton);
        final buttonSize = tester.getSize(buttonFinder);
        expect(
          buttonSize.height,
          greaterThanOrEqualTo(AppSpacing.touchTargetMin),
        );
      },
    );
  });
}

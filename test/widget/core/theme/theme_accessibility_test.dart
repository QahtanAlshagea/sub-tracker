import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/theme/app_tokens.dart';

void main() {
  Widget buildTestApp({
    required ThemeData theme,
    required TextDirection textDirection,
    double textScaleFactor = 1.0,
    required Widget child,
  }) {
    return MaterialApp(
      theme: theme,
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('WCAG 2.1 AA Accessibility & Contrast Verification (NFR-04)', () {
    testWidgets('Light Theme components meet WCAG AA contrast ratio >= 4.5:1', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: AppTheme.light,
          textDirection: TextDirection.rtl,
          child: Center(
            child: Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('اشتراك تجريبي', style: AppTypography.titleMedium),
                    AppSpacing.gapVerticalS,
                    Text('9.99 دولار', style: AppTypography.bodyMedium),
                    AppSpacing.gapVerticalM,
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('تأكيد الدفع'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // Verify mathematical contrast on used theme colors
      final textContrast = AppColors.calculateContrastRatio(
        AppColors.lightTextPrimary,
        AppColors.lightSurface,
      );
      expect(textContrast, greaterThanOrEqualTo(4.5));

      final buttonContrast = AppColors.calculateContrastRatio(
        AppColors.lightOnPrimary,
        AppColors.lightPrimary,
      );
      expect(buttonContrast, greaterThanOrEqualTo(4.5));
    });

    testWidgets('Dark Theme components meet WCAG AA contrast ratio >= 4.5:1', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: AppTheme.dark,
          textDirection: TextDirection.rtl,
          child: Center(
            child: Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('اشتراك سحابي', style: AppTypography.titleMedium),
                    AppSpacing.gapVerticalS,
                    Text('150.00 ر.س', style: AppTypography.bodyMedium),
                    AppSpacing.gapVerticalM,
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('حفظ التعديل'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final textContrast = AppColors.calculateContrastRatio(
        AppColors.darkTextPrimary,
        AppColors.darkSurface,
      );
      expect(textContrast, greaterThanOrEqualTo(4.5));

      final buttonContrast = AppColors.calculateContrastRatio(
        AppColors.darkOnPrimary,
        AppColors.darkPrimary,
      );
      expect(buttonContrast, greaterThanOrEqualTo(4.5));
    });
  });

  group('200% Font Scaling & Arabic Robustness (US-40, NFR-08)', () {
    testWidgets('Cards and Arabic typography scale up to 200% without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: AppTheme.light,
          textDirection: TextDirection.rtl,
          textScaleFactor: 2.0, // 200% scaling per WCAG AA requirement
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خدمة استضافة سحابية وتخزين بيانات متقدم',
                      style: AppTypography.titleLarge,
                    ),
                    AppSpacing.gapVerticalS,
                    Text(
                      'يتم التجديد تلقائياً في 31 مارس القادم، التكلفة الشهرية الموحدة: 45.00\$',
                      style: AppTypography.bodyMedium,
                    ),
                    AppSpacing.gapVerticalM,
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('إدارة'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Verify no RenderFlex overflow or layout exception occurred at 200%
      expect(tester.takeException(), isNull);
      expect(find.text('إدارة'), findsOneWidget);
    });

    testWidgets('Interactive buttons fulfill 48x48 touch target requirement', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: AppTheme.light,
          textDirection: TextDirection.rtl,
          child: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('زر تفاعلي'),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
      expect(
        buttonSize.height,
        greaterThanOrEqualTo(AppSpacing.minTouchTarget),
      );
    });
  });
}

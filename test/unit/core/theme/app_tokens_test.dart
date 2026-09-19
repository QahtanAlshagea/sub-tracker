import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_tokens.dart';

void main() {
  group('AppColors Tokens & Contrast Validation', () {
    test('calculateContrastRatio computes correct mathematical values', () {
      final blackWhiteRatio = AppColors.calculateContrastRatio(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );
      expect(blackWhiteRatio, closeTo(21.0, 0.1));

      final identicalRatio = AppColors.calculateContrastRatio(
        const Color(0xFFFFFFFF),
        const Color(0xFFFFFFFF),
      );
      expect(identicalRatio, closeTo(1.0, 0.01));
    });

    test('WCAG 2.1 AA: Light Theme text-to-surface contrast exceeds 4.5:1', () {
      final textPrimaryRatio = AppColors.calculateContrastRatio(
        AppColors.lightTextPrimary,
        AppColors.lightSurface,
      );
      expect(textPrimaryRatio, greaterThanOrEqualTo(4.5));
      expect(
        AppColors.meetsWcagNormalText(
          AppColors.lightTextPrimary,
          AppColors.lightSurface,
        ),
        isTrue,
      );

      final textSecondaryRatio = AppColors.calculateContrastRatio(
        AppColors.lightTextSecondary,
        AppColors.lightSurface,
      );
      expect(textSecondaryRatio, greaterThanOrEqualTo(4.5));
      expect(
        AppColors.meetsWcagNormalText(
          AppColors.lightTextSecondary,
          AppColors.lightSurface,
        ),
        isTrue,
      );
    });

    test('WCAG 2.1 AA: Dark Theme text-to-surface contrast exceeds 4.5:1', () {
      final textPrimaryRatio = AppColors.calculateContrastRatio(
        AppColors.darkTextPrimary,
        AppColors.darkSurface,
      );
      expect(textPrimaryRatio, greaterThanOrEqualTo(4.5));
      expect(
        AppColors.meetsWcagNormalText(
          AppColors.darkTextPrimary,
          AppColors.darkSurface,
        ),
        isTrue,
      );

      final textSecondaryRatio = AppColors.calculateContrastRatio(
        AppColors.darkTextSecondary,
        AppColors.darkSurface,
      );
      expect(textSecondaryRatio, greaterThanOrEqualTo(4.5));
      expect(
        AppColors.meetsWcagNormalText(
          AppColors.darkTextSecondary,
          AppColors.darkSurface,
        ),
        isTrue,
      );
    });

    test(
      'Semantic brand and feedback colors meet graphical contrast (>= 3.0:1)',
      () {
        expect(
          AppColors.meetsWcagLargeText(
            AppColors.lightPrimary,
            AppColors.lightSurface,
          ),
          isTrue,
        );
        expect(
          AppColors.meetsWcagLargeText(
            AppColors.lightError,
            AppColors.lightSurface,
          ),
          isTrue,
        );
        expect(
          AppColors.meetsWcagLargeText(
            AppColors.darkPrimary,
            AppColors.darkSurface,
          ),
          isTrue,
        );
        expect(
          AppColors.meetsWcagLargeText(
            AppColors.darkError,
            AppColors.darkSurface,
          ),
          isTrue,
        );
      },
    );
  });

  group('AppSpacing & Touch Target Validation', () {
    test(
      'Strict WCAG AA: Minimum touch target size is at least 48.0 logical pixels',
      () {
        expect(AppSpacing.minTouchTarget, greaterThanOrEqualTo(48.0));
        expect(AppSpacing.minTouchTargetSize.width, greaterThanOrEqualTo(48.0));
        expect(
          AppSpacing.minTouchTargetSize.height,
          greaterThanOrEqualTo(48.0),
        );
        expect(AppSpacing.buttonHeight, greaterThanOrEqualTo(48.0));
        expect(AppSpacing.inputHeight, greaterThanOrEqualTo(48.0));
      },
    );

    test(
      'Spacing scale strictly follows incremental values without magic jumps',
      () {
        expect(AppSpacing.none, equals(0.0));
        expect(AppSpacing.xs, equals(4.0));
        expect(AppSpacing.s, equals(8.0));
        expect(AppSpacing.sm, equals(12.0));
        expect(AppSpacing.m, equals(16.0));
        expect(AppSpacing.l, equals(24.0));
        expect(AppSpacing.xl, equals(32.0));
        expect(AppSpacing.xxl, equals(40.0));
        expect(AppSpacing.xxxl, equals(48.0));
        expect(AppSpacing.huge, equals(64.0));

        expect(AppSpacing.xs, lessThan(AppSpacing.s));
        expect(AppSpacing.s, lessThan(AppSpacing.sm));
        expect(AppSpacing.sm, lessThan(AppSpacing.m));
        expect(AppSpacing.m, lessThan(AppSpacing.l));
        expect(AppSpacing.l, lessThan(AppSpacing.xl));
      },
    );

    test('EdgeInsets shortcuts correctly apply token values', () {
      expect(AppSpacing.cardPadding, equals(const EdgeInsets.all(16.0)));
      expect(AppSpacing.insetsAllS, equals(const EdgeInsets.all(8.0)));
      expect(AppSpacing.insetsNone, equals(EdgeInsets.zero));
    });
  });

  group('AppRadii Tokens Validation', () {
    test('Corner radii values follow progressive scale', () {
      expect(AppRadii.none, equals(0.0));
      expect(AppRadii.xs, equals(4.0));
      expect(AppRadii.s, equals(8.0));
      expect(AppRadii.m, equals(12.0));
      expect(AppRadii.l, equals(16.0));
      expect(AppRadii.xl, equals(24.0));
      expect(AppRadii.full, equals(9999.0));

      expect(AppRadii.cardRadius.topLeft.x, equals(AppRadii.m));
      expect(AppRadii.buttonRadius.topLeft.x, equals(AppRadii.s));
      expect(AppRadii.inputRadius.topLeft.x, equals(AppRadii.s));
      expect(AppRadii.dialogRadius.topLeft.x, equals(AppRadii.l));
    });
  });

  group('AppTypography & Arabic Support Validation', () {
    test('Line heights satisfy minimum safe metrics for Arabic diacritics', () {
      expect(AppTypography.heightDisplay, greaterThanOrEqualTo(1.30));
      expect(AppTypography.heightHeadline, greaterThanOrEqualTo(1.35));
      expect(AppTypography.heightTitle, greaterThanOrEqualTo(1.40));
      expect(AppTypography.heightBody, greaterThanOrEqualTo(1.50));
      expect(AppTypography.heightLabel, greaterThanOrEqualTo(1.40));
    });

    test('Money typography styles include tabular figures feature', () {
      expect(
        AppTypography.moneyAmountLarge.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        AppTypography.moneyAmountMedium.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });

    test(
      'createTextTheme populates all Material 3 styles with bound colors',
      () {
        const primaryColor = Color(0xFF112233);
        const secondaryColor = Color(0xFF445566);

        final theme = AppTypography.createTextTheme(
          primaryTextColor: primaryColor,
          secondaryTextColor: secondaryColor,
        );

        expect(theme.headlineLarge?.color, equals(primaryColor));
        expect(theme.bodyLarge?.color, equals(primaryColor));
        expect(theme.bodyMedium?.color, equals(primaryColor));
        expect(theme.bodySmall?.color, equals(secondaryColor));
        expect(theme.titleSmall?.color, equals(secondaryColor));
        expect(theme.labelSmall?.color, equals(secondaryColor));
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/theme/app_tokens.dart';

void main() {
  group('AppTheme Configuration Tests', () {
    test('AppTheme.light provides complete Material 3 Light Theme', () {
      final theme = AppTheme.light;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.lightBackground));

      // ColorScheme
      expect(theme.colorScheme.primary, equals(AppColors.lightPrimary));
      expect(theme.colorScheme.surface, equals(AppColors.lightSurface));
      expect(theme.colorScheme.onSurface, equals(AppColors.lightTextPrimary));
      expect(theme.colorScheme.error, equals(AppColors.lightError));

      // Card Theme
      expect(theme.cardTheme.color, equals(AppColors.lightSurface));
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape?.borderRadius, equals(AppRadii.cardRadius));

      // Button Themes (Strict Touch Target >= 48x48)
      final elevatedBtnStyle = theme.elevatedButtonTheme.style;
      final minSize = elevatedBtnStyle?.minimumSize?.resolve({});
      expect(minSize?.width, greaterThanOrEqualTo(48.0));
      expect(minSize?.height, greaterThanOrEqualTo(48.0));
      expect(
        elevatedBtnStyle?.tapTargetSize,
        equals(MaterialTapTargetSize.padded),
      );

      // Input Decoration Theme
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(
        theme.inputDecorationTheme.contentPadding,
        equals(AppSpacing.inputContentPadding),
      );

      // Theme Extension
      final ext = theme.extension<AppThemeExtension>();
      expect(ext, isNotNull);
      expect(ext?.success, equals(AppColors.lightSuccess));
      expect(ext?.warning, equals(AppColors.lightWarning));
    });

    test('AppTheme.dark provides complete Material 3 Dark Theme', () {
      final theme = AppTheme.dark;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.darkBackground));

      // ColorScheme
      expect(theme.colorScheme.primary, equals(AppColors.darkPrimary));
      expect(theme.colorScheme.surface, equals(AppColors.darkSurface));
      expect(theme.colorScheme.onSurface, equals(AppColors.darkTextPrimary));
      expect(theme.colorScheme.error, equals(AppColors.darkError));

      // Card Theme
      expect(theme.cardTheme.color, equals(AppColors.darkSurface));
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape?.borderRadius, equals(AppRadii.cardRadius));

      // Button Themes (Strict Touch Target >= 48x48)
      final outlinedBtnStyle = theme.outlinedButtonTheme.style;
      final minSize = outlinedBtnStyle?.minimumSize?.resolve({});
      expect(minSize?.width, greaterThanOrEqualTo(48.0));
      expect(minSize?.height, greaterThanOrEqualTo(48.0));

      // Theme Extension
      final ext = theme.extension<AppThemeExtension>();
      expect(ext, isNotNull);
      expect(ext?.success, equals(AppColors.darkSuccess));
      expect(ext?.warning, equals(AppColors.darkWarning));
    });

    test('AppThemeExtension copyWith and lerp operate seamlessly', () {
      const extLight = AppThemeExtension.light;
      const extDark = AppThemeExtension.dark;

      final modified = extLight.copyWith(success: const Color(0xFF00FF00));
      expect(modified.success, equals(const Color(0xFF00FF00)));
      expect(modified.warning, equals(extLight.warning));

      final lerped = extLight.lerp(extDark, 0.5) as AppThemeExtension;
      expect(lerped, isNotNull);
      expect(lerped.success, isNot(equals(extLight.success)));
      expect(lerped.success, isNot(equals(extDark.success)));
    });
  });
}

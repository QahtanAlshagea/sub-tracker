import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Complete ThemeData configurations for Sub Tracker.
///
/// Provides:
/// - Light & Dark Material 3 themes (`AppTheme.light`, `AppTheme.dark`)
/// - Guaranteed WCAG 2.1 AA contrast ratios (>= 4.5:1 text, >= 3:1 controls)
/// - Minimum 48x48 tap targets for touch accessibility
/// - Arabic typography support and [AppThemeExtension] for custom semantics
abstract final class AppTheme {
  // ===========================================================================
  // 1. Light Theme
  // ===========================================================================

  static ThemeData get light {
    final textTheme = AppTypography.createTextTheme(
      primaryTextColor: AppColors.lightTextPrimary,
      secondaryTextColor: AppColors.lightTextSecondary,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.slate700,
      onSecondary: AppColors.pureWhite,
      secondaryContainer: AppColors.slate100,
      onSecondaryContainer: AppColors.slate900,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[AppThemeExtension.light],

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: BorderSide(color: AppColors.lightOutlineVariant, width: 1.0),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.lightTextPrimary,
        ),
      ),

      // Button Themes (Strict WCAG AA >= 48x48 tap target)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0.0,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          side: const BorderSide(color: AppColors.lightOutline, width: 1.0),
          textStyle: AppTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceContainer,
        contentPadding: AppSpacing.inputContentPadding,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextMuted,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.lightError,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightOutlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightError),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightError, width: 2.0),
        ),
      ),

      // Dialog & BottomSheet Themes
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.bottomSheetRadius),
      ),
    );
  }

  // ===========================================================================
  // 2. Dark Theme
  // ===========================================================================

  static ThemeData get dark {
    final textTheme = AppTypography.createTextTheme(
      primaryTextColor: AppColors.darkTextPrimary,
      secondaryTextColor: AppColors.darkTextSecondary,
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.slate300,
      onSecondary: AppColors.slate950,
      secondaryContainer: AppColors.slate800,
      onSecondaryContainer: AppColors.slate100,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[AppThemeExtension.dark],

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: BorderSide(color: AppColors.darkOutline, width: 1.0),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Button Themes (Strict WCAG AA >= 48x48 tap target)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0.0,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          side: const BorderSide(color: AppColors.darkOutline, width: 1.0),
          textStyle: AppTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.buttonHeight,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceContainer,
        contentPadding: AppSpacing.inputContentPadding,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextMuted,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.darkError,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkOutlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkError, width: 2.0),
        ),
      ),

      // Dialog & BottomSheet Themes
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.bottomSheetRadius),
      ),
    );
  }
}

// =============================================================================
// 3. AppThemeExtension for Custom Semantic Tokens
// =============================================================================

/// Extends standard Material 3 ThemeData with Sub Tracker specific semantics.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final TextStyle moneyLarge;
  final TextStyle moneyMedium;
  final TextStyle moneySmall;

  const AppThemeExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.moneyLarge,
    required this.moneyMedium,
    required this.moneySmall,
  });

  static const AppThemeExtension light = AppThemeExtension(
    success: AppColors.lightSuccess,
    onSuccess: AppColors.lightOnSuccess,
    warning: AppColors.lightWarning,
    onWarning: AppColors.lightOnWarning,
    surfaceContainer: AppColors.lightSurfaceContainer,
    surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
    moneyLarge: AppTypography.moneyAmountLarge,
    moneyMedium: AppTypography.moneyAmountMedium,
    moneySmall: AppTypography.moneyAmountSmall,
  );

  static const AppThemeExtension dark = AppThemeExtension(
    success: AppColors.darkSuccess,
    onSuccess: AppColors.darkOnSuccess,
    warning: AppColors.darkWarning,
    onWarning: AppColors.darkOnWarning,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    moneyLarge: AppTypography.moneyAmountLarge,
    moneyMedium: AppTypography.moneyAmountMedium,
    moneySmall: AppTypography.moneyAmountSmall,
  );

  @override
  AppThemeExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    TextStyle? moneyLarge,
    TextStyle? moneyMedium,
    TextStyle? moneySmall,
  }) {
    return AppThemeExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      moneyLarge: moneyLarge ?? this.moneyLarge,
      moneyMedium: moneyMedium ?? this.moneyMedium,
      moneySmall: moneySmall ?? this.moneySmall,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t) ??
          surfaceContainer,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t) ??
          surfaceContainerHigh,
      moneyLarge: TextStyle.lerp(moneyLarge, other.moneyLarge, t) ?? moneyLarge,
      moneyMedium:
          TextStyle.lerp(moneyMedium, other.moneyMedium, t) ?? moneyMedium,
      moneySmall: TextStyle.lerp(moneySmall, other.moneySmall, t) ?? moneySmall,
    );
  }
}

/// Ergonomic accessor for [AppThemeExtension] from [BuildContext].
extension BuildContextThemeExtension on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
}

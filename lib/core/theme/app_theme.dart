import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme_extension.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_radii.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

/// Central Design System Theme configuration for Sub Tracker.
/// Implements Material 3 with rigorous WCAG 2.1 AA accessibility (NFR-04, NFR-08).
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.lightTextSecondary,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTypography.lightTextTheme,
      extensions: const [AppThemeExtension.light],

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),

      // Elevated Button Theme (Strict Min Touch Target 48dp - NFR-04)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0,
          minimumSize: const Size(
            AppSpacing.touchTargetMin,
            AppSpacing.touchTargetMin,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(
            AppSpacing.touchTargetMin,
            AppSpacing.touchTargetMin,
          ),
          padding: AppSpacing.buttonPadding,
          side: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(
            AppSpacing.touchTargetMin,
            AppSpacing.touchTargetMin,
          ),
          padding: AppSpacing.horizontalMd,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input / TextField Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding: AppSpacing.inputPadding,
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightError, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.lightError, width: 2.0),
        ),
      ),

      // BottomSheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.bottomSheetRadius),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
    );
  }

  // ===========================================================================
  // DARK THEME
  // ===========================================================================
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.darkTextSecondary,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.darkTextTheme,
      extensions: const [AppThemeExtension.dark],

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),

      // Elevated Button Theme (Strict Min Touch Target 48dp - NFR-04)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0,
          minimumSize: const Size(
            AppSpacing.touchTargetMin,
            AppSpacing.touchTargetMin,
          ),
          padding: AppSpacing.buttonPadding,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(
            AppSpacing.touchTargetMin,
            AppSpacing.touchTargetMin,
          ),
          padding: AppSpacing.buttonPadding,
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(
            AppSpacing.touchTargetMin,
            AppSpacing.touchTargetMin,
          ),
          padding: AppSpacing.horizontalMd,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input / TextField Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: AppSpacing.inputPadding,
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkError, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: AppColors.darkError, width: 2.0),
        ),
      ),

      // BottomSheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.bottomSheetRadius),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialogRadius),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
    );
  }
}

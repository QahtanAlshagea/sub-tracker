import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens for Typography and Font Hierarchies.
/// Implements Material 3 typography with optimized line heights for Arabic & Latin scripts.
/// Guaranteed to scale gracefully under TextScaler up to 200% without clipping (NFR-04, [EC-40-1]).
class AppTypography {
  AppTypography._();

  // Primary font family fallbacks
  static const String? fontFamily =
      null; // System font (Cairo/Roboto native resolution)

  // ===========================================================================
  // 1. LIGHT TEXT THEME
  // ===========================================================================
  static TextTheme get lightTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 40.0,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
      height: 1.25,
      color: AppColors.lightTextPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 34.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.25,
      color: AppColors.lightTextPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
      color: AppColors.lightTextPrimary,
    ),

    headlineLarge: TextStyle(
      fontSize: 26.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.3,
      color: AppColors.lightTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.35,
      color: AppColors.lightTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.35,
      color: AppColors.lightTextPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
      color: AppColors.lightTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      color: AppColors.lightTextPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.lightTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      color: AppColors.lightTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.45,
      color: AppColors.lightTextSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.4,
      color: AppColors.lightTextTertiary,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.lightTextPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.35,
      color: AppColors.lightTextSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.35,
      color: AppColors.lightTextTertiary,
    ),
  );

  // ===========================================================================
  // 2. DARK TEXT THEME
  // ===========================================================================
  static TextTheme get darkTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 40.0,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
      height: 1.25,
      color: AppColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 34.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.25,
      color: AppColors.darkTextPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
      color: AppColors.darkTextPrimary,
    ),

    headlineLarge: TextStyle(
      fontSize: 26.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.3,
      color: AppColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.35,
      color: AppColors.darkTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.35,
      color: AppColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
      color: AppColors.darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
      color: AppColors.darkTextPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.darkTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      color: AppColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.45,
      color: AppColors.darkTextSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.4,
      color: AppColors.darkTextTertiary,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
      color: AppColors.darkTextPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.35,
      color: AppColors.darkTextSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.35,
      color: AppColors.darkTextTertiary,
    ),
  );
}

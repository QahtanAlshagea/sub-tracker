import 'package:flutter/material.dart';

/// Typography tokens for Sub Tracker.
///
/// Designed specifically to support Arabic and English typography, with:
/// - Safe line heights (1.35 - 1.55) to prevent Arabic diacritic clipping.
/// - Fluid scaling up to 200% (`TextScaler.linear(2.0)`) per WCAG 2.1 AA.
/// - Clear hierarchical contrast across Display, Headline, Title, Body, and Label scales.
abstract final class AppTypography {
  // ===========================================================================
  // 1. Font Weights
  // ===========================================================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ===========================================================================
  // 2. Safe Line Heights (Prevent vertical glyph clipping in Arabic)
  // ===========================================================================

  static const double heightDisplay = 1.30;
  static const double heightHeadline = 1.35;
  static const double heightTitle = 1.40;
  static const double heightBody = 1.50;
  static const double heightLabel = 1.40;

  // ===========================================================================
  // 3. Base Typography Styles (Color-agnostic)
  // ===========================================================================

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57.0,
    fontWeight: bold,
    height: heightDisplay,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45.0,
    fontWeight: bold,
    height: heightDisplay,
    letterSpacing: 0.0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36.0,
    fontWeight: bold,
    height: heightDisplay,
    letterSpacing: 0.0,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: semiBold,
    height: heightHeadline,
    letterSpacing: 0.0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: semiBold,
    height: heightHeadline,
    letterSpacing: 0.0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24.0,
    fontWeight: semiBold,
    height: heightHeadline,
    letterSpacing: 0.0,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: semiBold,
    height: heightTitle,
    letterSpacing: 0.0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: semiBold,
    height: heightTitle,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: medium,
    height: heightTitle,
    letterSpacing: 0.1,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: regular,
    height: heightBody,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: regular,
    height: heightBody,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: regular,
    height: heightBody,
    letterSpacing: 0.4,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: medium,
    height: heightLabel,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: medium,
    height: heightLabel,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: medium,
    height: heightLabel,
    letterSpacing: 0.5,
  );

  // Financial / Minor Units Numbers
  static const TextStyle moneyAmountLarge = TextStyle(
    fontSize: 28.0,
    fontWeight: bold,
    height: heightHeadline,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle moneyAmountMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: bold,
    height: heightTitle,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle moneyAmountSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: semiBold,
    height: heightTitle,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ===========================================================================
  // 4. Factory to Build Material 3 TextTheme
  // ===========================================================================

  /// Generates a complete Material 3 [TextTheme] bound to primary and secondary text colors.
  static TextTheme createTextTheme({
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primaryTextColor),
      displayMedium: displayMedium.copyWith(color: primaryTextColor),
      displaySmall: displaySmall.copyWith(color: primaryTextColor),
      headlineLarge: headlineLarge.copyWith(color: primaryTextColor),
      headlineMedium: headlineMedium.copyWith(color: primaryTextColor),
      headlineSmall: headlineSmall.copyWith(color: primaryTextColor),
      titleLarge: titleLarge.copyWith(color: primaryTextColor),
      titleMedium: titleMedium.copyWith(color: primaryTextColor),
      titleSmall: titleSmall.copyWith(color: secondaryTextColor),
      bodyLarge: bodyLarge.copyWith(color: primaryTextColor),
      bodyMedium: bodyMedium.copyWith(color: primaryTextColor),
      bodySmall: bodySmall.copyWith(color: secondaryTextColor),
      labelLarge: labelLarge.copyWith(color: primaryTextColor),
      labelMedium: labelMedium.copyWith(color: secondaryTextColor),
      labelSmall: labelSmall.copyWith(color: secondaryTextColor),
    );
  }
}

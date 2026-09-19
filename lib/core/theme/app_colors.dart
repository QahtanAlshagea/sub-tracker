import 'package:flutter/material.dart';

/// Comprehensive color tokens for Sub Tracker.
///
/// Implements a three-tier token architecture:
/// 1. Primitives: Raw curated color scales (Slate, Indigo, Emerald, Amber, Rose).
/// 2. Semantic Palettes: Light and Dark semantic color mappings.
/// 3. Mathematical contrast calculation for WCAG 2.1 AA compliance (>= 4.5:1).
abstract final class AppColors {
  // ===========================================================================
  // 1. Primitive Palette (Raw Values)
  // ===========================================================================

  // Slate (Neutral / Surface / Text)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Indigo (Primary Brand)
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo900 = Color(0xFF312E81);

  // Emerald (Success)
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);

  // Amber (Warning / Approaching Due)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  // Rose (Error / Overdue / Destructive)
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);

  // Pure Neutrals
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ===========================================================================
  // 2. Semantic Color Schemes (Light & Dark)
  // ===========================================================================

  // Light Theme Semantic Colors
  static const Color lightBackground = slate50;
  static const Color lightSurface = pureWhite;
  static const Color lightSurfaceContainer = slate100;
  static const Color lightSurfaceContainerHigh = slate200;
  static const Color lightPrimary = indigo600;
  static const Color lightOnPrimary = pureWhite;
  static const Color lightPrimaryContainer = indigo50;
  static const Color lightOnPrimaryContainer = indigo900;
  static const Color lightTextPrimary = slate900;
  static const Color lightTextSecondary = slate600;
  static const Color lightTextMuted = slate500;
  static const Color lightOutline = slate300;
  static const Color lightOutlineVariant = slate200;
  static const Color lightError = rose600;
  static const Color lightOnError = pureWhite;
  static const Color lightErrorContainer = rose50;
  static const Color lightOnErrorContainer = rose700;
  static const Color lightSuccess = emerald600;
  static const Color lightOnSuccess = pureWhite;
  static const Color lightWarning = amber600;
  static const Color lightOnWarning = pureWhite;

  // Dark Theme Semantic Colors
  static const Color darkBackground = slate950;
  static const Color darkSurface = slate900;
  static const Color darkSurfaceContainer = slate800;
  static const Color darkSurfaceContainerHigh = slate700;
  static const Color darkPrimary = indigo400;
  static const Color darkOnPrimary = slate950;
  static const Color darkPrimaryContainer = indigo900;
  static const Color darkOnPrimaryContainer = indigo100;
  static const Color darkTextPrimary = slate50;
  static const Color darkTextSecondary = slate300;
  static const Color darkTextMuted = slate400;
  static const Color darkOutline = slate700;
  static const Color darkOutlineVariant = slate800;
  static const Color darkError = rose400;
  static const Color darkOnError = slate950;
  static const Color darkErrorContainer = Color(0xFF4C0519);
  static const Color darkOnErrorContainer = rose100;
  static const Color darkSuccess = emerald500;
  static const Color darkOnSuccess = slate950;
  static const Color darkWarning = amber500;
  static const Color darkOnWarning = slate950;

  // ===========================================================================
  // 3. Contrast & Accessibility Helper Functions (WCAG 2.1)
  // ===========================================================================

  /// Calculates the contrast ratio between two colors according to WCAG 2.1 guidelines.
  /// Formula: (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter color's relative luminance.
  /// Minimum requirements:
  /// - Normal Text: >= 4.5:1 (WCAG AA)
  /// - Large Text (>= 18pt or >= 14pt bold): >= 3.0:1 (WCAG AA)
  /// - UI Components & Graphical Objects: >= 3.0:1 (WCAG AA)
  static double calculateContrastRatio(Color foreground, Color background) {
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Verifies whether the contrast ratio between [foreground] and [background] meets WCAG AA (>= 4.5:1).
  static bool meetsWcagNormalText(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Verifies whether the contrast ratio meets WCAG AA for large text or graphical elements (>= 3.0:1).
  static bool meetsWcagLargeText(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 3.0;
  }
}

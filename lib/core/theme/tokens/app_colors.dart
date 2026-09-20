import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Design tokens for colors following the Three-Layer Token Architecture:
/// 1. Primitive Tokens: Raw hex constants (Indigo, Slate, Emerald, Rose, Amber, Sky).
/// 2. Semantic Tokens: Purpose aliases for Light and Dark themes.
/// 3. Component & Accessibility utilities: Contrast calculation meeting WCAG 2.1 AA (≥ 4.5:1).
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. PRIMITIVE TOKENS (Palettes)
  // ===========================================================================

  // Slate / Neutrals
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
  static const Color slate950 = Color(0xFF0B0F19);

  // Indigo / Brand Primary
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo900 = Color(0xFF312E81);

  // Emerald / Success & Paid
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);

  // Rose / Error & Overdue
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);
  static const Color rose800 = Color(0xFF9F1239);

  // Amber / Warning & Due Soon / Trial
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);

  // Sky / Info & System
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky100 = Color(0xFFE0F2FE);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky700 = Color(0xFF0369A1);

  // Pure Constants
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ===========================================================================
  // 2. SEMANTIC TOKENS (Light Theme)
  // ===========================================================================
  static const Color lightBackground = slate50;
  static const Color lightSurface = white;
  static const Color lightSurfaceVariant = slate100;
  static const Color lightSurfaceContainer = slate200;

  static const Color lightPrimary = indigo700;
  static const Color lightOnPrimary = white;
  static const Color lightPrimaryContainer = indigo100;
  static const Color lightOnPrimaryContainer = indigo900;

  static const Color lightSecondary = slate700;
  static const Color lightOnSecondary = white;

  static const Color lightTextPrimary = slate900;
  static const Color lightTextSecondary = slate600;
  static const Color lightTextTertiary = slate400;
  static const Color lightTextDisabled = slate300;

  static const Color lightBorder = slate200;
  static const Color lightBorderSubtle = slate100;
  static const Color lightDivider = slate200;

  // Status Colors (Light)
  static const Color lightSuccess = emerald700;
  static const Color lightOnSuccess = white;
  static const Color lightSuccessContainer = emerald100;
  static const Color lightOnSuccessContainer = emerald800;

  static const Color lightWarning = amber700;
  static const Color lightOnWarning = white;
  static const Color lightWarningContainer = amber100;
  static const Color lightOnWarningContainer = amber800;

  static const Color lightError = rose700;
  static const Color lightOnError = white;
  static const Color lightErrorContainer = rose100;
  static const Color lightOnErrorContainer = rose800;

  static const Color lightInfo = sky700;
  static const Color lightOnInfo = white;
  static const Color lightInfoContainer = sky100;
  static const Color lightOnInfoContainer = sky700;

  // ===========================================================================
  // 3. SEMANTIC TOKENS (Dark Theme)
  // ===========================================================================
  static const Color darkBackground = slate950;
  static const Color darkSurface = Color(
    0xFF161E2E,
  ); // Custom rich dark surface
  static const Color darkSurfaceVariant = slate800;
  static const Color darkSurfaceContainer = slate700;

  static const Color darkPrimary = indigo400;
  static const Color darkOnPrimary = slate950;
  static const Color darkPrimaryContainer = indigo900;
  static const Color darkOnPrimaryContainer = indigo200;

  static const Color darkSecondary = slate300;
  static const Color darkOnSecondary = slate950;

  static const Color darkTextPrimary = slate50;
  static const Color darkTextSecondary = slate300;
  static const Color darkTextTertiary = slate400;
  static const Color darkTextDisabled = slate600;

  static const Color darkBorder = slate700;
  static const Color darkBorderSubtle = slate800;
  static const Color darkDivider = slate800;

  // Status Colors (Dark)
  static const Color darkSuccess = emerald400;
  static const Color darkOnSuccess = slate950;
  static const Color darkSuccessContainer = emerald800;
  static const Color darkOnSuccessContainer = emerald200;

  static const Color darkWarning = amber400;
  static const Color darkOnWarning = slate950;
  static const Color darkWarningContainer = amber800;
  static const Color darkOnWarningContainer = amber200;

  static const Color darkError = rose400;
  static const Color darkOnError = slate950;
  static const Color darkErrorContainer = rose800;
  static const Color darkOnErrorContainer = rose200;

  static const Color darkInfo = sky400;
  static const Color darkOnInfo = slate950;
  static const Color darkInfoContainer = Color(0xFF0C4A6E);
  static const Color darkOnInfoContainer = sky100;

  // ===========================================================================
  // 4. ACCESSIBILITY & WCAG CONTRAST UTILITIES
  // ===========================================================================

  /// Calculates relative luminance according to WCAG 2.1 specifications:
  /// L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  static double computeLuminance(Color color) {
    double transform(double c) {
      return (c <= 0.03928)
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = transform(color.r);
    final g = transform(color.g);
    final b = transform(color.b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates the contrast ratio between two colors according to WCAG 2.1:
  /// Ratio = (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter color.
  static double calculateContrastRatio(Color color1, Color color2) {
    final l1 = computeLuminance(color1);
    final l2 = computeLuminance(color2);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Evaluates whether two colors satisfy WCAG 2.1 AA for normal body text (ratio ≥ 4.5:1).
  static bool isWcagAANormalText(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Evaluates whether two colors satisfy WCAG 2.1 AA for large text or graphical components (ratio ≥ 3.0:1).
  static bool isWcagAALargeText(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 3.0;
  }
}

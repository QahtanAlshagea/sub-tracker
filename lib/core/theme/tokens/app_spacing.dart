import 'package:flutter/material.dart';

/// Design tokens for Spacing, Margins, Paddings, and Touch Target constraints.
/// Implements NFR-04 (Touch Target ≥ 48x48) and an 8px grid system with 4px sub-grid.
class AppSpacing {
  AppSpacing._();

  // ===========================================================================
  // 1. RAW NUMERIC SCALES
  // ===========================================================================
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  /// Minimum interactive touch target dimension required by WCAG 2.1 AA & NFR-04.
  static const double touchTargetMin = 48.0;

  // ===========================================================================
  // 2. EDGE INSETS
  // ===========================================================================
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// Standard screen content padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Standard card content padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Standard button content padding (guaranteeing minimum height)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  /// Standard form field content padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ===========================================================================
  // 3. SIZEDBOX GAPS (Layout Utilities)
  // ===========================================================================
  static const Widget gapVerticalXs = SizedBox(height: xs);
  static const Widget gapVerticalSm = SizedBox(height: sm);
  static const Widget gapVerticalMd = SizedBox(height: md);
  static const Widget gapVerticalLg = SizedBox(height: lg);
  static const Widget gapVerticalXl = SizedBox(height: xl);
  static const Widget gapVerticalXxl = SizedBox(height: xxl);

  static const Widget gapHorizontalXs = SizedBox(width: xs);
  static const Widget gapHorizontalSm = SizedBox(width: sm);
  static const Widget gapHorizontalMd = SizedBox(width: md);
  static const Widget gapHorizontalLg = SizedBox(width: lg);
  static const Widget gapHorizontalXl = SizedBox(width: xl);
}

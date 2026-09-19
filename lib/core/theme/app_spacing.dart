import 'package:flutter/material.dart';

/// Centralized spacing, layout padding, and touch target tokens for Sub Tracker.
///
/// Strictly enforces:
/// - 4px / 8px incremental scale
/// - WCAG AA minimum 48x48 logical pixels for all interactive touch targets
/// - Zero magic numbers in widget spacing and dimensions.
abstract final class AppSpacing {
  // ===========================================================================
  // 1. Raw Spacing Scale (in logical pixels)
  // ===========================================================================

  static const double none = 0.0;
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double sm = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;

  // ===========================================================================
  // 2. Standard Touch Target Dimensions (WCAG AA)
  // ===========================================================================

  /// Minimum width and height for any interactive touch target per WCAG 2.1 AA.
  static const double minTouchTarget = 48.0;
  static const Size minTouchTargetSize = Size(minTouchTarget, minTouchTarget);

  /// Standard heights for common UI controls.
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double chipHeight = 36.0;

  /// Standard icon dimensions.
  static const double iconXs = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXl = 48.0;

  // ===========================================================================
  // 3. Pre-composed Edge Insets
  // ===========================================================================

  static const EdgeInsets insetsNone = EdgeInsets.zero;
  static const EdgeInsets insetsAllXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsAllS = EdgeInsets.all(s);
  static const EdgeInsets insetsAllSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsAllM = EdgeInsets.all(m);
  static const EdgeInsets insetsAllL = EdgeInsets.all(l);
  static const EdgeInsets insetsAllXl = EdgeInsets.all(xl);
  static const EdgeInsets insetsAllXxl = EdgeInsets.all(xxl);

  // Symmetric Horizontal
  static const EdgeInsets insetsHorizontalS = EdgeInsets.symmetric(
    horizontal: s,
  );
  static const EdgeInsets insetsHorizontalM = EdgeInsets.symmetric(
    horizontal: m,
  );
  static const EdgeInsets insetsHorizontalL = EdgeInsets.symmetric(
    horizontal: l,
  );
  static const EdgeInsets insetsHorizontalXl = EdgeInsets.symmetric(
    horizontal: xl,
  );

  // Symmetric Vertical
  static const EdgeInsets insetsVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets insetsVerticalS = EdgeInsets.symmetric(vertical: s);
  static const EdgeInsets insetsVerticalM = EdgeInsets.symmetric(vertical: m);
  static const EdgeInsets insetsVerticalL = EdgeInsets.symmetric(vertical: l);

  // Screen & Component Ergonomics
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: m,
    vertical: sm,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  static const EdgeInsets dialogPadding = EdgeInsets.all(l);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: l,
    vertical: sm,
  );
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: m,
    vertical: m,
  );

  // ===========================================================================
  // 4. Pre-composed SizedBox Gaps
  // ===========================================================================

  // Horizontal Gaps
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalS = SizedBox(width: s);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalM = SizedBox(width: m);
  static const SizedBox gapHorizontalL = SizedBox(width: l);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);

  // Vertical Gaps
  static const SizedBox gapVerticalXs = SizedBox(height: xs);
  static const SizedBox gapVerticalS = SizedBox(height: s);
  static const SizedBox gapVerticalSm = SizedBox(height: sm);
  static const SizedBox gapVerticalM = SizedBox(height: m);
  static const SizedBox gapVerticalL = SizedBox(height: l);
  static const SizedBox gapVerticalXl = SizedBox(height: xl);
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);
}

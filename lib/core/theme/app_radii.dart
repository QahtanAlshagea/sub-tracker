import 'package:flutter/material.dart';

/// Centralized corner radii and shape tokens for Sub Tracker.
///
/// Ensures consistent, elegant curves and eliminates arbitrary radius values across UI components.
abstract final class AppRadii {
  // ===========================================================================
  // 1. Raw Radius Scale (in logical pixels)
  // ===========================================================================

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 9999.0;

  // ===========================================================================
  // 2. Pre-composed Radius Instances
  // ===========================================================================

  static const Radius radiusNone = Radius.zero;
  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusS = Radius.circular(s);
  static const Radius radiusM = Radius.circular(m);
  static const Radius radiusL = Radius.circular(l);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusXxl = Radius.circular(xxl);
  static const Radius radiusFull = Radius.circular(full);

  // ===========================================================================
  // 3. Pre-composed BorderRadius Instances
  // ===========================================================================

  static const BorderRadius borderNone = BorderRadius.zero;
  static const BorderRadius borderXs = BorderRadius.all(radiusXs);
  static const BorderRadius borderS = BorderRadius.all(radiusS);
  static const BorderRadius borderM = BorderRadius.all(radiusM);
  static const BorderRadius borderL = BorderRadius.all(radiusL);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderXxl = BorderRadius.all(radiusXxl);
  static const BorderRadius borderFull = BorderRadius.all(radiusFull);

  // ===========================================================================
  // 4. Component-Specific Border Radii
  // ===========================================================================

  static const BorderRadius cardRadius = borderM;
  static const BorderRadius buttonRadius = borderS;
  static const BorderRadius inputRadius = borderS;
  static const BorderRadius dialogRadius = borderL;
  static const BorderRadius chipRadius = borderFull;
  static const BorderRadius badgeRadius = borderXs;

  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: radiusXl,
  );
}

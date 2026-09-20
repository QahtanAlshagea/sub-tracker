import 'package:flutter/material.dart';

/// Design tokens for Border Radii across UI components.
class AppRadii {
  AppRadii._();

  // Raw numeric radius values
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // BorderRadius instances
  static const BorderRadius borderRadiusNone = BorderRadius.zero;
  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(full),
  );

  // Semantic Component Radii
  static const BorderRadius cardRadius = borderRadiusLg;
  static const BorderRadius buttonRadius = borderRadiusMd;
  static const BorderRadius inputRadius = borderRadiusMd;
  static const BorderRadius badgeRadius = borderRadiusSm;
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static const BorderRadius dialogRadius = borderRadiusXl;
}

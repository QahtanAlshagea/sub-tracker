import 'package:flutter/material.dart';

/// Design tokens for Elevations and BoxShadows.
class AppShadows {
  AppShadows._();

  // ===========================================================================
  // LIGHT THEME SHADOWS
  // ===========================================================================
  static const List<BoxShadow> lightSm = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 3.0, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x100F172A), blurRadius: 2.0, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> lightMd = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 6.0, offset: Offset(0, 4)),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 15.0,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> lightLg = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 15.0,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 25.0,
      offset: Offset(0, 20),
    ),
  ];

  // ===========================================================================
  // DARK THEME SHADOWS (Subtle border/elevation tint without harsh glow)
  // ===========================================================================
  static const List<BoxShadow> darkSm = [
    BoxShadow(color: Color(0x33000000), blurRadius: 4.0, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(color: Color(0x66000000), blurRadius: 8.0, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(color: Color(0x88000000), blurRadius: 16.0, offset: Offset(0, 8)),
  ];

  // Component semantic shadows
  static List<BoxShadow> cardShadow(bool isDark) => isDark ? darkSm : lightSm;
  static List<BoxShadow> dialogShadow(bool isDark) => isDark ? darkLg : lightLg;
}

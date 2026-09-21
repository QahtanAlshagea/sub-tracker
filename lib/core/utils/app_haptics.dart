import 'package:flutter/services.dart';

/// Provides consistent, subtle haptic feedback for user interactions.
///
/// Complies with [NFR-01] and [NFR-04]:
/// - Safe execution: does not crash on platforms without haptic vibrators (e.g., Desktop/Web).
/// - Fast response: runs asynchronously without blocking the UI thread (< 16 ms budget).
class AppHaptics {
  AppHaptics._();

  /// Subtle feedback for toggling switches, selecting chips, or tab switching.
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Ignored on unsupported platforms.
    }
  }

  /// Light feedback for subtle user actions (e.g., pulling to refresh, marking as paid).
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignored on unsupported platforms.
    }
  }

  /// Medium feedback for important confirmation actions (e.g., deletion, reset).
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignored on unsupported platforms.
    }
  }

  /// Heavy feedback for critical or destructive warnings.
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Ignored on unsupported platforms.
    }
  }
}

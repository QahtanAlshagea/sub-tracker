import 'package:flutter/services.dart';

/// Helper utility for tactile haptic feedback across interactions.
///
/// Handles platform exceptions gracefully to guarantee stability in headless tests or unsupported devices.
abstract final class HapticFeedbackHelper {
  /// Light impact for general card taps and navigation triggers.
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignored for testing and unsupported platforms
    }
  }

  /// Selection click for segment choices, switches, and dropdowns.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Ignored for testing and unsupported platforms
    }
  }

  /// Medium impact for destructive actions (e.g. deletion) and undo operations.
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignored for testing and unsupported platforms
    }
  }
}

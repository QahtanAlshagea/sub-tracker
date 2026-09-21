import 'package:flutter/material.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/utils/app_haptics.dart';

/// Reusable Undo SnackBar for safe deletion per [US-12] and [EC-12-1]..[EC-12-4].
///
/// Features:
/// - 5-second duration countdown.
/// - Distinct Undo action button.
/// - Floating style with design system tokens.
class UndoDeletionSnackBar {
  UndoDeletionSnackBar._();

  static SnackBar create({
    required BuildContext context,
    required String itemName,
    required VoidCallback onUndo,
    String? message,
    String undoLabel = 'تراجع',
    Duration duration = const Duration(seconds: 5),
  }) {
    final theme = Theme.of(context);

    return SnackBar(
      content: Text(
        message ?? 'تم حذف "$itemName"',
        style: TextStyle(
          color: theme.colorScheme.onInverseSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      action: SnackBarAction(
        label: undoLabel,
        textColor: theme.colorScheme.primary,
        onPressed: () {
          AppHaptics.selectionClick();
          onUndo();
        },
      ),
    );
  }

  /// Displays the undo SnackBar cleanly, clearing any previous snackbars to prevent overlapping.
  static void show({
    required BuildContext context,
    required String itemName,
    required VoidCallback onUndo,
    String? message,
    String undoLabel = 'تراجع',
    Duration duration = const Duration(seconds: 5),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      create(
        context: context,
        itemName: itemName,
        onUndo: onUndo,
        message: message,
        undoLabel: undoLabel,
        duration: duration,
      ),
    );
  }
}

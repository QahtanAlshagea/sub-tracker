import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../app_theme_extension.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

/// Interactive touch target wrapper that enforces the minimum 48x48 dp
/// accessibility requirement specified in NFR-04 and WCAG 2.1 AA.
class MinTouchTarget extends StatelessWidget {
  final Widget child;
  final double minDimension;
  final VoidCallback? onTap;
  final String? tooltip;

  const MinTouchTarget({
    super.key,
    required this.child,
    this.minDimension = AppSpacing.touchTargetMin,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minDimension,
        minHeight: minDimension,
      ),
      child: Center(child: child),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: AppRadii.buttonRadius,
        child: content,
      );
    }

    if (tooltip != null) {
      content = Tooltip(message: tooltip!, child: content);
    }

    return content;
  }
}

/// Accessible Subscription Status Badge.
/// Implements [EC-40-3] (Color Blindness Safe): Colors are ALWAYS paired with
/// a semantic icon and clear textual description so users with color vision deficiency
/// are never excluded.
enum StatusBadgeType {
  active,
  paid,
  dueSoon,
  overdue,
  trial,
  cancelled,
  archived,
}

class AccessibleStatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String? customLabel;
  final IconData? customIcon;

  const AccessibleStatusBadge({
    super.key,
    required this.type,
    this.customLabel,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.appTheme;
    final l10n = AppLocalizations.of(context);

    final (label, icon, fgColor, bgColor) = switch (type) {
      StatusBadgeType.active => (
        l10n?.active ?? 'نشط',
        Icons.check_circle_outline,
        themeExt.statusPaid,
        themeExt.successContainer,
      ),
      StatusBadgeType.paid => (
        l10n?.paid ?? 'مسدّد',
        Icons.done_all,
        themeExt.statusPaid,
        themeExt.successContainer,
      ),
      StatusBadgeType.dueSoon => (
        l10n?.dueSoon ?? 'مستحق قريباً',
        Icons.schedule,
        themeExt.statusDueSoon,
        themeExt.warningContainer,
      ),
      StatusBadgeType.overdue => (
        l10n?.overdue ?? 'متأخر',
        Icons.error_outline,
        themeExt.statusOverdue,
        themeExt.warningContainer, // Or errorContainer
      ),
      StatusBadgeType.trial => (
        l10n?.trial ?? 'تجربة مجانية',
        Icons.stars_outlined,
        themeExt.warning,
        themeExt.warningContainer,
      ),
      StatusBadgeType.cancelled => (
        l10n?.cancelled ?? 'ملغى',
        Icons.cancel_outlined,
        themeExt.statusArchived,
        themeExt.borderSubtle,
      ),
      StatusBadgeType.archived => (
        l10n?.archived ?? 'مؤرشف',
        Icons.archive_outlined,
        themeExt.statusArchived,
        themeExt.borderSubtle,
      ),
    };

    final displayLabel = customLabel ?? label;
    final displayIcon = customIcon ?? icon;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.badgeRadius,
        border: Border.all(color: fgColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(displayIcon, size: 14.0, color: fgColor),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: fgColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

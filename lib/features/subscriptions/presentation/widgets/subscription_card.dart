import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/value_objects/subscription_status.dart';
import '../formatters/currency_formatter.dart';
import '../formatters/date_formatter.dart';

/// Interactive subscription card component displaying summary details,
/// status badges, recurrence info, and quick actions.
///
/// Complies with:
/// - [FR-02], [US-05], [EC-05-5]: Graceful long text truncation.
/// - [US-40], [EC-40-3]: Accessible status badges combining color, icon, and text.
/// - [US-37], [EC-37-1]: Double-tap protected quick actions.
/// - [NFR-04]: Minimum 48x48 dp touch targets.
class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final Category? category;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.category,
    this.onTap,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final daysRemaining = subscription.dueDate.daysUntil(DateTime.now());

    final categoryName = category?.name ?? (l10n?.uncategorized ?? 'غير مصنف');
    final categoryColor = category != null
        ? Color(category!.colorValue)
        : AppColors.indigo600;

    final StatusBadgeType badgeType;
    if (subscription.status == SubscriptionStatus.archived) {
      badgeType = StatusBadgeType.archived;
    } else if (subscription.isTrial) {
      badgeType = StatusBadgeType.trial;
    } else if (daysRemaining < 0) {
      badgeType = StatusBadgeType.overdue;
    } else if (daysRemaining <= 3) {
      badgeType = StatusBadgeType.dueSoon;
    } else {
      badgeType = StatusBadgeType.active;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.cardRadius,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Category chip & AccessibleStatusBadge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        categoryName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  AccessibleStatusBadge(type: badgeType),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Title Row with truncation
              Text(
                subscription.name,
                key: const Key('subscription_card_title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Price & Cycle
              Row(
                children: [
                  Text(
                    CurrencyFormatter.format(subscription.price),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (l10n != null)
                    Text(
                      '/ ${DateFormatter.formatCycle(subscription.cycle, l10n)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Footer: Countdown & Quick Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n != null
                            ? DateFormatter.formatRemainingDays(
                                daysRemaining,
                                l10n,
                              )
                            : '$daysRemaining days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: daysRemaining < 0
                              ? (isDark
                                    ? AppColors.darkError
                                    : AppColors.lightError)
                              : daysRemaining <= 3
                              ? (isDark
                                    ? AppColors.darkWarning
                                    : AppColors.lightWarning)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (onMarkPaid != null)
                    MinTouchTarget(
                      key: const Key('subscription_card_pay_button'),
                      child: TextButton.icon(
                        onPressed: onMarkPaid,
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        label: Text(l10n?.markAsPaid ?? 'تسديد'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import '../formatters/subscription_formatters.dart';
import '../utils/haptic_feedback_helper.dart';

/// Card component representing an individual subscription in the list with micro-interactions.
///
/// Implements [US-05], [EC-05-2], [EC-05-5], and Card C-17:
/// - Safe title truncation with ellipsis.
/// - Distinctive visual treatment for overdue and urgent renewals (<= 3 days) without relying on color alone.
/// - Minimum touch target compliant with WCAG AA (>= 48x48).
/// - Micro-scale animation on press (150ms <= 300ms) and light haptic feedback.
/// - Optional Dismissible swipe-to-delete with tactile feedback.
class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
  final Category? category;
  final VoidCallback? onTap;
  final DateTime? referenceDate;
  final void Function(DismissDirection direction)? onDismissed;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.category,
    this.onTap,
    this.referenceDate,
    this.onDismissed,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedbackHelper.light();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final urgency = SubscriptionFormatters.getUrgency(
      widget.subscription.dueDate,
      widget.referenceDate,
    );
    final dueText = SubscriptionFormatters.formatDueRemaining(
      widget.subscription.dueDate,
      widget.referenceDate,
    );
    final formattedPrice = SubscriptionFormatters.formatMoney(
      widget.subscription.price,
    );
    final formattedCycle = SubscriptionFormatters.formatCycleSuffix(
      widget.subscription.cycle,
    );

    // Category styling
    final Color catColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppColors.indigo500;
    final String catName = widget.category?.name ?? 'غير مصنّف';

    Widget cardContent = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        key: widget.key ?? Key('subscription_card_${widget.subscription.id}'),
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceContainer
              : AppColors.lightSurface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(
            color: urgency == DueDateUrgency.urgent
                ? (isDark ? AppColors.darkWarning : AppColors.amber500)
                : (urgency == DueDateUrgency.overdue
                      ? (isDark ? AppColors.darkError : AppColors.rose500)
                      : (isDark
                            ? AppColors.darkOutline
                            : AppColors.lightOutline)),
            width: urgency != DueDateUrgency.normal ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: AppRadii.cardRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Category icon, Name & Badges, Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Category Avatar / Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: catColor.withValues(alpha: 0.4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            catName.isNotEmpty ? catName.characters.first : '؟',
                            style: AppTypography.titleMedium.copyWith(
                              color: catColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        AppSpacing.gapHorizontalM,

                        // Middle Column: Subscription Name & Tags
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subscription.name,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xxs,
                                children: [
                                  // Category chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    decoration: const BoxDecoration(
                                      borderRadius: AppRadii.badgeRadius,
                                    ),
                                    child: Text(
                                      catName,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: catColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  // Trial tag
                                  if (widget.subscription.isTrial)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.indigo900.withValues(
                                                alpha: 0.5,
                                              )
                                            : AppColors.indigo50,
                                        borderRadius: AppRadii.badgeRadius,
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.indigo700
                                              : AppColors.indigo200,
                                        ),
                                      ),
                                      child: Text(
                                        'تجربة مجانية',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: isDark
                                                  ? AppColors.indigo200
                                                  : AppColors.indigo600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapHorizontalS,

                        // End Column: Price & Cycle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedPrice,
                              style: AppTypography.titleMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              formattedCycle,
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.gapVerticalS,

                    // Bottom Row: Due date status badge
                    _buildDueBadge(
                      context,
                      urgency: urgency,
                      dueText: dueText,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.onDismissed != null) {
      final deleteBg = Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkError : AppColors.rose600,
          borderRadius: AppRadii.cardRadius,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_outline_rounded, color: Colors.white),
                AppSpacing.gapHorizontalS,
                Text(
                  'حذف',
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'حذف',
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.gapHorizontalS,
                const Icon(Icons.delete_outline_rounded, color: Colors.white),
              ],
            ),
          ],
        ),
      );

      return Dismissible(
        key: Key('dismissible_${widget.subscription.id}'),
        direction: DismissDirection.horizontal,
        background: deleteBg,
        secondaryBackground: deleteBg,
        onDismissed: (direction) {
          HapticFeedbackHelper.medium();
          widget.onDismissed!(direction);
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildDueBadge(
    BuildContext context, {
    required DueDateUrgency urgency,
    required String dueText,
    required bool isDark,
  }) {
    final (bgColor, borderColor, textColor, icon) = switch (urgency) {
      DueDateUrgency.overdue => (
        isDark ? AppColors.rose700.withValues(alpha: 0.4) : AppColors.rose50,
        isDark ? AppColors.rose600 : AppColors.rose400,
        isDark ? AppColors.rose100 : AppColors.rose700,
        Icons.warning_amber_rounded,
      ),
      DueDateUrgency.urgent => (
        isDark ? AppColors.amber700.withValues(alpha: 0.4) : AppColors.amber50,
        isDark ? AppColors.amber600 : AppColors.amber500,
        isDark ? AppColors.amber100 : AppColors.amber700,
        Icons.access_time_filled_rounded,
      ),
      DueDateUrgency.normal => (
        isDark ? AppColors.darkSurfaceContainer : AppColors.slate100,
        isDark ? AppColors.darkOutline : AppColors.lightOutline,
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        Icons.calendar_today_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.badgeRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          AppSpacing.gapHorizontalXs,
          Text(
            dueText,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: urgency != DueDateUrgency.normal
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

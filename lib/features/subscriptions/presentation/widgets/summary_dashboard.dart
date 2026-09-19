import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../formatters/subscription_formatters.dart';
import '../state/expense_summary.dart';
import '../state/subscriptions_view_state.dart';

/// Expense summary dashboard board displaying monthly and yearly commitment analytics.
///
/// Implements [US-15], [US-16], and [EC-15-1]:
/// - Calculates monthly equivalent accurately.
/// - Separates multiple currencies into distinct indicators.
/// - Gracefully supports all 4 states (Loading, Empty, Data, Error).
class SummaryDashboard extends StatelessWidget {
  final ExpenseSummary? summary;
  final SubscriptionsViewState? state;
  final VoidCallback? onRetry;

  const SummaryDashboard({
    super.key = const Key('summary_dashboard'),
    this.summary,
    this.state,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine effective state
    if (state is SubscriptionsLoading) {
      return _buildLoadingSkeleton(context, isDark: isDark);
    }

    if (state is SubscriptionsError) {
      return _buildErrorCard(
        context,
        message: (state as SubscriptionsError).message,
        onRetry: (state as SubscriptionsError).onRetry ?? onRetry,
        isDark: isDark,
      );
    }

    final effectiveSummary =
        summary ??
        (state is SubscriptionsData
            ? (state as SubscriptionsData).summary
            : ExpenseSummary.zero());

    if (effectiveSummary.isEmpty) {
      return _buildEmptySummary(context, isDark: isDark);
    }

    return _buildDataCard(context, summary: effectiveSummary, isDark: isDark);
  }

  Widget _buildDataCard(
    BuildContext context, {
    required ExpenseSummary summary,
    required bool isDark,
  }) {
    final primaryTotal = SubscriptionFormatters.formatMoney(
      summary.primaryMonthlyTotal,
    );
    final yearlyTotal = SubscriptionFormatters.formatMoney(
      summary.primaryYearlyTotal,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [AppColors.slate900, AppColors.slate950]
              : [AppColors.indigo700, AppColors.indigo900],
        ),
        borderRadius: AppRadii.cardRadius,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.indigo900.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title and Active Count Badge (Responsive Wrap for 200% scale)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.xs,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: AppColors.indigo200,
                    ),
                    AppSpacing.gapHorizontalS,
                    Text(
                      'إجمالي الالتزام الشهري',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.indigo100,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    borderRadius: AppRadii.badgeRadius,
                  ),
                  child: Text(
                    '${summary.activeCount} نشط',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapVerticalM,

            // Main Primary Total Display
            Text(
              primaryTotal,
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            AppSpacing.gapVerticalS,

            // Secondary Info: Annual Projection (Responsive Wrap for 200% scale)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'المكافئ السنوي التقريبي: $yearlyTotal',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.indigo200,
                  ),
                ),
                if (summary.trialCount > 0) ...[
                  const Text('•', style: TextStyle(color: AppColors.indigo200)),
                  Text(
                    '${summary.trialCount} تجربة مجانية',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.amber500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),

            // Multi-currency indicator section (EC-15-1)
            if (summary.hasMultipleCurrencies) ...[
              AppSpacing.gapVerticalM,
              const Divider(color: Colors.white24, height: 1),
              AppSpacing.gapVerticalS,
              Text(
                'تفصيل العملات الأخرى:',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.indigo200,
                ),
              ),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final entry in summary.monthlyTotalsByCurrency.entries)
                    if (entry.key != summary.primaryCurrency)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: AppRadii.badgeRadius,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          '${SubscriptionFormatters.formatMoney(entry.value)} / شهر',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySummary(BuildContext context, {required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurface,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        ),
      ),
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.savings_outlined,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
            ),
          ),
          AppSpacing.gapHorizontalM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص المصروفات الشهرية',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'لا توجد اشتراكات نشطة حالياً لاحتساب الإجمالي.',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context, {
    required String message,
    required VoidCallback? onRetry,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.rose700.withValues(alpha: 0.3)
            : AppColors.rose50,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: isDark ? AppColors.rose600 : AppColors.rose100,
        ),
      ),
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: isDark ? AppColors.rose400 : AppColors.rose600,
          ),
          AppSpacing.gapHorizontalM,
          Expanded(
            child: Text(
              'تعذّر حساب الملخص المالي: $message',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.rose100 : AppColors.rose700,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('إعادة')),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, {required bool isDark}) {
    final baseColor = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.lightSurfaceContainer;
    final highlight = isDark
        ? AppColors.darkOutlineVariant
        : AppColors.lightOutlineVariant;

    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: highlight),
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 140,
            height: 16,
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: AppRadii.borderXs,
            ),
          ),
          Container(
            width: 200,
            height: 32,
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: AppRadii.borderXs,
            ),
          ),
          Container(
            width: 160,
            height: 14,
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: AppRadii.borderXs,
            ),
          ),
        ],
      ),
    );
  }
}

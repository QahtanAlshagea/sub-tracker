import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/utils/app_haptics.dart';
import '../formatters/currency_formatter.dart';
import '../state/summary_controller.dart';
import '../state/view_state.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/category_distribution_bar.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/monthly_comparison_chart.dart';

/// Financial analytics and summary dashboard screen.
///
/// Implements [FR-06], [FR-07], [US-15]..[US-20], [EC-15-1]..[EC-15-4]:
/// - Covers all 4 view states: Data, Loading, Empty, and Error with retry.
/// - Separates totals by currency strictly to satisfy the Money Rule.
/// - Renders Monthly Equivalent, Annual Equivalent, Upcoming Projections,
///   Highest Cost Subscription, and Category Distribution.
class SummaryScreen extends StatefulWidget {
  final SummaryController controller;
  final VoidCallback? onAddSubscription;
  final bool showAppBar;

  const SummaryScreen({
    super.key,
    required this.controller,
    this.onAddSubscription,
    this.showAppBar = true,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(l10n?.summaryTab ?? 'الملخص المالي'))
          : null,
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;

          return switch (state) {
            ViewStateLoading() => AppLoadingView(
              message: l10n?.summaryTab ?? 'جاري تحليل البيانات...',
            ),
            ViewStateEmpty(title: final t, subtitle: final sub) => AppEmptyView(
              title: t,
              subtitle: sub,
              icon: Icons.pie_chart_outline,
              actionLabel: l10n?.addFirstSubscription ?? 'إضافة أول اشتراك',
              onAction: widget.onAddSubscription,
            ),
            ViewStateError(message: final msg, onRetry: final retry) =>
              AppErrorView(
                message: msg,
                onRetry: retry,
                retryLabel: l10n?.retry ?? 'إعادة المحاولة',
              ),
            ViewStateData(data: final data) => RefreshIndicator(
              onRefresh: () => widget.controller.loadSummary(
                preferredCurrency: data.selectedCurrency,
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Multi-currency tabs if multiple currencies exist
                    if (data.summaries.keys.length > 1) ...[
                      _buildCurrencySelector(data),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Metrics Cards Grid
                    if (data.currentMonthlySummary != null) ...[
                      _buildMetricsSection(data, l10n),
                      const SizedBox(height: AppSpacing.lg),

                      // Monthly Comparison Bar Chart
                      MonthlyComparisonChart(
                        monthlySummary: data.currentMonthlySummary!,
                        upcomingProjection: data.upcomingProjection,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Highest Cost Subscription
                    if (data.highestCost != null) ...[
                      _buildHighestCostCard(context, data, l10n),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Category Distribution (Interactive Pie Chart & Breakdown)
                    if (data.categoryDistribution != null &&
                        data.categoryDistribution!.items.isNotEmpty) ...[
                      CategoryPieChart(
                        distribution: data.categoryDistribution!,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildCategoryDistribution(context, data, l10n),
                    ],
                  ],
                ),
              ),
            ),
          };
        },
      ),
    );
  }

  Widget _buildCurrencySelector(SummaryDashboardData data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: data.summaries.keys.map((currency) {
          final isSelected = currency == data.selectedCurrency;
          return Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            child: ChoiceChip(
              label: Text(currency),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  AppHaptics.selectionClick();
                  widget.controller.selectCurrency(currency);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsSection(
    SummaryDashboardData data,
    AppLocalizations? l10n,
  ) {
    final summary = data.currentMonthlySummary!;
    final projection = data.upcomingProjection;

    final card1 = MetricCard(
      title: l10n?.monthlyEquivalent ?? 'المكافئ الشهري',
      value: CurrencyFormatter.format(summary.totalMonthlyEquivalent),
      icon: Icons.calendar_view_month,
      iconColor: AppColors.indigo600,
    );

    final card2 = MetricCard(
      title: l10n?.annualEquivalent ?? 'المكافئ السنوي',
      value: CurrencyFormatter.format(summary.totalAnnualEquivalent),
      icon: Icons.event_repeat,
      iconColor: AppColors.emerald600,
    );

    final card3 = MetricCard(
      title: l10n?.activeSubscriptionsCount ?? 'الاشتراكات النشطة',
      value: '${summary.activeSubscriptionsCount}',
      icon: Icons.subscriptions_outlined,
      iconColor: AppColors.amber600,
    );

    final card4 = MetricCard(
      title: l10n?.upcomingRenewals ?? 'المتبقي هذا الشهر',
      value: projection != null
          ? CurrencyFormatter.format(projection.upcomingAmount)
          : '-',
      icon: Icons.pending_actions,
      iconColor: AppColors.rose600,
      subtitle: projection != null
          ? '${projection.occurrences.length} تجديدات'
          : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: card2),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: card3),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: card4),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: card2),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: card3),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: card4),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHighestCostCard(
    BuildContext context,
    SummaryDashboardData data,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highest = data.highestCost!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.cardRadius,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_outline,
                  size: 20,
                  color: AppColors.amber500,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n?.highestCostSubscription ?? 'الاشتراك الأعلى كلفة',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  highest.subscription.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(highest.monthlyEquivalent),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.indigo400 : AppColors.indigo600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'يمثل ${highest.percentageOfTotal.toStringAsFixed(1)}% من إجمالي الإنفاق الشهري لهذه العملة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(
    BuildContext context,
    SummaryDashboardData data,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = data.categoryDistribution!.items;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.cardRadius,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pie_chart,
                  size: 20,
                  color: AppColors.emerald500,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n?.categoryDistribution ?? 'توزيع الإنفاق حسب الفئات',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...items.map((item) => CategoryDistributionBar(item: item)),
          ],
        ),
      ),
    );
  }
}

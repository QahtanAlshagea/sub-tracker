import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/upcoming_projection.dart';
import '../formatters/currency_formatter.dart';

/// Interactive Bar Chart comparing monthly commitment vs upcoming remaining dues.
///
/// Features:
/// - Visual comparison of Total Monthly Equivalent vs Pending Dues.
/// - Progress indicator of paid percentage for current calendar month.
/// - Tooltips with precise currency amounts.
class MonthlyComparisonChart extends StatelessWidget {
  final MonthlySummary monthlySummary;
  final UpcomingProjection? upcomingProjection;

  const MonthlyComparisonChart({
    super.key,
    required this.monthlySummary,
    this.upcomingProjection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalMinor = monthlySummary.totalMonthlyEquivalent.amountMinorUnits
        .toDouble();
    final remainingMinor =
        (upcomingProjection?.upcomingAmount.amountMinorUnits ?? 0).toDouble();
    final paidMinor = (totalMinor - remainingMinor).clamp(0.0, totalMinor);
    final paidPercentage = totalMinor > 0
        ? (paidMinor / totalMinor) * 100
        : 0.0;

    final maxVal = totalMinor > 0 ? (totalMinor / 100) * 1.25 : 100.0;

    return Card(
      key: const Key('monthly_comparison_chart_card'),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bar_chart_rounded,
                      size: 20,
                      color: AppColors.emerald500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'مقارنة التزامات الشهر',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Text(
                    'مسدد: ${paidPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.emerald600,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Bar Chart
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = switch (group.x) {
                          0 => 'الإجمالي الشهري',
                          1 => 'المسدد حتى الآن',
                          _ => 'المتبقي استحقاقه',
                        };
                        return BarTooltipItem(
                          '$label\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: CurrencyFormatter.formatMinorUnits(
                                minorUnits: (rod.toY * 100).round(),
                                currency: monthlySummary
                                    .totalMonthlyEquivalent
                                    .currencyCode,
                              ),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final text = switch (val.toInt()) {
                            0 => 'الإجمالي',
                            1 => 'المسدد',
                            2 => 'المتبقي',
                            _ => '',
                          };
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalMinor / 100,
                          color: AppColors.indigo500,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: paidMinor / 100,
                          color: AppColors.emerald500,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: remainingMinor / 100,
                          color: AppColors.amber500,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

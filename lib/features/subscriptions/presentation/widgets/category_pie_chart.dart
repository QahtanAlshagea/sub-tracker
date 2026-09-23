import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../domain/entities/category_distribution_item.dart';
import '../formatters/currency_formatter.dart';

/// Interactive Pie Chart displaying category spending breakdown with dynamic touched slice.
///
/// Complies with:
/// - [FR-07] Category distribution with interactive visualization.
/// - Dynamic touched section enlargement and center data display.
/// - Detailed legend with category color, title, percentage, and currency totals.
class CategoryPieChart extends StatefulWidget {
  final CategoryDistributionResult distribution;

  const CategoryPieChart({super.key, required this.distribution});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = widget.distribution.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeItem = (_touchedIndex >= 0 && _touchedIndex < items.length)
        ? items[_touchedIndex]
        : null;

    return Card(
      key: const Key('category_pie_chart_card'),
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
                  Icons.pie_chart_outline_rounded,
                  size: 20,
                  color: AppColors.indigo500,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'الرسم البياني لتوزيع الإنفاق',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Interactive Pie Chart
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            final index = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                            if (index != _touchedIndex) {
                              AppHaptics.selectionClick();
                            }
                            _touchedIndex = index;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2.5,
                      centerSpaceRadius: 48,
                      sections: List.generate(items.length, (i) {
                        final isTouched = i == _touchedIndex;
                        final item = items[i];
                        final radius = isTouched ? 65.0 : 54.0;
                        final color = Color(item.colorValue);

                        return PieChartSectionData(
                          color: color,
                          value: item.percentage > 0 ? item.percentage : 1.0,
                          title: isTouched
                              ? '${item.percentage.toStringAsFixed(1)}%'
                              : (item.percentage >= 8.0
                                    ? '${item.percentage.toStringAsFixed(0)}%'
                                    : ''),
                          radius: radius,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 2),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  // Center info (touched category details or total)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeItem != null
                            ? activeItem.categoryName
                            : 'الإجمالي',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeItem != null
                            ? CurrencyFormatter.format(
                                activeItem.totalMonthlyEquivalent,
                              )
                            : CurrencyFormatter.format(
                                widget.distribution.totalMonthlyEquivalent,
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Legend Grid
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == _touchedIndex;
                final color = Color(item.colorValue);

                return InkWell(
                  key: Key('pie_legend_item_$index'),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() {
                      _touchedIndex = isSelected ? -1 : index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: isSelected
                          ? Border.all(color: color, width: 1.2)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          item.categoryName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '(${item.percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

/// Skeleton loading placeholder mimicking the home summary card and subscription cards.
///
/// Prevents blank white screens and maintains layout stability during asynchronous data loading.
class LoadingShimmerView extends StatelessWidget {
  const LoadingShimmerView({super.key = const Key('loading_shimmer_view')});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.lightSurfaceContainer;
    final highlightColor = isDark
        ? AppColors.darkOutlineVariant
        : AppColors.lightOutlineVariant;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: AppSpacing.screenPadding,
      children: [
        // Summary Card Skeleton
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: highlightColor),
          ),
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShimmerBlock(width: 140, height: 16, color: highlightColor),
              _buildShimmerBlock(width: 200, height: 32, color: highlightColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBlock(
                    width: 100,
                    height: 14,
                    color: highlightColor,
                  ),
                  _buildShimmerBlock(
                    width: 80,
                    height: 14,
                    color: highlightColor,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalL,

        // Subscription Card Skeletons (3 items)
        for (int i = 0; i < 3; i++) ...[
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: AppRadii.cardRadius,
              border: Border.all(color: highlightColor),
            ),
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                // Category Icon circle skeleton
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.gapHorizontalM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerBlock(
                        width: 120,
                        height: 16,
                        color: highlightColor,
                      ),
                      AppSpacing.gapVerticalXs,
                      _buildShimmerBlock(
                        width: 80,
                        height: 12,
                        color: highlightColor,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerBlock(
                      width: 70,
                      height: 18,
                      color: highlightColor,
                    ),
                    AppSpacing.gapVerticalXs,
                    _buildShimmerBlock(
                      width: 50,
                      height: 12,
                      color: highlightColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapVerticalS,
        ],
      ],
    );
  }

  Widget _buildShimmerBlock({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: AppRadii.borderXs),
    );
  }
}

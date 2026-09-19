import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

/// Reusable empty state view displaying an inviting illustration, guidance text, and a CTA button.
///
/// Designed to satisfy [EC-05-1]: "قاعدة فارغة تماماً عند التثبيت الجديد تعرض حالة فارغة مصممة بدعوة لإضافة أول التزام".
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateView({
    super.key = const Key('empty_state_view'),
    this.title = 'لا توجد التزامات دورية بعد',
    this.message =
        'أضف اشتراكاتك وفواتيرك الدورية لتتبّع مواعيد استحقاقها ومصروفاتها الشهرية بدقة.',
    this.actionLabel = 'إضافة التزام جديد',
    this.onAction,
    this.icon = Icons.receipt_long_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Prominent Illustration Icon Container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.indigo900.withValues(alpha: 0.4)
                    : AppColors.indigo50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.indigo700 : AppColors.indigo200,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? AppColors.indigo200 : AppColors.indigo600,
              ),
            ),
            AppSpacing.gapVerticalL,

            // Primary Title
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapVerticalS,

            // Descriptive Subtitle
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.gapVerticalXl,

            // Call to Action Button
            if (onAction != null)
              ElevatedButton.icon(
                key: const Key('empty_state_cta_button'),
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, AppSpacing.buttonHeight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.s,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.buttonRadius,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

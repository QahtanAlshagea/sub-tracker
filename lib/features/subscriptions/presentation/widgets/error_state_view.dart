import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

/// Reusable error state view displaying an error icon, user-friendly Arabic explanation,
/// and a prominent retry button.
///
/// Designed to satisfy [EC-05-4]: "فشل القراءة من القاعدة يعرض حالة خطأ تشرح السبب وتتيح إعادة المحاولة بدل شاشة بيضاء".
class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorStateView({
    super.key = const Key('error_state_view'),
    this.title = 'تعذّر تحميل البيانات',
    this.message =
        'حدث خطأ غير متوقع أثناء معالجة البيانات. يرجى المحاولة مرة أخرى.',
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
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
            // Error Alert Icon Container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkError.withValues(alpha: 0.2)
                    : AppColors.rose50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkError.withValues(alpha: 0.5)
                      : AppColors.lightError.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: isDark ? AppColors.darkError : AppColors.lightError,
              ),
            ),
            AppSpacing.gapVerticalL,

            // Error Title
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

            // Error Explanation Text
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
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

            // Retry Button
            if (onRetry != null)
              ElevatedButton.icon(
                key: const Key('error_retry_button'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(retryLabel),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, AppSpacing.buttonHeight),
                  backgroundColor: isDark
                      ? AppColors.indigo600
                      : AppColors.indigo600,
                  foregroundColor: Colors.white,
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

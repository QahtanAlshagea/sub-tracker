import 'package:flutter/material.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_spacing.dart';

/// Accessible error state view with actionable retry mechanism.
///
/// Implements [EC-05-4], [EC-15-4], and [NFR-04]:
/// - Replaces technical exceptions with friendly explanations.
/// - Minimum 48x48 dp touch target on the retry button.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkErrorContainer
                    : AppColors.lightErrorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: isDark ? AppColors.darkError : AppColors.lightError,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              MinTouchTarget(
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(retryLabel ?? 'إعادة المحاولة'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

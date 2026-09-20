import 'package:flutter/material.dart';
import 'tokens/app_colors.dart';

/// ThemeExtension to provide type-safe access to domain and semantic colors
/// not directly available on Flutter's standard [ColorScheme].
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color borderSubtle;
  final Color cardBorder;

  // Domain Subscription Status Colors
  final Color statusPaid;
  final Color statusDueSoon;
  final Color statusOverdue;
  final Color statusTrial;
  final Color statusArchived;

  const AppThemeExtension({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.borderSubtle,
    required this.cardBorder,
    required this.statusPaid,
    required this.statusDueSoon,
    required this.statusOverdue,
    required this.statusTrial,
    required this.statusArchived,
  });

  /// Light theme preset
  static const AppThemeExtension light = AppThemeExtension(
    success: AppColors.lightSuccess,
    onSuccess: AppColors.lightOnSuccess,
    successContainer: AppColors.lightSuccessContainer,
    onSuccessContainer: AppColors.lightOnSuccessContainer,
    warning: AppColors.lightWarning,
    onWarning: AppColors.lightOnWarning,
    warningContainer: AppColors.lightWarningContainer,
    onWarningContainer: AppColors.lightOnWarningContainer,
    info: AppColors.lightInfo,
    onInfo: AppColors.lightOnInfo,
    infoContainer: AppColors.lightInfoContainer,
    onInfoContainer: AppColors.lightOnInfoContainer,
    borderSubtle: AppColors.lightBorderSubtle,
    cardBorder: AppColors.lightBorder,
    statusPaid: AppColors.lightSuccess,
    statusDueSoon: AppColors.lightWarning,
    statusOverdue: AppColors.lightError,
    statusTrial: AppColors.lightWarning,
    statusArchived: AppColors.lightTextTertiary,
  );

  /// Dark theme preset
  static const AppThemeExtension dark = AppThemeExtension(
    success: AppColors.darkSuccess,
    onSuccess: AppColors.darkOnSuccess,
    successContainer: AppColors.darkSuccessContainer,
    onSuccessContainer: AppColors.darkOnSuccessContainer,
    warning: AppColors.darkWarning,
    onWarning: AppColors.darkOnWarning,
    warningContainer: AppColors.darkWarningContainer,
    onWarningContainer: AppColors.darkOnWarningContainer,
    info: AppColors.darkInfo,
    onInfo: AppColors.darkOnInfo,
    infoContainer: AppColors.darkInfoContainer,
    onInfoContainer: AppColors.darkOnInfoContainer,
    borderSubtle: AppColors.darkBorderSubtle,
    cardBorder: AppColors.darkBorder,
    statusPaid: AppColors.darkSuccess,
    statusDueSoon: AppColors.darkWarning,
    statusOverdue: AppColors.darkError,
    statusTrial: AppColors.darkWarning,
    statusArchived: AppColors.darkTextTertiary,
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? borderSubtle,
    Color? cardBorder,
    Color? statusPaid,
    Color? statusDueSoon,
    Color? statusOverdue,
    Color? statusTrial,
    Color? statusArchived,
  }) {
    return AppThemeExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      cardBorder: cardBorder ?? this.cardBorder,
      statusPaid: statusPaid ?? this.statusPaid,
      statusDueSoon: statusDueSoon ?? this.statusDueSoon,
      statusOverdue: statusOverdue ?? this.statusOverdue,
      statusTrial: statusTrial ?? this.statusTrial,
      statusArchived: statusArchived ?? this.statusArchived,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      statusPaid: Color.lerp(statusPaid, other.statusPaid, t)!,
      statusDueSoon: Color.lerp(statusDueSoon, other.statusDueSoon, t)!,
      statusOverdue: Color.lerp(statusOverdue, other.statusOverdue, t)!,
      statusTrial: Color.lerp(statusTrial, other.statusTrial, t)!,
      statusArchived: Color.lerp(statusArchived, other.statusArchived, t)!,
    );
  }
}

/// Convenience extension on BuildContext to easily access [AppThemeExtension].
extension AppThemeContextExtension on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
}

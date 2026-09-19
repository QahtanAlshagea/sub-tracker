import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_radii.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Single source of truth for all design tokens in Sub Tracker.
///
/// Ensures strict elimination of magic values and guarantees consistency across:
/// - Colors (Light / Dark semantic scales + contrast calculation)
/// - Spacing & Insets (4px / 8px incremental grid + 48x48 touch targets)
/// - Corner Radii & Shapes
/// - Typography (Arabic-first metrics + 200% scale safety)
abstract final class AppTokens {
  // Direct namespace references
  static const colors = AppColors;
  static const spacing = AppSpacing;
  static const radii = AppRadii;
  static const typography = AppTypography;
}

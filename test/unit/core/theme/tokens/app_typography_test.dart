import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/tokens/app_colors.dart';
import 'package:sub_tracker/core/theme/tokens/app_typography.dart';

void main() {
  group('AppTypography Design Tokens & Scale Tests (NFR-04, NFR-08)', () {
    test('lightTextTheme has complete Material 3 typographic scale', () {
      final textTheme = AppTypography.lightTextTheme;

      expect(textTheme.displayLarge?.fontSize, equals(40.0));
      expect(textTheme.headlineMedium?.fontSize, equals(22.0));
      expect(textTheme.titleMedium?.fontSize, equals(16.0));
      expect(textTheme.bodyLarge?.fontSize, equals(16.0));
      expect(textTheme.bodyMedium?.fontSize, equals(14.0));
      expect(textTheme.bodySmall?.fontSize, equals(12.0));
      expect(textTheme.labelMedium?.fontSize, equals(12.0));

      expect(textTheme.bodyLarge?.color, equals(AppColors.lightTextPrimary));
      expect(textTheme.bodyMedium?.color, equals(AppColors.lightTextSecondary));
    });

    test(
      'darkTextTheme has complete Material 3 typographic scale with dark colors',
      () {
        final textTheme = AppTypography.darkTextTheme;

        expect(textTheme.displayLarge?.fontSize, equals(40.0));
        expect(textTheme.bodyLarge?.fontSize, equals(16.0));
        expect(textTheme.bodyMedium?.fontSize, equals(14.0));

        expect(textTheme.bodyLarge?.color, equals(AppColors.darkTextPrimary));
        expect(
          textTheme.bodyMedium?.color,
          equals(AppColors.darkTextSecondary),
        );
      },
    );

    test(
      'line heights (height) are safely set to prevent Arabic diacritic clipping',
      () {
        final lightTheme = AppTypography.lightTextTheme;

        expect(lightTheme.displayLarge?.height, greaterThanOrEqualTo(1.2));
        expect(lightTheme.headlineLarge?.height, greaterThanOrEqualTo(1.25));
        expect(lightTheme.titleMedium?.height, greaterThanOrEqualTo(1.3));
        expect(lightTheme.bodyLarge?.height, greaterThanOrEqualTo(1.4));
        expect(lightTheme.bodyMedium?.height, greaterThanOrEqualTo(1.4));
      },
    );
  });
}

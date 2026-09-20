import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/tokens/app_colors.dart';

void main() {
  group('AppColors & WCAG 2.1 AA Contrast Ratio Tests (NFR-04)', () {
    test('computes relative luminance correctly for pure white and black', () {
      expect(
        AppColors.computeLuminance(const Color(0xFFFFFFFF)),
        closeTo(1.0, 0.01),
      );
      expect(
        AppColors.computeLuminance(const Color(0xFF000000)),
        closeTo(0.0, 0.01),
      );
    });

    test('contrast ratio between pure black and white is exactly 21.0:1', () {
      final ratio = AppColors.calculateContrastRatio(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
      );
      expect(ratio, closeTo(21.0, 0.1));
    });

    group(
      'Light Theme WCAG 2.1 AA Compliance (Contrast ≥ 4.5:1 for normal text)',
      () {
        test(
          'lightTextPrimary against lightSurface meets or exceeds 4.5:1',
          () {
            final ratio = AppColors.calculateContrastRatio(
              AppColors.lightTextPrimary,
              AppColors.lightSurface,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason:
                  'lightTextPrimary on lightSurface failed contrast: $ratio',
            );
          },
        );

        test(
          'lightTextPrimary against lightBackground meets or exceeds 4.5:1',
          () {
            final ratio = AppColors.calculateContrastRatio(
              AppColors.lightTextPrimary,
              AppColors.lightBackground,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason:
                  'lightTextPrimary on lightBackground failed contrast: $ratio',
            );
          },
        );

        test(
          'lightTextSecondary against lightSurface meets or exceeds 4.5:1',
          () {
            final ratio = AppColors.calculateContrastRatio(
              AppColors.lightTextSecondary,
              AppColors.lightSurface,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason:
                  'lightTextSecondary on lightSurface failed contrast: $ratio',
            );
          },
        );

        test(
          'lightPrimary button background against lightOnPrimary text meets or exceeds 4.5:1',
          () {
            final ratio = AppColors.calculateContrastRatio(
              AppColors.lightOnPrimary,
              AppColors.lightPrimary,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: 'lightOnPrimary on lightPrimary failed contrast: $ratio',
            );
          },
        );

        test('lightSuccess against lightOnSuccess meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.lightOnSuccess,
            AppColors.lightSuccess,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'lightOnSuccess on lightSuccess failed contrast: $ratio',
          );
        });

        test('lightError against lightOnError meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.lightOnError,
            AppColors.lightError,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'lightOnError on lightError failed contrast: $ratio',
          );
        });

        test('lightWarning against lightOnWarning meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.lightOnWarning,
            AppColors.lightWarning,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'lightOnWarning on lightWarning failed contrast: $ratio',
          );
        });
      },
    );

    group(
      'Dark Theme WCAG 2.1 AA Compliance (Contrast ≥ 4.5:1 for normal text)',
      () {
        test('darkTextPrimary against darkSurface meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.darkTextPrimary,
            AppColors.darkSurface,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'darkTextPrimary on darkSurface failed contrast: $ratio',
          );
        });

        test(
          'darkTextPrimary against darkBackground meets or exceeds 4.5:1',
          () {
            final ratio = AppColors.calculateContrastRatio(
              AppColors.darkTextPrimary,
              AppColors.darkBackground,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason:
                  'darkTextPrimary on darkBackground failed contrast: $ratio',
            );
          },
        );

        test(
          'darkTextSecondary against darkSurface meets or exceeds 4.5:1',
          () {
            final ratio = AppColors.calculateContrastRatio(
              AppColors.darkTextSecondary,
              AppColors.darkSurface,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason:
                  'darkTextSecondary on darkSurface failed contrast: $ratio',
            );
          },
        );

        test('darkPrimary against darkBackground meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.darkPrimary,
            AppColors.darkBackground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'darkPrimary on darkBackground failed contrast: $ratio',
          );
        });

        test('darkSuccess against darkBackground meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.darkSuccess,
            AppColors.darkBackground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'darkSuccess on darkBackground failed contrast: $ratio',
          );
        });

        test('darkError against darkBackground meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.darkError,
            AppColors.darkBackground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'darkError on darkBackground failed contrast: $ratio',
          );
        });

        test('darkWarning against darkBackground meets or exceeds 4.5:1', () {
          final ratio = AppColors.calculateContrastRatio(
            AppColors.darkWarning,
            AppColors.darkBackground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'darkWarning on darkBackground failed contrast: $ratio',
          );
        });
      },
    );

    test(
      'isWcagAANormalText and isWcagAALargeText utility helpers work accurately',
      () {
        expect(
          AppColors.isWcagAANormalText(
            AppColors.lightTextPrimary,
            AppColors.lightSurface,
          ),
          isTrue,
        );
        expect(
          AppColors.isWcagAALargeText(
            AppColors.lightTextSecondary,
            AppColors.lightSurface,
          ),
          isTrue,
        );
      },
    );
  });
}

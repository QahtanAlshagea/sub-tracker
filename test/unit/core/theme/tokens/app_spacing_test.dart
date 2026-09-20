import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/tokens/app_spacing.dart';

void main() {
  group('AppSpacing Design Tokens & Touch Target Tests (NFR-04)', () {
    test('numeric scale follows 4px sub-grid and 8px primary grid', () {
      expect(AppSpacing.xxs, equals(2.0));
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(12.0));
      expect(AppSpacing.lg, equals(16.0));
      expect(AppSpacing.xl, equals(20.0));
      expect(AppSpacing.xxl, equals(24.0));
      expect(AppSpacing.xxxl, equals(32.0));
      expect(AppSpacing.huge, equals(48.0));
    });

    test('touchTargetMin strictly equals 48.0 dp for WCAG AA compliance', () {
      expect(AppSpacing.touchTargetMin, equals(48.0));
    });

    test('semantic insets match expected spacing values', () {
      expect(AppSpacing.allSm, equals(const EdgeInsets.all(8.0)));
      expect(AppSpacing.allMd, equals(const EdgeInsets.all(12.0)));
      expect(AppSpacing.allLg, equals(const EdgeInsets.all(16.0)));

      expect(
        AppSpacing.screenPadding,
        equals(const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
      );
      expect(AppSpacing.cardPadding, equals(const EdgeInsets.all(16.0)));
      expect(
        AppSpacing.buttonPadding,
        equals(const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0)),
      );
    });

    test('gap widgets have expected sizes', () {
      expect((AppSpacing.gapVerticalSm as SizedBox).height, equals(8.0));
      expect((AppSpacing.gapVerticalMd as SizedBox).height, equals(12.0));
      expect((AppSpacing.gapVerticalLg as SizedBox).height, equals(16.0));

      expect((AppSpacing.gapHorizontalSm as SizedBox).width, equals(8.0));
      expect((AppSpacing.gapHorizontalMd as SizedBox).width, equals(12.0));
      expect((AppSpacing.gapHorizontalLg as SizedBox).width, equals(16.0));
    });
  });
}

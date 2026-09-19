import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/validators/category_validator.dart';

void main() {
  group('CategoryValidator Tests', () {
    group('BR-05 & EC-21: Category Name Boundaries', () {
      test('BR-05 / EC-21-2: reject empty category name (length 0)', () {
        final result = CategoryValidator.validateName('');
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(CategoryValidationFailure.emptyName()),
        );
      });

      test('BR-05 / EC-21-2: reject whitespace-only category name', () {
        final result = CategoryValidator.validateName('   ');
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(CategoryValidationFailure.emptyName()),
        );
      });

      test('BR-05: accept category name at lower boundary (length 1)', () {
        final result = CategoryValidator.validateName('X');
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('X'));
      });

      test('BR-05: accept category name at upper boundary (length 24)', () {
        final name24 = 'c' * 24;
        final result = CategoryValidator.validateName(name24);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(name24));
      });

      test(
        'BR-05 / EC-21-1: reject category name above boundary (length 25)',
        () {
          final name25 = 'c' * 25;
          final result = CategoryValidator.validateName(name25);
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(CategoryValidationFailure.nameTooLong()),
          );
        },
      );

      test(
        'BR-05: normalize name by trimming, collapsing spaces, and lowercasing',
        () {
          expect(
            CategoryValidator.normalizeName('   Entertainment    Media  '),
            equals('entertainment media'),
          );
          expect(
            CategoryValidator.normalizeName('سحابة   وتخزين'),
            equals('سحابة وتخزين'),
          );
        },
      );
    });

    group('EC-21-3: System Category Protection', () {
      test('EC-21-3: reject modification of system category', () {
        final systemCat = Category.systemUncategorized();
        final result = CategoryValidator.validateModification(systemCat);
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(CategoryValidationFailure.cannotModifySystemCategory()),
        );
      });

      test('accept modification of user-created custom category', () {
        final customCat = Category(
          id: 'cat-custom',
          name: 'Gaming',
          colorValue: 0xFF10B981,
          createdAt: DateTime.utc(2026, 1, 1),
          isSystem: false,
        );
        final result = CategoryValidator.validateModification(customCat);
        expect(result.isSuccess, isTrue);
      });

      test('validateCategory accepts valid custom category', () {
        final customCat = Category(
          id: 'cat-custom',
          name: 'Education',
          colorValue: 0xFF10B981,
          createdAt: DateTime.utc(2026, 1, 1),
          isSystem: false,
        );
        final result = CategoryValidator.validateCategory(customCat);
        expect(result.isSuccess, isTrue);
      });
    });
  });
}

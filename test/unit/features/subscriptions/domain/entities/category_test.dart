import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';

void main() {
  group('Category Entity Tests', () {
    test('US-05: creates valid Category entity successfully', () {
      final category = Category.create(
        id: 'cat-1',
        name: 'Entertainment',
        colorValue: 0xFF4F46E5,
        iconCode: 'tv',
      );

      expect(category.id, 'cat-1');
      expect(category.name, 'Entertainment');
      expect(category.colorValue, 0xFF4F46E5);
      expect(category.iconCode, 'tv');
      expect(category.isSystem, isFalse);
    });

    test('US-05 / [EC-04-1]: rejects empty category name', () {
      expect(
        () => Category.create(id: 'cat-2', name: '   ', colorValue: 0xFF000000),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test(
      'US-05 / [EC-04-1]: rejects category name exceeding 24 characters',
      () {
        expect(
          () => Category.create(
            id: 'cat-3',
            name: 'A very long category name that exceeds limits',
            colorValue: 0xFF000000,
          ),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test(
      'US-05 / [EC-04-2]: systemUncategorized creates immutable system category',
      () {
        final systemCat = Category.systemUncategorized();

        expect(systemCat.name, 'غير مصنّف');
        expect(systemCat.isSystem, isTrue);
        expect(systemCat.id, 'system_uncategorized_id');
      },
    );

    test('US-05: copyWith and equality work accurately', () {
      final c1 = Category.create(
        id: 'cat-1',
        name: 'Work',
        colorValue: 0xFF123456,
        iconCode: 'briefcase',
        isSystem: false,
      );
      final c2 = c1.copyWith(
        id: 'cat-2',
        name: 'Office',
        colorValue: 0xFF654321,
        iconCode: 'building',
        isSystem: true,
      );

      expect(c2.id, 'cat-2');
      expect(c2.name, 'Office');
      expect(c2.colorValue, 0xFF654321);
      expect(c2.iconCode, 'building');
      expect(c2.isSystem, isTrue);
      expect(c1, equals(c1.copyWith()));
      expect(c1.hashCode, isNotNull);
      expect(c1.toString(), contains('Work'));
    });
  });
}

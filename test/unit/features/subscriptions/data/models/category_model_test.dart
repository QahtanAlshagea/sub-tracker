import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart' as db;
import 'package:sub_tracker/features/subscriptions/data/models/category_model.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';

void main() {
  group('CategoryModel Tests (C-13)', () {
    final testDate = DateTime.utc(2026, 3, 15, 10, 30);

    test(
      'CategoryModel.fromEntity converts Domain Category to Model and Companions accurately',
      () {
        final entity = Category(
          id: 'cat_tech',
          name: 'تقنية وسحابة',
          colorValue: 0xFF4F46E5,
          iconCode: 'cloud_icon',
          isSystem: false,
          createdAt: testDate,
        );

        final model = CategoryModel.fromEntity(entity);

        expect(model.id, equals('cat_tech'));
        expect(model.name, equals('تقنية وسحابة'));
        expect(model.colorValue, equals(0xFF4F46E5));
        expect(model.iconCode, equals('cloud_icon'));
        expect(model.isSystem, isFalse);
        expect(model.createdAt, equals(testDate));

        final companion = model.toCompanion();
        expect(companion.id.value, equals('cat_tech'));
        expect(companion.name.value, equals('تقنية وسحابة'));
        expect(companion.colorValue.value, equals(0xFF4F46E5));
        expect(companion.iconCode.value, equals('cloud_icon'));
        expect(companion.isSystem.value, isFalse);
        expect(companion.createdAt.value, equals(testDate));
      },
    );

    test(
      'CategoryModel.toEntity reconstructs pure Domain Category perfectly',
      () {
        final model = CategoryModel(
          id: 'cat_system',
          name: 'غير مصنّف',
          colorValue: 0xFF9CA3AF,
          iconCode: 'folder_outline',
          isSystem: true,
          createdAt: DateTime.utc(2026, 1, 1),
        );

        final entity = model.toEntity();

        expect(entity.id, equals('cat_system'));
        expect(entity.name, equals('غير مصنّف'));
        expect(entity.colorValue, equals(0xFF9CA3AF));
        expect(entity.iconCode, equals('folder_outline'));
        expect(entity.isSystem, isTrue);
        expect(entity.createdAt, equals(DateTime.utc(2026, 1, 1)));
      },
    );

    test('CategoryModel.fromData maps Drift generated row class to Model', () {
      final driftData = db.Category(
        id: 'cat_drift',
        name: 'ترفيه',
        colorValue: 0xFFFF5722,
        iconCode: 'movie',
        isSystem: false,
        createdAt: testDate,
      );

      final model = CategoryModel.fromData(driftData);

      expect(model.id, equals('cat_drift'));
      expect(model.name, equals('ترفيه'));
      expect(model.colorValue, equals(0xFFFF5722));
      expect(model.iconCode, equals('movie'));
      expect(model.isSystem, isFalse);
      expect(model.createdAt, equals(testDate));
    });

    test(
      'CategoryModel JSON serialization and deserialization preserves all attributes',
      () {
        final model = CategoryModel(
          id: 'cat_json',
          name: 'اشتراكات شخصية',
          colorValue: 0xFF10B981,
          iconCode: 'person',
          isSystem: false,
          createdAt: testDate,
        );

        final json = model.toJson();
        final restored = CategoryModel.fromJson(json);

        expect(restored, equals(model));
        expect(restored.hashCode, equals(model.hashCode));
        expect(restored.toString(), contains('cat_json'));
      },
    );
  });
}

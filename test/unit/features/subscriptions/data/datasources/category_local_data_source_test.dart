import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/category_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/models/category_model.dart';

void main() {
  late AppDatabase db;
  late CategoryLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = CategoryLocalDataSourceImpl(db.categoryDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryLocalDataSource Tests (C-13)', () {
    final testDate = DateTime.utc(2026, 3, 1, 12, 0);

    test(
      'createCategory and getCategoryById persist and retrieve category model',
      () async {
        final model = CategoryModel(
          id: 'cat_news',
          name: 'أخبار وصحافة',
          colorValue: 0xFFEF4444,
          iconCode: 'newspaper',
          isSystem: false,
          createdAt: testDate,
        );

        final created = await dataSource.createCategory(model);
        expect(created.id, equals('cat_news'));
        expect(created.name, equals('أخبار وصحافة'));

        final fetched = await dataSource.getCategoryById('cat_news');
        expect(fetched, isNotNull);
        expect(fetched!.name, equals('أخبار وصحافة'));
        expect(fetched.colorValue, equals(0xFFEF4444));
      },
    );

    test('getCategoryById returns null for non-existent category', () async {
      final fetched = await dataSource.getCategoryById('unknown_id');
      expect(fetched, isNull);
    });

    test(
      'getAllCategories and watchCategories return seeded and newly added categories',
      () async {
        final initial = await dataSource.getAllCategories();
        // Should contain at least the seeded system category
        expect(initial.any((c) => c.id == 'system_uncategorized_id'), isTrue);

        final stream = dataSource.watchCategories();
        final streamInitial = await stream.first;
        expect(
          streamInitial.any((c) => c.id == 'system_uncategorized_id'),
          isTrue,
        );

        await dataSource.createCategory(
          CategoryModel(
            id: 'cat_stream',
            name: 'بث وموسيقى',
            colorValue: 0xFF3B82F6,
            createdAt: testDate,
          ),
        );

        final updated = await dataSource.getAllCategories();
        expect(updated.any((c) => c.id == 'cat_stream'), isTrue);
      },
    );

    test('updateCategory modifies existing row attributes', () async {
      await dataSource.createCategory(
        CategoryModel(
          id: 'cat_edit',
          name: 'اسم قديم',
          colorValue: 0xFF111111,
          createdAt: testDate,
        ),
      );

      final updatedModel = CategoryModel(
        id: 'cat_edit',
        name: 'اسم جديد محدث',
        colorValue: 0xFF222222,
        iconCode: 'updated_icon',
        createdAt: testDate,
      );

      final result = await dataSource.updateCategory(updatedModel);
      expect(result.name, equals('اسم جديد محدث'));
      expect(result.colorValue, equals(0xFF222222));
      expect(result.iconCode, equals('updated_icon'));
    });

    test(
      'deleteCategoryWithReassignment orchestrates atomic category deletion',
      () async {
        await dataSource.createCategory(
          CategoryModel(
            id: 'cat_to_delete',
            name: 'فئة للحذف',
            colorValue: 0xFF888888,
            createdAt: testDate,
          ),
        );

        await dataSource.deleteCategoryWithReassignment(
          id: 'cat_to_delete',
          fallbackId: 'system_uncategorized_id',
        );

        final check = await dataSource.getCategoryById('cat_to_delete');
        expect(check, isNull);
      },
    );
  });
}

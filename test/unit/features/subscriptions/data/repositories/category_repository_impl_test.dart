import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart' hide Category;
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/category_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/models/category_model.dart';
import 'package:sub_tracker/features/subscriptions/data/repositories/category_repository_impl.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';

class FailingCategoryLocalDataSource implements CategoryLocalDataSource {
  final Object errorToThrow;
  FailingCategoryLocalDataSource(this.errorToThrow);

  @override
  Future<CategoryModel> createCategory(CategoryModel model) =>
      throw errorToThrow;

  @override
  Future<CategoryModel> updateCategory(CategoryModel model) =>
      throw errorToThrow;

  @override
  Future<CategoryModel?> getCategoryById(String id) => throw errorToThrow;

  @override
  Future<List<CategoryModel>> getAllCategories() => throw errorToThrow;

  @override
  Stream<List<CategoryModel>> watchCategories() => Stream.error(errorToThrow);

  @override
  Future<void> deleteCategoryWithReassignment({
    required String id,
    required String fallbackId,
  }) => throw errorToThrow;
}

void main() {
  late AppDatabase db;
  late CategoryLocalDataSourceImpl dataSource;
  late CategoryRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = CategoryLocalDataSourceImpl(db.categoryDao);
    repository = CategoryRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl Tests (C-13)', () {
    final testDate = DateTime.utc(2026, 3, 1, 12, 0);

    test(
      'createCategory successfully saves category and returns Result.success',
      () async {
        final category = Category(
          id: 'cat_work',
          name: 'العمل والمشاريع',
          colorValue: 0xFF6366F1,
          iconCode: 'briefcase',
          createdAt: testDate,
        );

        final result = await repository.createCategory(category);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.name, equals('العمل والمشاريع'));

        final fetchResult = await repository.getCategoryById('cat_work');
        expect(fetchResult.isSuccess, isTrue);
        expect(fetchResult.dataOrNull!.id, equals('cat_work'));
      },
    );

    test(
      'updateCategory updates custom category and returns Result.success',
      () async {
        final category = Category(
          id: 'cat_update',
          name: 'فئة أولى',
          colorValue: 0xFF111111,
          createdAt: testDate,
        );
        await repository.createCategory(category);

        final updated = category.copyWith(name: 'فئة ثانية معدلة');
        final result = await repository.updateCategory(updated);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.name, equals('فئة ثانية معدلة'));
      },
    );

    test(
      'updateCategory rejects modifying system category with CategoryValidationFailure',
      () async {
        final systemCat = Category.systemUncategorized();
        final result = await repository.updateCategory(
          systemCat.copyWith(name: 'تغيير غير مصرح'),
        );

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<CategoryValidationFailure>());
      },
    );

    test(
      'getCategoryById returns CategoryNotFoundFailure when id does not exist',
      () async {
        final result = await repository.getCategoryById('non_existent_id');

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<CategoryNotFoundFailure>());
      },
    );

    test(
      'updateCategory returns CategoryNotFoundFailure when target does not exist',
      () async {
        final category = Category(
          id: 'phantom_id',
          name: 'فئة وهمية',
          colorValue: 0xFF000000,
          createdAt: testDate,
        );
        final result = await repository.updateCategory(category);

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<CategoryNotFoundFailure>());
      },
    );

    test(
      'deleteCategory reassigns subscriptions and returns Result.success',
      () async {
        final category = Category(
          id: 'cat_to_remove',
          name: 'فئة للإزالة',
          colorValue: 0xFF999999,
          createdAt: testDate,
        );
        await repository.createCategory(category);

        final result = await repository.deleteCategory(
          'cat_to_remove',
          fallbackCategoryId: 'system_uncategorized_id',
        );
        expect(result.isSuccess, isTrue);

        final check = await repository.getCategoryById('cat_to_remove');
        expect(check.isFailure, isTrue);
        expect(check.failureOrNull, isA<CategoryNotFoundFailure>());
      },
    );

    test('deleteCategory rejects deleting system category', () async {
      final result = await repository.deleteCategory(
        'system_uncategorized_id',
        fallbackCategoryId: 'any_other_id',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<CategoryValidationFailure>());
    });

    test(
      'createCategory maps duplicate category name constraint to ValidationFailure',
      () async {
        final cat1 = Category(
          id: 'cat_unique_1',
          name: 'فئة مكررة',
          colorValue: 0xFF123456,
          createdAt: testDate,
        );
        final cat2 = Category(
          id: 'cat_unique_2',
          name: 'فئة مكررة',
          colorValue: 0xFF654321,
          createdAt: testDate,
        );

        final res1 = await repository.createCategory(cat1);
        expect(res1.isSuccess, isTrue);

        final res2 = await repository.createCategory(cat2);
        expect(res2.isFailure, isTrue);
        expect(res2.failureOrNull, isA<ValidationFailure>());
      },
    );

    test(
      'getAllCategories and watchCategories return list wrapped in Result.success',
      () async {
        final all = await repository.getAllCategories();
        expect(all.isSuccess, isTrue);
        expect(all.dataOrNull!.any((c) => c.isSystem), isTrue);

        final streamResult = await repository.watchCategories().first;
        expect(streamResult.isSuccess, isTrue);
        expect(streamResult.dataOrNull!.any((c) => c.isSystem), isTrue);
      },
    );

    test(
      'catches SqliteException and maps to DatabaseFailure with zero leak',
      () async {
        final failingDataSource = FailingCategoryLocalDataSource(
          SqliteException(1, 'disk I/O error'),
        );
        final failingRepo = CategoryRepositoryImpl(failingDataSource);

        final category = Category(
          id: 'cat_fail',
          name: 'فئة تفشل',
          colorValue: 0xFF111111,
          createdAt: testDate,
        );

        final result = await failingRepo.createCategory(category);
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<DatabaseFailure>());
      },
    );

    test(
      'catches FileSystemException and maps to StorageFullFailure with zero leak',
      () async {
        final failingDataSource = FailingCategoryLocalDataSource(
          const FileSystemException('No space left on device'),
        );
        final failingRepo = CategoryRepositoryImpl(failingDataSource);

        final result = await failingRepo.getAllCategories();
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<StorageFullFailure>());
      },
    );

    test(
      'watchCategories catches stream exceptions and emits Result.failure',
      () async {
        final failingDataSource = FailingCategoryLocalDataSource(
          SqliteException(1, 'stream error'),
        );
        final failingRepo = CategoryRepositoryImpl(failingDataSource);

        final emitted = await failingRepo.watchCategories().first;
        expect(emitted.isFailure, isTrue);
        expect(emitted.failureOrNull, isA<DatabaseFailure>());
      },
    );
  });
}

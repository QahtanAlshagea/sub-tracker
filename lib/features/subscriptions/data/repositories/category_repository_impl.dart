import 'dart:io';
import 'package:drift/native.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/failures/subscription_failures.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';

/// Implementation of [CategoryRepository] adhering strictly to Clean Architecture.
///
/// Orchestrates [CategoryLocalDataSource] and encapsulates all low-level persistence
/// details and database exceptions, translating them into pure domain [Failure] types.
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  const CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final created = await _localDataSource.createCategory(model);
      return Result.success(created.toEntity());
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067 ||
          e.message.toLowerCase().contains('unique')) {
        return Result.failure(
          const ValidationFailure('اسم الفئة موجود بالفعل.'),
        );
      }
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    if (category.isSystem || category.id == 'system_uncategorized_id') {
      return Result.failure(
        CategoryValidationFailure.cannotModifySystemCategory(),
      );
    }

    try {
      final existing = await _localDataSource.getCategoryById(category.id);
      if (existing == null) {
        return Result.failure(CategoryNotFoundFailure(category.id));
      }

      final model = CategoryModel.fromEntity(category);
      final updated = await _localDataSource.updateCategory(model);
      return Result.success(updated.toEntity());
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067 ||
          e.message.toLowerCase().contains('unique')) {
        return Result.failure(
          const ValidationFailure('اسم الفئة موجود بالفعل.'),
        );
      }
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    try {
      final model = await _localDataSource.getCategoryById(id);
      if (model == null) {
        return Result.failure(CategoryNotFoundFailure(id));
      }
      return Result.success(model.toEntity());
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      final list = await _localDataSource.getAllCategories();
      final entities = list.map((m) => m.toEntity()).toList();
      return Result.success(entities);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Result<List<Category>>> watchCategories() async* {
    try {
      await for (final list in _localDataSource.watchCategories()) {
        yield Result.success(list.map((m) => m.toEntity()).toList());
      }
    } on SqliteException catch (e) {
      yield Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      yield const Result.failure(StorageFullFailure());
    } catch (e) {
      yield Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCategory(
    String id, {
    required String fallbackCategoryId,
  }) async {
    if (id == 'system_uncategorized_id') {
      return Result.failure(
        CategoryValidationFailure.cannotModifySystemCategory(),
      );
    }

    try {
      final existing = await _localDataSource.getCategoryById(id);
      if (existing == null) {
        return Result.failure(CategoryNotFoundFailure(id));
      }

      await _localDataSource.deleteCategoryWithReassignment(
        id: id,
        fallbackId: fallbackCategoryId,
      );
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } on FileSystemException {
      return const Result.failure(StorageFullFailure());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}

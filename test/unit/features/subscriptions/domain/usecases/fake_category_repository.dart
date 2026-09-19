import 'dart:async';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/category_repository.dart';

/// In-memory fake implementation of [CategoryRepository] for pure domain unit testing.
class FakeCategoryRepository implements CategoryRepository {
  final Map<String, Category> categories = {};
  final StreamController<Result<List<Category>>> _streamController =
      StreamController<Result<List<Category>>>.broadcast();

  Failure? injectedFailure;

  void emitCurrent() {
    if (injectedFailure != null) {
      _streamController.add(Error(injectedFailure!));
    } else {
      _streamController.add(Success(categories.values.toList()));
    }
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    categories[category.id] = category;
    emitCurrent();
    return Success(category);
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    if (!categories.containsKey(category.id)) {
      return Error(CategoryNotFoundFailure(category.id));
    }
    categories[category.id] = category;
    emitCurrent();
    return Success(category);
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    final cat = categories[id];
    if (cat == null) {
      return Error(CategoryNotFoundFailure(id));
    }
    return Success(cat);
  }

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    if (injectedFailure != null) return Error(injectedFailure!);
    return Success(categories.values.toList());
  }

  @override
  Stream<Result<List<Category>>> watchCategories() {
    return _streamController.stream;
  }

  @override
  Future<Result<void>> deleteCategory(
    String id, {
    required String fallbackCategoryId,
  }) async {
    if (injectedFailure != null) return Error(injectedFailure!);
    if (!categories.containsKey(id)) {
      return Error(CategoryNotFoundFailure(id));
    }
    categories.remove(id);
    emitCurrent();
    return const Success(null);
  }

  void dispose() {
    _streamController.close();
  }
}

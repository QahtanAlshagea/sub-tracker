import '../daos/category_dao.dart';
import '../models/category_model.dart';

/// Contract for category persistence at the local data source level.
abstract class CategoryLocalDataSource {
  /// Inserts a new category into SQLite via DAO and returns the persisted model.
  Future<CategoryModel> createCategory(CategoryModel model);

  /// Updates an existing category row and returns the updated model.
  Future<CategoryModel> updateCategory(CategoryModel model);

  /// Retrieves a category by [id], or null if not found.
  Future<CategoryModel?> getCategoryById(String id);

  /// Retrieves all categories ordered alphabetically by name.
  Future<List<CategoryModel>> getAllCategories();

  /// Watches all categories as a reactive stream.
  Stream<List<CategoryModel>> watchCategories();

  /// Safely deletes a category by atomically reassigning linked subscriptions to [fallbackId].
  Future<void> deleteCategoryWithReassignment({
    required String id,
    required String fallbackId,
  });
}

/// Concrete implementation of [CategoryLocalDataSource] using Drift's [CategoryDao].
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final CategoryDao _categoryDao;

  const CategoryLocalDataSourceImpl(this._categoryDao);

  @override
  Future<CategoryModel> createCategory(CategoryModel model) async {
    final companion = model.toCompanion(forInsert: true);
    await _categoryDao.insertCategory(companion);
    final persisted = await _categoryDao.getCategoryById(model.id);
    return CategoryModel.fromData(persisted!);
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel model) async {
    final companion = model.toCompanion();
    await _categoryDao.updateCategory(companion);
    final updated = await _categoryDao.getCategoryById(model.id);
    return CategoryModel.fromData(updated!);
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final data = await _categoryDao.getCategoryById(id);
    if (data == null) return null;
    return CategoryModel.fromData(data);
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final list = await _categoryDao.getAllCategories();
    return list.map(CategoryModel.fromData).toList();
  }

  @override
  Stream<List<CategoryModel>> watchCategories() {
    return _categoryDao.watchAllCategories().map(
      (list) => list.map(CategoryModel.fromData).toList(),
    );
  }

  @override
  Future<void> deleteCategoryWithReassignment({
    required String id,
    required String fallbackId,
  }) {
    return _categoryDao.safeDeleteCategoryWithReassignment(
      categoryIdToDelete: id,
      fallbackCategoryId: fallbackId,
    );
  }
}

import '../../../../core/utils/result.dart';
import '../entities/category.dart';

/// Abstract repository contract for category persistence and retrieval.
/// Pure Dart interface adhering to Clean Architecture and the Dependency Inversion Principle (DIP).
abstract class CategoryRepository {
  /// Persists a new custom [Category].
  Future<Result<Category>> createCategory(Category category);

  /// Updates an existing custom [Category].
  Future<Result<Category>> updateCategory(Category category);

  /// Retrieves a single [Category] by its unique [id].
  Future<Result<Category>> getCategoryById(String id);

  /// Retrieves all available categories.
  Future<Result<List<Category>>> getAllCategories();

  /// Provides a reactive stream of all available categories.
  Stream<Result<List<Category>>> watchCategories();

  /// Safely deletes a category by reassigning any linked subscriptions to [fallbackCategoryId] (US-22, FR-12).
  Future<Result<void>> deleteCategory(
    String id, {
    required String fallbackCategoryId,
  });
}

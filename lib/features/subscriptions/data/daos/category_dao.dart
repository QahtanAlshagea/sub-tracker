import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../tables/categories_table.dart';
import '../tables/subscriptions_table.dart';

part 'category_dao.g.dart';

/// Data Access Object for category persistence operations.
///
/// Implements typed queries, reactive streams, and transactional category deletion
/// with atomic subscription reassignment according to ARCHITECTURE.md §3.3.
@DriftAccessor(tables: [Categories, Subscriptions])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// Retrieves all categories ordered by name ascending.
  Future<List<Category>> getAllCategories() {
    return (select(categories)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
        ]))
        .get();
  }

  /// Emits a stream of all categories whenever the categories table changes.
  Stream<List<Category>> watchAllCategories() {
    return (select(categories)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.name, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  /// Retrieves a specific category by its unique [id].
  Future<Category?> getCategoryById(String id) {
    return (select(
      categories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves a category matching the given normalized [name] (case-insensitive in SQLite).
  Future<Category?> getCategoryByName(String name) {
    return (select(
      categories,
    )..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  /// Inserts a new category into the database.
  Future<int> insertCategory(CategoriesCompanion companion) {
    return into(categories).insert(companion);
  }

  /// Updates an existing category's properties.
  Future<bool> updateCategory(CategoriesCompanion companion) async {
    final updated = await (update(
      categories,
    )..where((tbl) => tbl.id.equals(companion.id.value))).write(companion);
    return updated > 0;
  }

  /// Deletes a category by its [id].
  ///
  /// Throws [SqliteException] if foreign key restrictions are violated (ON DELETE RESTRICT).
  Future<int> deleteCategory(String id) {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Atomically reassigns all subscriptions linked to [categoryIdToDelete]
  /// to [fallbackCategoryId], then safely deletes [categoryIdToDelete].
  ///
  /// Enforces atomic all-or-nothing execution: if any step fails, the entire
  /// transaction rolls back, leaving no subscriptions orphaned and no categories deleted.
  Future<void> safeDeleteCategoryWithReassignment({
    required String categoryIdToDelete,
    required String fallbackCategoryId,
  }) {
    return transaction(() async {
      // 1. Reassign all subscriptions pointing to the category being deleted
      await (update(
        subscriptions,
      )..where((tbl) => tbl.categoryId.equals(categoryIdToDelete))).write(
        SubscriptionsCompanion(
          categoryId: Value(fallbackCategoryId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      // 2. Safely delete the empty category
      final rowsDeleted = await (delete(
        categories,
      )..where((tbl) => tbl.id.equals(categoryIdToDelete))).go();

      if (rowsDeleted == 0) {
        throw StateError('Category $categoryIdToDelete not found to delete.');
      }
    });
  }
}

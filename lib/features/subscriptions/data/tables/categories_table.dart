import 'package:drift/drift.dart';

/// Categories table schema.
///
/// Stores subscription categories and includes the default system category («غير مصنّف»).
/// Implements ARCHITECTURE.md §3.2.1.
@TableIndex(name: 'idx_categories_name', columns: {#name}, unique: true)
class Categories extends Table {
  /// Unique identifier (UUID v4).
  TextColumn get id => text()();

  /// Normalized category name (1 to 24 chars). Unique across all categories.
  TextColumn get name => text().withLength(min: 1, max: 24)();

  /// 32-bit ARGB color value integer (e.g. 0xFF4F46E5).
  IntColumn get colorValue => integer().named('color_value')();

  /// Optional icon code identifier.
  TextColumn get iconCode => text().named('icon_code').nullable()();

  /// Whether this is the immutable system category («غير مصنّف»).
  BoolColumn get isSystem =>
      boolean().named('is_system').withDefault(const Constant(false))();

  /// Creation timestamp in UTC.
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

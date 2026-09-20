import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/category.dart';

/// Data Model for Categories.
///
/// Handles bidirectional mapping between Drift generated database rows (`db.Category`),
/// database insert/update companions (`db.CategoriesCompanion`), pure domain entities (`Category`),
/// and JSON maps for backup serialization.
class CategoryModel {
  final String id;
  final String name;
  final int colorValue;
  final String? iconCode;
  final bool isSystem;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCode,
    this.isSystem = false,
    required this.createdAt,
  });

  /// Creates a [CategoryModel] from a pure domain [Category] entity.
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      colorValue: entity.colorValue,
      iconCode: entity.iconCode,
      isSystem: entity.isSystem,
      createdAt: entity.createdAt,
    );
  }

  /// Converts this model to a pure domain [Category] entity.
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      colorValue: colorValue,
      iconCode: iconCode,
      isSystem: isSystem,
      createdAt: createdAt,
    );
  }

  /// Creates a [CategoryModel] from a Drift generated [db.Category] row.
  factory CategoryModel.fromData(db.Category data) {
    return CategoryModel(
      id: data.id,
      name: data.name,
      colorValue: data.colorValue,
      iconCode: data.iconCode,
      isSystem: data.isSystem,
      createdAt: data.createdAt,
    );
  }

  /// Converts this model to a Drift [db.CategoriesCompanion] for insertions or updates.
  db.CategoriesCompanion toCompanion({bool forInsert = false}) {
    return db.CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      iconCode: Value(iconCode),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color_value': colorValue,
      'icon_code': iconCode,
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Deserializes from a JSON map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['color_value'] as int,
      iconCode: json['icon_code'] as String?,
      isSystem: (json['is_system'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorValue == other.colorValue &&
          iconCode == other.iconCode &&
          isSystem == other.isSystem &&
          createdAt.isAtSameMomentAs(other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      colorValue.hashCode ^
      iconCode.hashCode ^
      isSystem.hashCode ^
      createdAt.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: "$name")';
}

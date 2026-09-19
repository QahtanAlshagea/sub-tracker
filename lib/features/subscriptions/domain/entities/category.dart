import 'package:sub_tracker/core/error/failures.dart';

/// Represents a subscription category entity in the domain layer.
///
/// Categories organize subscriptions (e.g., Entertainment, Work, Utilities)
/// and include a protected system category («غير مصنّف»).
class Category {
  /// Unique identifier (UUID v4).
  final String id;

  /// Trimmed, normalized category name (1 to 24 characters).
  final String name;

  /// 32-bit ARGB color value integer (e.g. 0xFF4F46E5).
  final int colorValue;

  /// Optional icon identifier or codepoint.
  final String? iconCode;

  /// Whether this is the immutable system category («غير مصنّف») protected from deletion.
  final bool isSystem;

  /// Creation timestamp in UTC.
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCode,
    this.isSystem = false,
    required this.createdAt,
  });

  /// Factory that validates domain invariants before construction.
  factory Category.create({
    required String id,
    required String name,
    required int colorValue,
    String? iconCode,
    bool isSystem = false,
    DateTime? createdAt,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Category name cannot be empty.');
    }
    if (trimmedName.length > 24) {
      throw const ValidationFailure(
        'Category name cannot exceed 24 characters.',
      );
    }

    return Category(
      id: id,
      name: trimmedName,
      colorValue: colorValue,
      iconCode: iconCode,
      isSystem: isSystem,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  /// System default "Uncategorized" category instance.
  factory Category.systemUncategorized({
    String id = 'system_uncategorized_id',
    DateTime? createdAt,
  }) {
    return Category(
      id: id,
      name: 'غير مصنّف',
      colorValue: 0xFF9CA3AF,
      iconCode: 'folder_outline',
      isSystem: true,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconCode,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name != null ? name.trim() : this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorValue == other.colorValue &&
          iconCode == other.iconCode &&
          isSystem == other.isSystem;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      colorValue.hashCode ^
      iconCode.hashCode ^
      isSystem.hashCode;

  @override
  String toString() => 'Category(id: $id, name: "$name", isSystem: $isSystem)';
}

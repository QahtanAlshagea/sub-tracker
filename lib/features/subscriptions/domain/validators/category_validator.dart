import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../failures/subscription_failures.dart';

/// Pure domain validation rules for Categories.
/// Implements BR-05, US-21, US-22 and EC-21-1..EC-21-3.
/// Pure Dart — zero dependencies on Flutter or persistence.
class CategoryValidator {
  const CategoryValidator._();

  /// Maximum allowed characters for category name (BR-05).
  static const int maxCategoryNameLength = 24;

  /// Validates category name length and content (BR-05, EC-21-1, EC-21-2).
  static Result<String> validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Error(CategoryValidationFailure.emptyName());
    }
    if (trimmed.runes.length > maxCategoryNameLength) {
      return Error(CategoryValidationFailure.nameTooLong());
    }
    return Success(trimmed);
  }

  /// Normalizes category name for collision and uniqueness checks (BR-05).
  /// Trims spaces, collapses internal whitespace, and converts to lowercase.
  static String normalizeName(String name) {
    final trimmed = name.trim();
    final singleSpaced = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    return singleSpaced.toLowerCase();
  }

  /// Validates that a category can be safely modified or deleted (EC-21-3).
  /// System categories (like 'Uncategorized') are protected from mutation.
  static Result<void> validateModification(Category category) {
    if (category.isSystem) {
      return Error(CategoryValidationFailure.cannotModifySystemCategory());
    }
    final nameResult = validateName(category.name);
    if (nameResult.isFailure) {
      return Error(nameResult.failureOrNull!);
    }
    return const Success(null);
  }

  /// Validates an entire [Category] entity.
  static Result<void> validateCategory(Category category) {
    final nameResult = validateName(category.name);
    if (nameResult.isFailure) {
      return Error(nameResult.failureOrNull!);
    }
    return const Success(null);
  }
}

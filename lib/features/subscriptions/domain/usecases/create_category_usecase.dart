import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../failures/subscription_failures.dart';
import '../repositories/category_repository.dart';
import '../validators/category_validator.dart';

/// Use case for creating a new custom category.
/// Implements [FR-12] and [US-21].
class CreateCategoryUseCase implements UseCase<Category, Category> {
  final CategoryRepository _repository;

  const CreateCategoryUseCase(this._repository);

  @override
  Future<Result<Category>> call(Category params) async {
    // 1. Validate category invariants
    final validationResult = CategoryValidator.validateCategory(params);
    if (validationResult.isFailure) {
      return Error(validationResult.failureOrNull!);
    }

    // 2. Query existing categories to check for duplicate names (normalized)
    final existingResult = await _repository.getAllCategories();
    if (existingResult.isSuccess) {
      final existingCategories = existingResult.dataOrNull ?? [];
      final normalizedCandidate = CategoryValidator.normalizeName(params.name);

      for (final existing in existingCategories) {
        if (CategoryValidator.normalizeName(existing.name) ==
            normalizedCandidate) {
          return const Error(
            CategoryValidationFailure(
              CategoryValidationReason.emptyName,
              'A category with the same name already exists.',
            ),
          );
        }
      }
    }

    // 3. Delegate to repository
    return _repository.createCategory(params);
  }
}

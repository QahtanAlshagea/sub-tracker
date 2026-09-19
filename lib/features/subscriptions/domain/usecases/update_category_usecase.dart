import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../failures/subscription_failures.dart';
import '../repositories/category_repository.dart';
import '../validators/category_validator.dart';

/// Use case for updating a custom category.
/// Implements [FR-12], [US-21], and prevents modifying system categories [EC-21-3].
class UpdateCategoryUseCase implements UseCase<Category, Category> {
  final CategoryRepository _repository;

  const UpdateCategoryUseCase(this._repository);

  @override
  Future<Result<Category>> call(Category params) async {
    // 1. Check system protection on input
    final modResult = CategoryValidator.validateModification(params);
    if (modResult.isFailure) {
      return Error(modResult.failureOrNull!);
    }

    // 2. Validate category invariants
    final validationResult = CategoryValidator.validateCategory(params);
    if (validationResult.isFailure) {
      return Error(validationResult.failureOrNull!);
    }

    // 3. Verify category exists in repository
    final existingResult = await _repository.getCategoryById(params.id);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    final existing = existingResult.dataOrNull!;
    // 4. Ensure existing category in database is not a system category
    if (existing.isSystem) {
      return Error(CategoryValidationFailure.cannotModifySystemCategory());
    }

    // 5. Delegate update to repository
    return _repository.updateCategory(params);
  }
}

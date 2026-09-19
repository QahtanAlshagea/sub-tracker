import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../failures/subscription_failures.dart';
import '../repositories/category_repository.dart';

/// Parameters for safely deleting a category.
class DeleteCategoryParams {
  final String categoryId;
  final String fallbackCategoryId;

  const DeleteCategoryParams({
    required this.categoryId,
    required this.fallbackCategoryId,
  });
}

/// Use case for deleting a custom category and reassigning its subscriptions.
/// Implements [FR-12], [US-22], and system category protection [EC-21-3, EC-22-1..3].
class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final CategoryRepository _repository;

  const DeleteCategoryUseCase(this._repository);

  @override
  Future<Result<void>> call(DeleteCategoryParams params) async {
    // 1. Target category and fallback category cannot be the same
    if (params.categoryId == params.fallbackCategoryId) {
      return const Error(
        CategoryValidationFailure(
          CategoryValidationReason.emptyName,
          'Fallback category cannot be the same as the category being deleted.',
        ),
      );
    }

    // 2. Verify target category exists and is not a system category
    final targetResult = await _repository.getCategoryById(params.categoryId);
    if (targetResult.isFailure) {
      return Error(targetResult.failureOrNull!);
    }

    final target = targetResult.dataOrNull!;
    if (target.isSystem) {
      return Error(CategoryValidationFailure.cannotModifySystemCategory());
    }

    // 3. Verify fallback category exists
    final fallbackResult = await _repository.getCategoryById(
      params.fallbackCategoryId,
    );
    if (fallbackResult.isFailure) {
      return Error(fallbackResult.failureOrNull!);
    }

    // 4. Delegate safe deletion and reassignment to repository
    return _repository.deleteCategory(
      params.categoryId,
      fallbackCategoryId: params.fallbackCategoryId,
    );
  }
}

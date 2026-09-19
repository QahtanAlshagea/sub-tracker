import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case for retrieving all categories.
/// Implements [FR-12].
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository _repository;

  const GetCategoriesUseCase(this._repository);

  @override
  Future<Result<List<Category>>> call(NoParams params) {
    return _repository.getAllCategories();
  }
}

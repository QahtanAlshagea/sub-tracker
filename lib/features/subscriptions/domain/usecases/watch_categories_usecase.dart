import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Reactive stream use case for watching categories continuously.
class WatchCategoriesUseCase
    implements StreamUseCase<List<Category>, NoParams> {
  final CategoryRepository _repository;

  const WatchCategoriesUseCase(this._repository);

  @override
  Stream<Result<List<Category>>> call(NoParams params) {
    return _repository.watchCategories();
  }
}

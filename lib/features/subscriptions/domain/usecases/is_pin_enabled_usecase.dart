import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/security_repository.dart';

/// Use case to check if PIN protection is active.
class IsPinEnabledUseCase implements UseCase<bool, NoParams> {
  final SecurityRepository _repository;

  const IsPinEnabledUseCase(this._repository);

  @override
  Future<Result<bool>> call(NoParams params) {
    return _repository.isPinEnabled();
  }
}

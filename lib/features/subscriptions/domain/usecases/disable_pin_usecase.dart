import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/security_repository.dart';

/// Use case to disable PIN locking on the application.
class DisablePinUseCase implements UseCase<void, NoParams> {
  final SecurityRepository _repository;

  const DisablePinUseCase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.disablePin();
  }
}

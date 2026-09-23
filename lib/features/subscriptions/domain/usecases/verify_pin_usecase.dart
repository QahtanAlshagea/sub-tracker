import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/security_repository.dart';

/// Use case to verify whether an entered PIN matches the stored PIN hash.
class VerifyPinUseCase implements UseCase<bool, String> {
  final SecurityRepository _repository;

  const VerifyPinUseCase(this._repository);

  @override
  Future<Result<bool>> call(String params) {
    return _repository.verifyPin(params);
  }
}

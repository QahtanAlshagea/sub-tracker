import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/security_repository.dart';
import '../value_objects/pin_code.dart';

/// Use case to configure or update the application security PIN.
class SetPinUseCase implements UseCase<void, String> {
  final SecurityRepository _repository;

  const SetPinUseCase(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    try {
      // Validate PIN format before persisting
      PinCode(params);
      return await _repository.setPin(params);
    } on Failure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(ValidationFailure(e.toString()));
    }
  }
}

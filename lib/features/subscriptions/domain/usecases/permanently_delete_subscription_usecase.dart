import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/subscription_repository.dart';

/// Use case for permanently deleting a subscription from storage.
/// Implements [FR-09] and [US-13].
class PermanentlyDeleteSubscriptionUseCase implements UseCase<void, String> {
  final SubscriptionRepository _repository;

  const PermanentlyDeleteSubscriptionUseCase(this._repository);

  @override
  Future<Result<void>> call(String params) {
    return _repository.permanentlyDeleteSubscription(params);
  }
}

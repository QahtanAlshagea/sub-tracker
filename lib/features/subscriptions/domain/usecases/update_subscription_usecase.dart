import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';
import '../validators/duplicate_detector.dart';
import '../validators/subscription_validator.dart';
import '../value_objects/subscription_status.dart';

/// Use case for updating an existing subscription.
/// Implements [FR-04] and validates domain invariants.
class UpdateSubscriptionUseCase implements UseCase<Subscription, Subscription> {
  final SubscriptionRepository _repository;

  const UpdateSubscriptionUseCase(this._repository);

  @override
  Future<Result<Subscription>> call(Subscription params) async {
    // 1. Defensively validate domain invariants
    final validationResult = SubscriptionValidator.validateSubscription(params);
    if (validationResult.isFailure) {
      return Error(validationResult.failureOrNull!);
    }

    // 2. Ensure target subscription exists
    final existingResult = await _repository.getSubscriptionById(params.id);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    // 3. Query active subscriptions to avoid collisions on update (DuplicateDetector ignores self by id)
    final activeResult = await _repository.getAllSubscriptions(
      status: SubscriptionStatus.active,
    );

    if (activeResult.isSuccess) {
      final activeList = activeResult.dataOrNull ?? [];
      final dupResult = DuplicateDetector.checkDuplicate(
        candidate: params,
        existingSubscriptions: activeList,
      );
      if (dupResult.isFailure) {
        return Error(dupResult.failureOrNull!);
      }
    }

    // 4. Delegate to repository
    return _repository.updateSubscription(params);
  }
}

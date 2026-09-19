import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';
import '../validators/duplicate_detector.dart';
import '../validators/subscription_validator.dart';
import '../value_objects/subscription_status.dart';

/// Use case for creating and persisting a new subscription.
/// Implements [FR-01] and [FR-19] (duplicate prevention).
class CreateSubscriptionUseCase implements UseCase<Subscription, Subscription> {
  final SubscriptionRepository _repository;

  const CreateSubscriptionUseCase(this._repository);

  @override
  Future<Result<Subscription>> call(Subscription params) async {
    // 1. Defensively validate domain invariants
    final validationResult = SubscriptionValidator.validateSubscription(params);
    if (validationResult.isFailure) {
      return Error(validationResult.failureOrNull!);
    }

    // 2. Query active subscriptions to verify against duplicates (FR-19)
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
    } else {
      return Error(activeResult.failureOrNull!);
    }

    // 3. Delegate to repository for atomic persistence
    return _repository.createSubscription(params);
  }
}

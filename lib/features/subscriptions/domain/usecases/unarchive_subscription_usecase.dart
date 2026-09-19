import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../failures/subscription_failures.dart';
import '../repositories/subscription_repository.dart';
import '../value_objects/subscription_status.dart';

/// Use case for restoring an archived subscription back to active.
/// Implements [FR-08] and [US-11].
class UnarchiveSubscriptionUseCase implements UseCase<void, String> {
  final SubscriptionRepository _repository;

  const UnarchiveSubscriptionUseCase(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    final subResult = await _repository.getSubscriptionById(params);
    if (subResult.isFailure) {
      return Error(subResult.failureOrNull!);
    }

    final sub = subResult.dataOrNull!;
    if (sub.status != SubscriptionStatus.archived) {
      return const Error(
        SubscriptionStateTransitionFailure(
          StateTransitionReason.alreadyArchived,
          'Subscription is not in archived status.',
        ),
      );
    }

    return _repository.unarchiveSubscription(params);
  }
}

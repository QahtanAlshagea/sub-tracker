import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../failures/subscription_failures.dart';
import '../repositories/subscription_repository.dart';
import '../value_objects/subscription_status.dart';

/// Use case for archiving an active subscription.
/// Implements [FR-08] and [US-10].
class ArchiveSubscriptionUseCase implements UseCase<void, String> {
  final SubscriptionRepository _repository;

  const ArchiveSubscriptionUseCase(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    final subResult = await _repository.getSubscriptionById(params);
    if (subResult.isFailure) {
      return Error(subResult.failureOrNull!);
    }

    final sub = subResult.dataOrNull!;
    if (sub.status == SubscriptionStatus.archived) {
      return Error(SubscriptionStateTransitionFailure.alreadyArchived());
    }

    if (sub.status == SubscriptionStatus.inTrash) {
      return Error(SubscriptionStateTransitionFailure.alreadyInTrash());
    }

    return _repository.archiveSubscription(params);
  }
}

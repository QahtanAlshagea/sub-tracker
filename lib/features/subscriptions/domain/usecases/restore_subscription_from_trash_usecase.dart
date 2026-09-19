import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../failures/subscription_failures.dart';
import '../repositories/subscription_repository.dart';
import '../value_objects/subscription_status.dart';

/// Use case for restoring a subscription from the trash back to active.
/// Implements [FR-09] and [US-14].
class RestoreSubscriptionFromTrashUseCase implements UseCase<void, String> {
  final SubscriptionRepository _repository;

  const RestoreSubscriptionFromTrashUseCase(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    final subResult = await _repository.getSubscriptionById(params);
    if (subResult.isFailure) {
      return Error(subResult.failureOrNull!);
    }

    final sub = subResult.dataOrNull!;
    if (sub.status != SubscriptionStatus.inTrash) {
      return const Error(
        SubscriptionStateTransitionFailure(
          StateTransitionReason.alreadyInTrash,
          'Subscription is not in trash.',
        ),
      );
    }

    return _repository.restoreFromTrash(params);
  }
}

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../failures/subscription_failures.dart';
import '../repositories/subscription_repository.dart';
import '../value_objects/subscription_status.dart';

/// Use case for soft-deleting a subscription by moving it into the trash.
/// Implements [FR-09] and [US-12].
class MoveSubscriptionToTrashUseCase implements UseCase<void, String> {
  final SubscriptionRepository _repository;

  const MoveSubscriptionToTrashUseCase(this._repository);

  @override
  Future<Result<void>> call(String params) async {
    final subResult = await _repository.getSubscriptionById(params);
    if (subResult.isFailure) {
      return Error(subResult.failureOrNull!);
    }

    final sub = subResult.dataOrNull!;
    if (sub.status == SubscriptionStatus.inTrash) {
      return Error(SubscriptionStateTransitionFailure.alreadyInTrash());
    }

    return _repository.moveToTrash(params);
  }
}

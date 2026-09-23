import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../failures/subscription_failures.dart';
import '../repositories/subscription_repository.dart';
import '../value_objects/due_date.dart';

/// Parameters for renewing a subscription.
class RenewSubscriptionParams {
  final String subscriptionId;
  final DateTime? at;
  final DueDate? nextDueDate;

  const RenewSubscriptionParams({
    required this.subscriptionId,
    this.at,
    this.nextDueDate,
  });
}

/// Use case for marking a subscription as paid/renewed and advancing its due date.
/// Implements [FR-11], [US-02], and [US-28].
class RenewSubscriptionUseCase
    implements UseCase<Subscription, RenewSubscriptionParams> {
  final SubscriptionRepository _repository;

  const RenewSubscriptionUseCase(this._repository);

  @override
  Future<Result<Subscription>> call(RenewSubscriptionParams params) async {
    final subResult = await _repository.getSubscriptionById(
      params.subscriptionId,
    );
    if (subResult.isFailure) {
      return Error(subResult.failureOrNull!);
    }

    final subscription = subResult.dataOrNull!;
    if (subscription.isArchived || subscription.isInTrash) {
      return Error(SubscriptionStateTransitionFailure.cannotRenewInactive());
    }

    final renewed = params.nextDueDate != null
        ? subscription.copyWith(
            dueDate: params.nextDueDate,
            updatedAt: (params.at ?? DateTime.now()).toUtc(),
          )
        : subscription.markAsRenewed(at: params.at);
    return _repository.updateSubscription(renewed);
  }
}

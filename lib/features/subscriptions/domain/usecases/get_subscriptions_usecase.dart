import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';
import '../value_objects/subscription_status.dart';

/// Parameters for filtering subscription list queries.
class GetSubscriptionsParams {
  final SubscriptionStatus? status;
  final String? categoryId;

  const GetSubscriptionsParams({this.status, this.categoryId});

  static const all = GetSubscriptionsParams();
  static const active = GetSubscriptionsParams(
    status: SubscriptionStatus.active,
  );
  static const archived = GetSubscriptionsParams(
    status: SubscriptionStatus.archived,
  );
  static const inTrash = GetSubscriptionsParams(
    status: SubscriptionStatus.inTrash,
  );
}

/// Use case for retrieving subscriptions filtered by status and/or category.
/// Implements [FR-02], [FR-15], [US-05], and [US-25].
class GetSubscriptionsUseCase
    implements UseCase<List<Subscription>, GetSubscriptionsParams> {
  final SubscriptionRepository _repository;

  const GetSubscriptionsUseCase(this._repository);

  @override
  Future<Result<List<Subscription>>> call(GetSubscriptionsParams params) {
    return _repository.getAllSubscriptions(
      status: params.status,
      categoryId: params.categoryId,
    );
  }
}

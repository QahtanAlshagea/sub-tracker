import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';
import 'get_subscriptions_usecase.dart';

/// Reactive stream use case for watching subscriptions continuously.
/// Implements reactive UI updates across the application lifecycle.
class WatchSubscriptionsUseCase
    implements StreamUseCase<List<Subscription>, GetSubscriptionsParams> {
  final SubscriptionRepository _repository;

  const WatchSubscriptionsUseCase(this._repository);

  @override
  Stream<Result<List<Subscription>>> call(GetSubscriptionsParams params) {
    return _repository.watchSubscriptions(
      status: params.status,
      categoryId: params.categoryId,
    );
  }
}

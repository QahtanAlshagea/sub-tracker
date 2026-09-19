import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/subscription.dart';
import '../failures/subscription_failures.dart';
import '../repositories/subscription_repository.dart';

/// Use case for retrieving a single subscription by its unique identifier.
/// Implements [FR-03] and [US-06].
class GetSubscriptionByIdUseCase implements UseCase<Subscription, String> {
  final SubscriptionRepository _repository;

  const GetSubscriptionByIdUseCase(this._repository);

  @override
  Future<Result<Subscription>> call(String params) async {
    final trimmedId = params.trim();
    if (trimmedId.isEmpty) {
      return const Error(SubscriptionNotFoundFailure(''));
    }
    return _repository.getSubscriptionById(trimmedId);
  }
}

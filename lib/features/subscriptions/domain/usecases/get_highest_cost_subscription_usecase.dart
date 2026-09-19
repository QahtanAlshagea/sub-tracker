import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/highest_cost_subscription_result.dart';
import '../repositories/subscription_repository.dart';
import '../services/financial_calculator.dart';
import '../value_objects/subscription_status.dart';

/// Parameters for finding the highest cost subscription.
class GetHighestCostSubscriptionParams {
  /// The ISO 4217 currency code.
  final String currencyCode;

  const GetHighestCostSubscriptionParams({required this.currencyCode});
}

/// Identifies the subscription with highest monthly equivalent in a currency.
///
/// Implements FR-06, US-18, EC-18-1..3.
class GetHighestCostSubscriptionUseCase
    implements
        UseCase<
          HighestCostSubscriptionResult?,
          GetHighestCostSubscriptionParams
        > {
  final SubscriptionRepository _repository;

  const GetHighestCostSubscriptionUseCase(this._repository);

  @override
  Future<Result<HighestCostSubscriptionResult?>> call(
    GetHighestCostSubscriptionParams params,
  ) async {
    final result = await _repository.getAllSubscriptions(
      status: SubscriptionStatus.active,
    );

    return result.fold(
      onSuccess: (subscriptions) {
        final currency = params.currencyCode.trim().toUpperCase();
        final highest = FinancialCalculator.findHighestCostSubscription(
          subscriptions,
          currencyCode: currency,
        );
        return Success(highest);
      },
      onFailure: (failure) => Error(failure),
    );
  }
}

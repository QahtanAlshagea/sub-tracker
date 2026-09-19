import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/monthly_summary.dart';
import '../repositories/subscription_repository.dart';
import '../services/financial_calculator.dart';
import '../value_objects/subscription_status.dart';

/// Parameters for retrieving monthly financial summaries.
class GetMonthlySummaryParams {
  /// Optional currency filter. If provided, the summary will include this currency
  /// (with empty values if no subscriptions exist).
  final String? currencyCode;

  const GetMonthlySummaryParams({this.currencyCode});

  static const all = GetMonthlySummaryParams();
}

/// Retrieves aggregated monthly and annual summaries grouped strictly by currency.
///
/// Implements FR-06, BR-07, BR-08, BR-10, US-15, EC-15-1..4.
class GetMonthlySummaryUseCase
    implements UseCase<Map<String, MonthlySummary>, GetMonthlySummaryParams> {
  final SubscriptionRepository _repository;

  const GetMonthlySummaryUseCase(this._repository);

  @override
  Future<Result<Map<String, MonthlySummary>>> call(
    GetMonthlySummaryParams params,
  ) async {
    final result = await _repository.getAllSubscriptions(
      status: SubscriptionStatus.active,
    );

    return result.fold(
      onSuccess: (subscriptions) {
        final summaries = FinancialCalculator.calculateMonthlySummaries(
          subscriptions,
        );

        if (params.currencyCode != null) {
          final currency = params.currencyCode!.trim().toUpperCase();
          final filtered = <String, MonthlySummary>{};
          filtered[currency] =
              summaries[currency] ?? MonthlySummary.empty(currency);
          return Success(filtered);
        }

        return Success(summaries);
      },
      onFailure: (failure) => Error(failure),
    );
  }
}

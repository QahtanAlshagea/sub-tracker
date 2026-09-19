import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/month_comparison_result.dart';
import '../repositories/subscription_repository.dart';
import '../services/financial_calculator.dart';
import '../value_objects/subscription_status.dart';

/// Parameters for comparing current month spending against previous month.
class GetMonthComparisonParams {
  /// The ISO 4217 currency code.
  final String currencyCode;

  /// Anchor reference date (defaults to UTC today).
  final DateTime? referenceDate;

  const GetMonthComparisonParams({
    required this.currencyCode,
    this.referenceDate,
  });
}

/// Compares current month spending commitments against the previous calendar month.
///
/// Implements FR-07, US-20, EC-20-1..3.
class GetMonthComparisonUseCase
    implements UseCase<MonthComparisonResult, GetMonthComparisonParams> {
  final SubscriptionRepository _repository;

  const GetMonthComparisonUseCase(this._repository);

  @override
  Future<Result<MonthComparisonResult>> call(
    GetMonthComparisonParams params,
  ) async {
    final result = await _repository.getAllSubscriptions(
      status: SubscriptionStatus.active,
    );

    return result.fold(
      onSuccess: (subscriptions) {
        final currency = params.currencyCode.trim().toUpperCase();
        final refDate = params.referenceDate ?? DateTime.now().toUtc();

        final comparison = FinancialCalculator.compareMonthOverMonth(
          subscriptions,
          currencyCode: currency,
          referenceDate: refDate,
        );

        return Success(comparison);
      },
      onFailure: (failure) => Error(failure),
    );
  }
}

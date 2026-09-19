import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/upcoming_projection.dart';
import '../repositories/subscription_repository.dart';
import '../services/financial_calculator.dart';
import '../value_objects/subscription_status.dart';

/// Parameters for querying upcoming subscription commitments.
class GetUpcomingProjectionsParams {
  /// The ISO 4217 currency code.
  final String currencyCode;

  /// Anchor reference date (defaults to UTC today).
  final DateTime? referenceDate;

  /// If true, projects the current calendar month (US-16).
  /// If false, projects a rolling 30-day window (US-17).
  final bool isCalendarMonth;

  const GetUpcomingProjectionsParams({
    required this.currencyCode,
    this.referenceDate,
    this.isCalendarMonth = true,
  });

  /// Factory for calendar month query (US-16).
  factory GetUpcomingProjectionsParams.calendarMonth({
    required String currencyCode,
    DateTime? referenceDate,
  }) {
    return GetUpcomingProjectionsParams(
      currencyCode: currencyCode,
      referenceDate: referenceDate,
      isCalendarMonth: true,
    );
  }

  /// Factory for rolling 30-day window query (US-17).
  factory GetUpcomingProjectionsParams.rolling30Days({
    required String currencyCode,
    DateTime? referenceDate,
  }) {
    return GetUpcomingProjectionsParams(
      currencyCode: currencyCode,
      referenceDate: referenceDate,
      isCalendarMonth: false,
    );
  }
}

/// Retrieves upcoming payment projections over a calendar month or rolling 30-day window.
///
/// Implements FR-06, US-16, US-17, EC-16-1..4, EC-17-1..3.
class GetUpcomingProjectionsUseCase
    implements UseCase<UpcomingProjection, GetUpcomingProjectionsParams> {
  final SubscriptionRepository _repository;

  const GetUpcomingProjectionsUseCase(this._repository);

  @override
  Future<Result<UpcomingProjection>> call(
    GetUpcomingProjectionsParams params,
  ) async {
    final result = await _repository.getAllSubscriptions(
      status: SubscriptionStatus.active,
    );

    return result.fold(
      onSuccess: (subscriptions) {
        final refDate = params.referenceDate ?? DateTime.now().toUtc();
        final currency = params.currencyCode.trim().toUpperCase();

        final projection = params.isCalendarMonth
            ? FinancialCalculator.calculateCalendarMonthProjection(
                subscriptions,
                currencyCode: currency,
                referenceDate: refDate,
              )
            : FinancialCalculator.calculateRolling30DaysProjection(
                subscriptions,
                currencyCode: currency,
                referenceDate: refDate,
              );

        return Success(projection);
      },
      onFailure: (failure) => Error(failure),
    );
  }
}

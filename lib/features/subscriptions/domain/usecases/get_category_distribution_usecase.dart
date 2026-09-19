import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/category_distribution_item.dart';
import '../repositories/category_repository.dart';
import '../repositories/subscription_repository.dart';
import '../services/financial_calculator.dart';
import '../value_objects/subscription_status.dart';

/// Parameters for retrieving category spending distribution.
class GetCategoryDistributionParams {
  /// The ISO 4217 currency code.
  final String currencyCode;

  const GetCategoryDistributionParams({required this.currencyCode});
}

/// Generates a category spending distribution report with percentage shares.
///
/// Implements FR-07, US-19, EC-19-1..3.
class GetCategoryDistributionUseCase
    implements
        UseCase<CategoryDistributionResult, GetCategoryDistributionParams> {
  final SubscriptionRepository _subscriptionRepository;
  final CategoryRepository _categoryRepository;

  const GetCategoryDistributionUseCase({
    required SubscriptionRepository subscriptionRepository,
    required CategoryRepository categoryRepository,
  }) : _subscriptionRepository = subscriptionRepository,
       _categoryRepository = categoryRepository;

  @override
  Future<Result<CategoryDistributionResult>> call(
    GetCategoryDistributionParams params,
  ) async {
    final subsResult = await _subscriptionRepository.getAllSubscriptions(
      status: SubscriptionStatus.active,
    );

    if (subsResult.isFailure) {
      return Error(subsResult.failureOrNull!);
    }

    final categoriesResult = await _categoryRepository.getAllCategories();
    if (categoriesResult.isFailure) {
      return Error(categoriesResult.failureOrNull!);
    }

    final currency = params.currencyCode.trim().toUpperCase();
    final distribution = FinancialCalculator.calculateCategoryDistribution(
      subsResult.dataOrNull!,
      currencyCode: currency,
      categories: categoriesResult.dataOrNull!,
    );

    return Success(distribution);
  }
}

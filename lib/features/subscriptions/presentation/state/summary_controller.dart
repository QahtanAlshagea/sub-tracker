import 'package:flutter/foundation.dart';
import '../../domain/entities/category_distribution_item.dart';
import '../../domain/entities/highest_cost_subscription_result.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/upcoming_projection.dart';
import '../../domain/usecases/get_category_distribution_usecase.dart';
import '../../domain/usecases/get_highest_cost_subscription_usecase.dart';
import '../../domain/usecases/get_monthly_summary_usecase.dart';
import '../../domain/usecases/get_upcoming_projections_usecase.dart';
import 'view_state.dart';

/// Data payload encapsulated by [SummaryController].
class SummaryDashboardData {
  final Map<String, MonthlySummary> summaries;
  final String selectedCurrency;
  final MonthlySummary? currentMonthlySummary;
  final UpcomingProjection? upcomingProjection;
  final CategoryDistributionResult? categoryDistribution;
  final HighestCostSubscriptionResult? highestCost;

  const SummaryDashboardData({
    required this.summaries,
    required this.selectedCurrency,
    this.currentMonthlySummary,
    this.upcomingProjection,
    this.categoryDistribution,
    this.highestCost,
  });

  bool get isEmpty =>
      summaries.isEmpty ||
      summaries.values.every((s) => s.activeSubscriptionsCount == 0);
}

/// MVVM state controller for calculating and managing financial analytics dashboard.
///
/// Implements [FR-06], [FR-07], [US-15]..[US-20], [EC-15-1]..[EC-15-4].
class SummaryController extends ChangeNotifier {
  final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;
  final GetUpcomingProjectionsUseCase _getUpcomingProjectionsUseCase;
  final GetCategoryDistributionUseCase _getCategoryDistributionUseCase;
  final GetHighestCostSubscriptionUseCase _getHighestCostSubscriptionUseCase;

  SummaryController({
    required GetMonthlySummaryUseCase getMonthlySummaryUseCase,
    required GetUpcomingProjectionsUseCase getUpcomingProjectionsUseCase,
    required GetCategoryDistributionUseCase getCategoryDistributionUseCase,
    required GetHighestCostSubscriptionUseCase
    getHighestCostSubscriptionUseCase,
  }) : _getMonthlySummaryUseCase = getMonthlySummaryUseCase,
       _getUpcomingProjectionsUseCase = getUpcomingProjectionsUseCase,
       _getCategoryDistributionUseCase = getCategoryDistributionUseCase,
       _getHighestCostSubscriptionUseCase = getHighestCostSubscriptionUseCase;

  ViewState<SummaryDashboardData> _state = const ViewStateLoading();
  ViewState<SummaryDashboardData> get state => _state;

  String _selectedCurrency = 'USD';
  String get selectedCurrency => _selectedCurrency;

  /// Fetches financial analytics across all currencies and sets [ViewState].
  Future<void> loadSummary({String? preferredCurrency}) async {
    _state = const ViewStateLoading();
    notifyListeners();

    final summariesResult = await _getMonthlySummaryUseCase(
      GetMonthlySummaryParams.all,
    );

    if (summariesResult.isFailure) {
      _state = ViewStateError(
        message:
            summariesResult.failureOrNull?.message ??
            'تعذر تحميل ملخص التحليلات المالية',
        onRetry: () => loadSummary(preferredCurrency: preferredCurrency),
      );
      notifyListeners();
      return;
    }

    final summaries = summariesResult.dataOrNull ?? {};

    // Check if empty
    if (summaries.isEmpty ||
        summaries.values.every((s) => s.activeSubscriptionsCount == 0)) {
      _state = const ViewStateEmpty(
        title: 'لا توجد بيانات كافية للتحليل',
        subtitle:
            'أضف اشتراكاتك لعرض التحليلات والمكافئ الشهري والسنوي وتوزيع الفئات.',
      );
      notifyListeners();
      return;
    }

    // Determine selected currency
    if (preferredCurrency != null && summaries.containsKey(preferredCurrency)) {
      _selectedCurrency = preferredCurrency;
    } else if (!summaries.containsKey(_selectedCurrency)) {
      _selectedCurrency = summaries.keys.first;
    }

    await _loadDetailsForCurrency(summaries, _selectedCurrency);
  }

  /// Changes the actively analyzed currency.
  Future<void> selectCurrency(String currencyCode) async {
    final current = _state.dataOrNull;
    if (current == null) return;
    _selectedCurrency = currencyCode;
    await _loadDetailsForCurrency(current.summaries, currencyCode);
  }

  Future<void> _loadDetailsForCurrency(
    Map<String, MonthlySummary> summaries,
    String currency,
  ) async {
    final monthlySummary = summaries[currency];

    // 1. Upcoming projection
    final upcomingResult = await _getUpcomingProjectionsUseCase(
      GetUpcomingProjectionsParams.calendarMonth(currencyCode: currency),
    );
    final upcoming = upcomingResult.dataOrNull;

    // 2. Category distribution
    final catDistResult = await _getCategoryDistributionUseCase(
      GetCategoryDistributionParams(currencyCode: currency),
    );
    final catDist = catDistResult.dataOrNull;

    // 3. Highest cost subscription
    final highestResult = await _getHighestCostSubscriptionUseCase(
      GetHighestCostSubscriptionParams(currencyCode: currency),
    );
    final highest = highestResult.dataOrNull;

    _state = ViewStateData(
      SummaryDashboardData(
        summaries: summaries,
        selectedCurrency: currency,
        currentMonthlySummary: monthlySummary,
        upcomingProjection: upcoming,
        categoryDistribution: catDist,
        highestCost: highest,
      ),
    );
    notifyListeners();
  }
}

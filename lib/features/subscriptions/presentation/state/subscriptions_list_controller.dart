import 'package:flutter/foundation.dart' hide Category;
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_subscriptions_usecase.dart';
import '../../domain/usecases/renew_subscription_usecase.dart';
import '../../domain/value_objects/subscription_status.dart';
import 'view_state.dart';

/// MVVM state controller for managing active subscriptions list.
///
/// Encapsulates state transformations, loading, empty, and error view states.
/// Complies with [FR-02], [US-05], and [codeguaid.md].
class SubscriptionsListController extends ChangeNotifier {
  final GetSubscriptionsUseCase _getSubscriptionsUseCase;
  final RenewSubscriptionUseCase _renewSubscriptionUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  SubscriptionsListController({
    required GetSubscriptionsUseCase getSubscriptionsUseCase,
    required RenewSubscriptionUseCase renewSubscriptionUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  }) : _getSubscriptionsUseCase = getSubscriptionsUseCase,
       _renewSubscriptionUseCase = renewSubscriptionUseCase,
       _getCategoriesUseCase = getCategoriesUseCase;

  ViewState<List<Subscription>> _state = const ViewStateLoading();
  ViewState<List<Subscription>> get state => _state;

  final Map<String, Category> _categoriesById = {};
  Map<String, Category> get categoriesById => _categoriesById;

  bool _isProcessingAction = false;
  bool get isProcessingAction => _isProcessingAction;

  /// Loads categories and subscriptions, setting the appropriate [ViewState].
  Future<void> loadSubscriptions({
    SubscriptionStatus? status = SubscriptionStatus.active,
    String? categoryId,
  }) async {
    _state = const ViewStateLoading();
    notifyListeners();

    // 1. Fetch categories for fast lookup
    final catResult = await _getCategoriesUseCase(const NoParams());
    if (catResult.isSuccess) {
      _categoriesById.clear();
      for (final cat in catResult.dataOrNull!) {
        _categoriesById[cat.id] = cat;
      }
    }

    // 2. Fetch subscriptions
    final params = GetSubscriptionsParams(
      status: status,
      categoryId: categoryId,
    );
    final result = await _getSubscriptionsUseCase(params);

    if (result.isFailure) {
      _state = ViewStateError(
        message: result.failureOrNull?.message ?? 'تعذر تحميل قائمة الاشتراكات',
        onRetry: () =>
            loadSubscriptions(status: status, categoryId: categoryId),
      );
    } else {
      final subscriptions = result.dataOrNull ?? [];
      if (subscriptions.isEmpty) {
        _state = const ViewStateEmpty(
          title: 'لا توجد اشتراكات مضافة بعد',
          subtitle: 'ابدأ بإضافة أول التزام دوري لتتبع نفقاتك ومواعيد تجديدك.',
          actionLabel: 'إضافة أول اشتراك',
        );
      } else {
        _state = ViewStateData(subscriptions);
      }
    }

    notifyListeners();
  }

  /// Marks a subscription as paid/renewed with double-tap protection ([US-37], [EC-37-1]).
  Future<bool> markAsPaid(String subscriptionId) async {
    if (_isProcessingAction) return false;

    _isProcessingAction = true;
    notifyListeners();

    try {
      final result = await _renewSubscriptionUseCase(
        RenewSubscriptionParams(
          subscriptionId: subscriptionId,
          at: DateTime.now().toUtc(),
        ),
      );

      if (result.isSuccess) {
        await loadSubscriptions();
        return true;
      }
      return false;
    } finally {
      _isProcessingAction = false;
      notifyListeners();
    }
  }
}

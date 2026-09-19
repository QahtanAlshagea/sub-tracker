import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import 'expense_summary.dart';
import 'subscriptions_view_state.dart';

/// Presentation state controller managing subscription view state transitions.
///
/// Implements pure, reactive state management using [ValueNotifier] to guarantee
/// deterministic testing, instant responsiveness, and zero external state package dependencies.
class SubscriptionsController extends ValueNotifier<SubscriptionsViewState> {
  final Future<List<Subscription>> Function()? fetchSubscriptions;
  final Future<Map<String, Category>> Function()? fetchCategories;

  SubscriptionsController({
    SubscriptionsViewState? initialState,
    this.fetchSubscriptions,
    this.fetchCategories,
  }) : super(initialState ?? const SubscriptionsLoading());

  /// Convenience getter for the current state.
  SubscriptionsViewState get state => value;

  /// Sets state to Loading.
  void setLoading([String? message]) {
    value = SubscriptionsLoading(message);
  }

  /// Sets state to Empty.
  void setEmpty({String? title, String? message}) {
    value = SubscriptionsEmpty(
      title: title ?? 'لا توجد التزامات دورية بعد',
      message:
          message ??
          'أضف اشتراكاتك وفواتيرك الدورية لتتبّع مواعيد استحقاقها ومصروفاتها الشهرية بدقة.',
    );
  }

  /// Sets state to Data.
  void setData({
    required List<Subscription> subscriptions,
    Map<String, Category>? categories,
    ExpenseSummary? summary,
  }) {
    final catMap = categories ?? const {};
    final calculatedSummary =
        summary ?? ExpenseSummary.fromSubscriptions(subscriptions);

    if (subscriptions.isEmpty) {
      setEmpty();
      return;
    }

    value = SubscriptionsData(
      subscriptions: subscriptions,
      categories: catMap,
      summary: calculatedSummary,
    );
  }

  /// Sets state to Error with a retry callback.
  void setError({
    String message = 'تعذّر تحميل البيانات. يرجى المحاولة مرة أخرى.',
    VoidCallback? onRetry,
  }) {
    value = SubscriptionsError(
      message: message,
      onRetry: onRetry ?? () => loadSubscriptions(),
    );
  }

  /// Asynchronously loads subscriptions and categories if fetchers are provided.
  Future<void> loadSubscriptions() async {
    setLoading();
    try {
      if (fetchSubscriptions == null) {
        // If no fetcher injected, preserve current or show empty
        return;
      }
      final subs = await fetchSubscriptions!();
      final cats = fetchCategories != null
          ? await fetchCategories!()
          : <String, Category>{};

      if (subs.isEmpty) {
        setEmpty();
      } else {
        setData(subscriptions: subs, categories: cats);
      }
    } catch (e) {
      setError(
        message: 'حدث خطأ غير متوقع أثناء تحميل البيانات: ${e.toString()}',
        onRetry: () => loadSubscriptions(),
      );
    }
  }
}

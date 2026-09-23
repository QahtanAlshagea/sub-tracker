import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_subscriptions_usecase.dart';
import '../../domain/usecases/move_subscription_to_trash_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import '../../domain/usecases/renew_subscription_usecase.dart';
import '../../domain/usecases/restore_subscription_from_trash_usecase.dart';
import '../../domain/value_objects/due_date.dart';
import '../../domain/value_objects/subscription_status.dart';
import 'view_state.dart';

/// MVVM state controller for managing active subscriptions list.
///
/// Encapsulates state transformations, loading, empty, and error view states.
/// Complies with [FR-02], [FR-09], [FR-11], [US-05], [US-12], [US-28], and [codeguaid.md].
class SubscriptionsListController extends ChangeNotifier {
  final GetSubscriptionsUseCase _getSubscriptionsUseCase;
  final RenewSubscriptionUseCase _renewSubscriptionUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final MoveSubscriptionToTrashUseCase? _moveSubscriptionToTrashUseCase;
  final RestoreSubscriptionFromTrashUseCase?
  _restoreSubscriptionFromTrashUseCase;
  final PaymentRepository? _paymentRepository;
  final RecordPaymentUseCase? _recordPaymentUseCase;
  final NotificationService? _notificationService;

  SubscriptionsListController({
    required GetSubscriptionsUseCase getSubscriptionsUseCase,
    required RenewSubscriptionUseCase renewSubscriptionUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    MoveSubscriptionToTrashUseCase? moveSubscriptionToTrashUseCase,
    RestoreSubscriptionFromTrashUseCase? restoreSubscriptionFromTrashUseCase,
    PaymentRepository? paymentRepository,
    RecordPaymentUseCase? recordPaymentUseCase,
    NotificationService? notificationService,
  }) : _getSubscriptionsUseCase = getSubscriptionsUseCase,
       _renewSubscriptionUseCase = renewSubscriptionUseCase,
       _getCategoriesUseCase = getCategoriesUseCase,
       _moveSubscriptionToTrashUseCase = moveSubscriptionToTrashUseCase,
       _restoreSubscriptionFromTrashUseCase =
           restoreSubscriptionFromTrashUseCase,
       _paymentRepository = paymentRepository,
       _recordPaymentUseCase = recordPaymentUseCase,
       _notificationService = notificationService;

  ViewState<List<Subscription>> _state = const ViewStateLoading();
  ViewState<List<Subscription>> get state => _state;

  final Map<String, Category> _categoriesById = {};
  Map<String, Category> get categoriesById => _categoriesById;

  final Map<String, int> _paymentCounts = {};
  Map<String, int> get paymentCounts => _paymentCounts;

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

    // 2. Fetch payment counts if payment repository is supplied
    if (_paymentRepository != null) {
      final countsResult = await _paymentRepository.getAllPaymentCounts();
      if (countsResult.isSuccess) {
        _paymentCounts.clear();
        _paymentCounts.addAll(countsResult.dataOrNull ?? {});
      }
    }

    // 3. Fetch subscriptions
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
  Future<bool> markAsPaid(String subscriptionId, {DueDate? nextDueDate}) async {
    if (_isProcessingAction) return false;

    _isProcessingAction = true;
    notifyListeners();

    try {
      Subscription? targetSub;
      if (_state is ViewStateData<List<Subscription>>) {
        final currentSubs = (_state as ViewStateData<List<Subscription>>).data;
        targetSub = currentSubs
            .where((s) => s.id == subscriptionId)
            .firstOrNull;
      }

      // 1. Record payment history entry if usecase is supplied
      if (_recordPaymentUseCase != null && targetSub != null) {
        await _recordPaymentUseCase(
          PaymentRecord(
            id: const Uuid().v4(),
            subscriptionId: subscriptionId,
            amount: targetSub.price,
            paidAt: DateTime.now().toUtc(),
            cycleType: targetSub.cycle.type.name,
          ),
        );
      }

      // 2. Renew subscription cycle date
      final result = await _renewSubscriptionUseCase(
        RenewSubscriptionParams(
          subscriptionId: subscriptionId,
          at: DateTime.now().toUtc(),
          nextDueDate: nextDueDate,
        ),
      );

      if (result.isSuccess) {
        await loadSubscriptions();
        if (targetSub != null &&
            _notificationService != null &&
            targetSub.reminderEnabled) {
          final computedDueDate =
              nextDueDate ??
              DueDate(targetSub.dueDate.nextOccurrence(targetSub.cycle).date);
          final renewed = targetSub.copyWith(
            dueDate: computedDueDate,
            updatedAt: DateTime.now().toUtc(),
          );
          await _notificationService.scheduleSubscriptionReminder(renewed);
        }
        return true;
      }
      return false;
    } finally {
      _isProcessingAction = false;
      notifyListeners();
    }
  }

  /// Deletes a subscription safely by moving it to the trash ([US-12], [FR-09]).
  Future<bool> deleteSubscription(String subscriptionId) async {
    if (_isProcessingAction) return false;

    _isProcessingAction = true;
    notifyListeners();

    try {
      if (_moveSubscriptionToTrashUseCase != null) {
        final result = await _moveSubscriptionToTrashUseCase(subscriptionId);
        if (result.isSuccess) {
          await _notificationService?.cancelSubscriptionReminder(
            subscriptionId,
          );
          await loadSubscriptions();
          return true;
        }
      }
      return false;
    } finally {
      _isProcessingAction = false;
      notifyListeners();
    }
  }

  /// Restores a subscription from the trash back to active ([US-12], [US-14]).
  Future<bool> restoreSubscription(String subscriptionId) async {
    if (_isProcessingAction) return false;

    _isProcessingAction = true;
    notifyListeners();

    try {
      if (_restoreSubscriptionFromTrashUseCase != null) {
        final result = await _restoreSubscriptionFromTrashUseCase(
          subscriptionId,
        );
        if (result.isSuccess) {
          await loadSubscriptions();
          return true;
        }
      }
      return false;
    } finally {
      _isProcessingAction = false;
      notifyListeners();
    }
  }
}

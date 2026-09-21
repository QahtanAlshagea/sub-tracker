import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/create_subscription_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_subscription_by_id_usecase.dart';
import '../../domain/usecases/update_subscription_usecase.dart';
import '../../domain/value_objects/billing_cycle.dart';
import '../../domain/value_objects/due_date.dart';
import '../../domain/value_objects/money.dart';
import 'view_state.dart';

/// Form state snapshot for Add / Edit subscription screen.
class AddEditFormState {
  final String? subscriptionId;
  final String name;
  final String priceText;
  final String currency;
  final BillingCycle cycle;
  final DateTime startDate;
  final DateTime nextDueDate;
  final String categoryId;
  final String notes;
  final String paymentMethodDesc;
  final List<Category> availableCategories;
  final bool isSubmitting;
  final String? nameError;
  final String? priceError;
  final String? generalError;
  final bool hasUnsavedChanges;

  const AddEditFormState({
    this.subscriptionId,
    required this.name,
    required this.priceText,
    required this.currency,
    required this.cycle,
    required this.startDate,
    required this.nextDueDate,
    required this.categoryId,
    this.notes = '',
    this.paymentMethodDesc = '',
    this.availableCategories = const [],
    this.isSubmitting = false,
    this.nameError,
    this.priceError,
    this.generalError,
    this.hasUnsavedChanges = false,
  });

  bool get isEditMode => subscriptionId != null;

  AddEditFormState copyWith({
    String? subscriptionId,
    String? name,
    String? priceText,
    String? currency,
    BillingCycle? cycle,
    DateTime? startDate,
    DateTime? nextDueDate,
    String? categoryId,
    String? notes,
    String? paymentMethodDesc,
    List<Category>? availableCategories,
    bool? isSubmitting,
    String? nameError,
    String? priceError,
    String? generalError,
    bool? hasUnsavedChanges,
    bool clearNameError = false,
    bool clearPriceError = false,
    bool clearGeneralError = false,
  }) {
    return AddEditFormState(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      name: name ?? this.name,
      priceText: priceText ?? this.priceText,
      currency: currency ?? this.currency,
      cycle: cycle ?? this.cycle,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      paymentMethodDesc: paymentMethodDesc ?? this.paymentMethodDesc,
      availableCategories: availableCategories ?? this.availableCategories,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      priceError: clearPriceError ? null : (priceError ?? this.priceError),
      generalError: clearGeneralError
          ? null
          : (generalError ?? this.generalError),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// MVVM controller for adding and editing subscriptions.
///
/// Complies with [FR-01], [FR-04], [US-01], [US-07], [EC-01-1]..[EC-01-5], [EC-07-4], [EC-37-1].
class AddEditSubscriptionController extends ChangeNotifier {
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final UpdateSubscriptionUseCase _updateSubscriptionUseCase;
  final GetSubscriptionByIdUseCase _getSubscriptionByIdUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  AddEditSubscriptionController({
    required CreateSubscriptionUseCase createSubscriptionUseCase,
    required UpdateSubscriptionUseCase updateSubscriptionUseCase,
    required GetSubscriptionByIdUseCase getSubscriptionByIdUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  }) : _createSubscriptionUseCase = createSubscriptionUseCase,
       _updateSubscriptionUseCase = updateSubscriptionUseCase,
       _getSubscriptionByIdUseCase = getSubscriptionByIdUseCase,
       _getCategoriesUseCase = getCategoriesUseCase;

  ViewState<AddEditFormState> _state = const ViewStateLoading();
  ViewState<AddEditFormState> get state => _state;

  /// Returns current [AddEditFormState] if state is [ViewStateData].
  AddEditFormState get formState => switch (_state) {
    ViewStateData(data: final d) => d,
    _ => throw StateError('FormState accessed before data loaded'),
  };

  Subscription? _originalSubscription;

  /// Initializes the form in either Add mode or Edit mode.
  Future<void> initialize({
    String? subscriptionId,
    String defaultCurrency = 'USD',
  }) async {
    _state = const ViewStateLoading();
    notifyListeners();

    // 1. Fetch categories
    final catResult = await _getCategoriesUseCase(const NoParams());
    final categories = catResult.isSuccess
        ? catResult.dataOrNull ?? []
        : <Category>[];

    final defaultCategoryId = categories.isNotEmpty
        ? categories.first.id
        : 'default-cat';

    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    if (subscriptionId == null) {
      // Add Mode
      final defaultCycle = const BillingCycle.monthly();
      final defaultDueDate = DueDate(today).nextOccurrence(defaultCycle).date;

      _state = ViewStateData(
        AddEditFormState(
          name: '',
          priceText: '',
          currency: defaultCurrency,
          cycle: defaultCycle,
          startDate: today,
          nextDueDate: defaultDueDate,
          categoryId: defaultCategoryId,
          availableCategories: categories,
        ),
      );
    } else {
      // Edit Mode
      final subResult = await _getSubscriptionByIdUseCase(subscriptionId);
      if (subResult.isFailure) {
        _state = ViewStateError(
          message: subResult.failureOrNull?.message ?? 'الاشتراك غير موجود',
          onRetry: () => initialize(
            subscriptionId: subscriptionId,
            defaultCurrency: defaultCurrency,
          ),
        );
      } else {
        final sub = subResult.dataOrNull!;
        _originalSubscription = sub;
        final decimals =
            sub.price.currencyCode == 'JPY' || sub.price.currencyCode == 'KRW'
            ? 0
            : 2;
        final priceNum = sub.price.toMajorUnits(decimalDigits: decimals);

        _state = ViewStateData(
          AddEditFormState(
            subscriptionId: sub.id,
            name: sub.name,
            priceText: decimals == 0
                ? priceNum.toInt().toString()
                : priceNum.toStringAsFixed(2),
            currency: sub.price.currencyCode,
            cycle: sub.cycle,
            startDate: sub.startDate,
            nextDueDate: sub.dueDate.date,
            categoryId: sub.categoryId,
            notes: sub.notes ?? '',
            paymentMethodDesc: sub.paymentMethodDesc ?? '',
            availableCategories: categories,
          ),
        );
      }
    }

    notifyListeners();
  }

  void updateName(String name) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(
        name: name,
        hasUnsavedChanges: true,
        clearNameError: true,
      ),
    );
    notifyListeners();
  }

  void updatePriceText(String priceText) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(
        priceText: priceText,
        hasUnsavedChanges: true,
        clearPriceError: true,
      ),
    );
    notifyListeners();
  }

  void updateCurrency(String currency) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(currency: currency, hasUnsavedChanges: true),
    );
    notifyListeners();
  }

  void updateCycle(BillingCycle cycle) {
    final current = _state.dataOrNull;
    if (current == null) return;
    final nextDue = DueDate(current.startDate).nextOccurrence(cycle).date;
    _state = ViewStateData(
      current.copyWith(
        cycle: cycle,
        nextDueDate: nextDue,
        hasUnsavedChanges: true,
      ),
    );
    notifyListeners();
  }

  void updateStartDate(DateTime startDate) {
    final current = _state.dataOrNull;
    if (current == null) return;
    final nextDue = DueDate(startDate).nextOccurrence(current.cycle).date;
    _state = ViewStateData(
      current.copyWith(
        startDate: startDate,
        nextDueDate: nextDue,
        hasUnsavedChanges: true,
      ),
    );
    notifyListeners();
  }

  void updateNextDueDate(DateTime nextDueDate) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(nextDueDate: nextDueDate, hasUnsavedChanges: true),
    );
    notifyListeners();
  }

  void updateCategory(String categoryId) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(categoryId: categoryId, hasUnsavedChanges: true),
    );
    notifyListeners();
  }

  void updateNotes(String notes) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(notes: notes, hasUnsavedChanges: true),
    );
    notifyListeners();
  }

  void updatePaymentMethod(String paymentMethod) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(
      current.copyWith(
        paymentMethodDesc: paymentMethod,
        hasUnsavedChanges: true,
      ),
    );
    notifyListeners();
  }

  /// Validates inputs and persists subscription with double-tap lock ([EC-01-5], [EC-37-1]).
  Future<bool> saveSubscription() async {
    final current = _state.dataOrNull;
    if (current == null || current.isSubmitting) return false;

    // 1. Client-side Defensive Validation
    final trimmedName = current.name.trim();
    String? nameError;
    if (trimmedName.isEmpty) {
      nameError = 'يرجى إدخال اسم الاشتراك';
    } else if (trimmedName.length > 60) {
      nameError = 'لا يمكن أن يتجاوز الاسم 60 حرفاً';
    }

    final parsedPrice = double.tryParse(current.priceText.replaceAll(',', '.'));
    String? priceError;
    if (parsedPrice == null || parsedPrice <= 0) {
      priceError = 'يجب أن يكون المبلغ أكبر من صفر';
    }

    if (nameError != null || priceError != null) {
      _state = ViewStateData(
        current.copyWith(nameError: nameError, priceError: priceError),
      );
      notifyListeners();
      return false;
    }

    // 2. Lock UI against double-tap
    _state = ViewStateData(
      current.copyWith(isSubmitting: true, clearGeneralError: true),
    );
    notifyListeners();

    try {
      final decimals = current.currency == 'JPY' || current.currency == 'KRW'
          ? 0
          : 2;
      final money = Money.fromMajorUnits(
        majorUnits: parsedPrice!,
        currencyCode: current.currency,
        decimalDigits: decimals,
      );

      final dueDate = DueDate(current.nextDueDate, current.startDate.day);

      if (!current.isEditMode) {
        // Create
        final now = DateTime.now().toUtc();
        final newSubscription = Subscription.create(
          id: const Uuid().v4(),
          name: trimmedName,
          price: money,
          cycle: current.cycle,
          dueDate: dueDate,
          startDate: current.startDate,
          categoryId: current.categoryId,
          notes: current.notes.isNotEmpty ? current.notes : null,
          paymentMethodDesc: current.paymentMethodDesc.isNotEmpty
              ? current.paymentMethodDesc
              : null,
          createdAt: now,
          updatedAt: now,
        );

        final result = await _createSubscriptionUseCase(newSubscription);
        if (result.isFailure) {
          _state = ViewStateData(
            current.copyWith(
              isSubmitting: false,
              generalError: result.failureOrNull?.message ?? 'فشل حفظ الاشتراك',
            ),
          );
          notifyListeners();
          return false;
        }
      } else {
        // Update
        final existing = _originalSubscription!;
        final updatedSubscription = existing.copyWith(
          name: trimmedName,
          price: money,
          cycle: current.cycle,
          dueDate: dueDate,
          startDate: current.startDate,
          categoryId: current.categoryId,
          notes: current.notes.isNotEmpty ? current.notes : null,
          paymentMethodDesc: current.paymentMethodDesc.isNotEmpty
              ? current.paymentMethodDesc
              : null,
          updatedAt: DateTime.now().toUtc(),
        );

        final result = await _updateSubscriptionUseCase(updatedSubscription);
        if (result.isFailure) {
          _state = ViewStateData(
            current.copyWith(
              isSubmitting: false,
              generalError:
                  result.failureOrNull?.message ?? 'فشل تعديل الاشتراك',
            ),
          );
          notifyListeners();
          return false;
        }
      }

      _state = ViewStateData(
        current.copyWith(isSubmitting: false, hasUnsavedChanges: false),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = ViewStateData(
        current.copyWith(isSubmitting: false, generalError: e.toString()),
      );
      notifyListeners();
      return false;
    }
  }
}

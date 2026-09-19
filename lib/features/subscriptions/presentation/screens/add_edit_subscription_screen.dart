import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/validators/subscription_validator.dart';
import '../../domain/value_objects/billing_cycle.dart';
import '../../domain/value_objects/due_date.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/subscription_status.dart';
import '../formatters/subscription_formatters.dart';
import '../utils/debounce_guard.dart';
import '../utils/haptic_feedback_helper.dart';

/// Form screen for adding a new subscription or editing an existing one with responsive layout.
///
/// Implements [US-01], [US-02], [US-03], [US-07], and Card C-17:
/// - [EC-01-5]: Double-tap save prevention via [DebounceGuard].
/// - [EC-01-7]: Rotation state persistence without loss of user inputs.
/// - Responsive two-column layout in landscape or wide viewports (>= 600px).
/// - Tactile haptic feedback on interactive changes.
class AddEditSubscriptionScreen extends StatefulWidget {
  final Subscription? initialSubscription;
  final List<Category>? categories;
  final void Function(Subscription subscription)? onSaved;

  const AddEditSubscriptionScreen({
    super.key,
    this.initialSubscription,
    this.categories,
    this.onSaved,
  });

  @override
  State<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _debounceGuard = DebounceGuard(
    window: const Duration(milliseconds: 500),
  );

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _customDaysController;
  late final TextEditingController _notesController;
  late final TextEditingController _paymentMethodController;

  late CycleType _selectedCycleType;
  late DateTime _startDate;
  late DateTime _dueDate;
  late String _selectedCategoryId;
  late bool _isTrial;
  late bool _reminderEnabled;
  late int _reminderLeadDays;

  bool _isSaving = false;
  bool _isDirty = false;
  String? _saveErrorMessage;

  // Inline field validation error messages (US-01 requirement)
  String? _nameError;
  String? _priceError;
  String? _customDaysError;

  // Default system category fallback
  late final List<Category> _availableCategories;

  @override
  void initState() {
    super.initState();
    final sub = widget.initialSubscription;

    _availableCategories =
        widget.categories != null && widget.categories!.isNotEmpty
        ? widget.categories!
        : [
            Category.create(
              id: 'cat-system-default',
              name: 'غير مصنّف',
              colorValue: AppColors.slate600.toARGB32(),
              isSystem: true,
            ),
          ];

    _nameController = TextEditingController(text: sub?.name ?? '');
    _priceController = TextEditingController(
      text: sub != null
          ? (sub.price.amountMinorUnits / 100.0).toStringAsFixed(2)
          : '',
    );
    _currencyController = TextEditingController(
      text: sub?.price.currencyCode ?? 'USD',
    );
    _customDaysController = TextEditingController(
      text: sub?.cycle.customDays?.toString() ?? '30',
    );
    _notesController = TextEditingController(text: sub?.notes ?? '');
    _paymentMethodController = TextEditingController(
      text: sub?.paymentMethodDesc ?? '',
    );

    _selectedCycleType = sub?.cycle.type ?? CycleType.monthly;
    _startDate = sub?.startDate ?? DateTime.now().toUtc();
    _dueDate = sub?.dueDate.date ?? _startDate.add(const Duration(days: 30));
    _selectedCategoryId = sub?.categoryId ?? _availableCategories.first.id;
    _isTrial = sub?.isTrial ?? false;
    _reminderEnabled = sub?.reminderEnabled ?? true;
    _reminderLeadDays = sub?.reminderLeadDays ?? 1;

    _nameController.addListener(_markDirty);
    _priceController.addListener(_markDirty);
    _customDaysController.addListener(_markDirty);
    _notesController.addListener(_markDirty);
    _paymentMethodController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _customDaysController.dispose();
    _notesController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty || _isSaving) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تجاهل التغييرات؟'),
        content: const Text(
          'لديك تعديلات غير محفوظة، هل تريد الخروج وتجاهلها؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('البقاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تجاهل والخروج'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    HapticFeedbackHelper.selection();
    final initial = isStartDate ? _startDate : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _isDirty = true;
        if (isStartDate) {
          _startDate = picked.toUtc();
          _dueDate = _calculateDefaultDueDate(_startDate, _selectedCycleType);
        } else {
          _dueDate = picked.toUtc();
        }
      });
    }
  }

  DateTime _calculateDefaultDueDate(DateTime start, CycleType type) {
    switch (type) {
      case CycleType.monthly:
        return DateTime.utc(start.year, start.month + 1, start.day);
      case CycleType.yearly:
        return DateTime.utc(start.year + 1, start.month, start.day);
      case CycleType.weekly:
        return start.add(const Duration(days: 7));
      case CycleType.custom:
        final days = int.tryParse(_customDaysController.text.trim()) ?? 30;
        return start.add(Duration(days: days));
    }
  }

  void _validateAndSave() {
    // Prevent double clicking via DebounceGuard (EC-01-5)
    final executed = _debounceGuard.run(() {
      if (_isSaving) return;

      setState(() {
        _nameError = null;
        _priceError = null;
        _customDaysError = null;
        _saveErrorMessage = null;
      });

      // 1. Validate Name (US-01, EC-01-1..4)
      final nameResult = SubscriptionValidator.validateName(
        _nameController.text,
      );
      if (nameResult is Error<String>) {
        HapticFeedbackHelper.medium();
        setState(() {
          _nameError = nameResult.failure.message;
        });
        return;
      }

      // 2. Validate Price (US-02, EC-02-1..6)
      final normalizedPriceStr = SubscriptionFormatters.normalizeNumerals(
        _priceController.text.trim(),
      );
      final parsedPriceDouble = double.tryParse(normalizedPriceStr);
      if (parsedPriceDouble == null) {
        HapticFeedbackHelper.medium();
        setState(() {
          _priceError = 'يرجى إدخال قيمة مالية رقمية صحيحة.';
        });
        return;
      }

      final priceMinorUnits = (parsedPriceDouble * 100).round();
      final priceResult = SubscriptionValidator.validatePrice(
        priceMinorUnits,
        isTrial: _isTrial,
      );
      if (priceResult is Error<int>) {
        HapticFeedbackHelper.medium();
        setState(() {
          _priceError = priceResult.failure.message;
        });
        return;
      }

      // 3. Validate Cycle (US-03, EC-03-1)
      BillingCycle cycle;
      if (_selectedCycleType == CycleType.custom) {
        final days = int.tryParse(
          SubscriptionFormatters.normalizeNumerals(
            _customDaysController.text.trim(),
          ),
        );
        final customDaysResult = SubscriptionValidator.validateCustomDays(days);
        if (customDaysResult is Error<int>) {
          HapticFeedbackHelper.medium();
          setState(() {
            _customDaysError = customDaysResult.failure.message;
          });
          return;
        }
        cycle = BillingCycle.custom(days!);
      } else {
        cycle = switch (_selectedCycleType) {
          CycleType.monthly => const BillingCycle.monthly(),
          CycleType.yearly => const BillingCycle.yearly(),
          CycleType.weekly => const BillingCycle.weekly(),
          CycleType.custom => const BillingCycle.monthly(),
        };
      }

      // 4. Construct Subscription
      final currency = _currencyController.text.trim().toUpperCase();
      final now = DateTime.now().toUtc();
      final id =
          widget.initialSubscription?.id ??
          'sub-${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _isSaving = true;
      });

      try {
        final subscription = Subscription.create(
          id: id,
          name: (nameResult as Success<String>).data,
          price: Money.create(
            amountMinorUnits: priceMinorUnits,
            currencyCode: currency,
          ),
          cycle: cycle,
          dueDate: DueDate.create(date: _dueDate),
          startDate: _startDate,
          categoryId: _selectedCategoryId,
          status:
              widget.initialSubscription?.status ?? SubscriptionStatus.active,
          isTrial: _isTrial,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          paymentMethodDesc: _paymentMethodController.text.trim().isNotEmpty
              ? _paymentMethodController.text.trim()
              : null,
          reminderEnabled: _reminderEnabled,
          reminderLeadDays: _reminderLeadDays,
          createdAt: widget.initialSubscription?.createdAt ?? now,
          updatedAt: now,
        );

        HapticFeedbackHelper.light();
        if (widget.onSaved != null) {
          widget.onSaved!(subscription);
        }

        Navigator.of(context).pop(subscription);
      } catch (e) {
        HapticFeedbackHelper.medium();
        setState(() {
          _isSaving = false;
          _saveErrorMessage = 'تعذّر حفظ بيانات الاشتراك: ${e.toString()}';
        });
      }
    });

    if (!executed) {
      // Throttled duplicate click ignored safely
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.initialSubscription != null;

    return PopScope(
      canPop: !_isDirty || _isSaving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isDirty && !_isSaving) {
          _onWillPop().then((shouldPop) {
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'تعديل الالتزام' : 'إضافة التزام جديد'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                child: FilledButton.icon(
                  key: const Key('subscription_save_button'),
                  onPressed: _isSaving ? null : _validateAndSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ'),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Banner if unexpected failure
                      if (_saveErrorMessage != null) ...[
                        Container(
                          padding: AppSpacing.cardPadding,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.rose700.withValues(alpha: 0.3)
                                : AppColors.rose50,
                            borderRadius: AppRadii.cardRadius,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.rose600
                                  : AppColors.rose100,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.rose600,
                              ),
                              AppSpacing.gapHorizontalM,
                              Expanded(
                                child: Text(
                                  _saveErrorMessage!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.rose100
                                        : AppColors.rose700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapVerticalM,
                      ],

                      // Responsive Form Fields (Single column for portrait, Two columns for landscape/wide)
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column 1: Core details & finance
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildNameField(),
                                  AppSpacing.gapVerticalM,
                                  _buildPriceCurrencyRow(),
                                  AppSpacing.gapVerticalM,
                                  _buildTrialSwitch(),
                                  AppSpacing.gapVerticalM,
                                  _buildCategoryDropdown(),
                                ],
                              ),
                            ),
                            AppSpacing.gapHorizontalL,

                            // Column 2: Cycle, dates & extra info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCycleSection(),
                                  AppSpacing.gapVerticalM,
                                  _buildDatesRow(),
                                  AppSpacing.gapVerticalM,
                                  _buildReminderSwitch(),
                                  AppSpacing.gapVerticalM,
                                  _buildPaymentMethodField(),
                                  AppSpacing.gapVerticalM,
                                  _buildNotesField(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        // Vertical Stack for Portrait/Mobile
                        _buildNameField(),
                        AppSpacing.gapVerticalM,
                        _buildPriceCurrencyRow(),
                        AppSpacing.gapVerticalM,
                        _buildTrialSwitch(),
                        AppSpacing.gapVerticalM,
                        _buildCycleSection(),
                        AppSpacing.gapVerticalM,
                        _buildCategoryDropdown(),
                        AppSpacing.gapVerticalM,
                        _buildDatesRow(),
                        AppSpacing.gapVerticalM,
                        _buildReminderSwitch(),
                        AppSpacing.gapVerticalM,
                        _buildPaymentMethodField(),
                        AppSpacing.gapVerticalM,
                        _buildNotesField(),
                      ],
                      AppSpacing.gapVerticalXl,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اسم الاشتراك / الالتزام *', style: AppTypography.titleSmall),
        AppSpacing.gapVerticalXs,
        TextFormField(
          key: const Key('subscription_name_field'),
          controller: _nameController,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: 'مثال: Netflix، فاتورة الكهرباء',
            counterText: '${_nameController.text.characters.length}/60',
            errorText: _nameError,
            prefixIcon: const Icon(Icons.label_outline_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPriceCurrencyRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('القيمة المالية *', style: AppTypography.titleSmall),
              AppSpacing.gapVerticalXs,
              TextFormField(
                key: const Key('subscription_price_field'),
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  errorText: _priceError,
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapHorizontalM,
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('العملة', style: AppTypography.titleSmall),
              AppSpacing.gapVerticalXs,
              TextFormField(
                key: const Key('subscription_currency_field'),
                controller: _currencyController,
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'USD',
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrialSwitch() {
    return SwitchListTile(
      key: const Key('subscription_trial_switch'),
      contentPadding: EdgeInsets.zero,
      title: const Text('فترة تجربة مجانية'),
      subtitle: const Text(
        'تتيح إدخال القيمة 0.00 مع التنبيه قبل موعد التجديد المدفوع',
      ),
      value: _isTrial,
      onChanged: (val) {
        HapticFeedbackHelper.selection();
        setState(() {
          _isDirty = true;
          _isTrial = val;
          if (val && _priceController.text.isEmpty) {
            _priceController.text = '0.00';
          }
        });
      },
    );
  }

  Widget _buildCycleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('دورية التجديد *', style: AppTypography.titleSmall),
        AppSpacing.gapVerticalXs,
        SegmentedButton<CycleType>(
          key: const Key('subscription_cycle_selector'),
          segments: const [
            ButtonSegment(value: CycleType.monthly, label: Text('شهري')),
            ButtonSegment(value: CycleType.yearly, label: Text('سنوي')),
            ButtonSegment(value: CycleType.weekly, label: Text('أسبوعي')),
            ButtonSegment(value: CycleType.custom, label: Text('مخصص')),
          ],
          selected: {_selectedCycleType},
          onSelectionChanged: (set) {
            HapticFeedbackHelper.selection();
            setState(() {
              _isDirty = true;
              _selectedCycleType = set.first;
              _dueDate = _calculateDefaultDueDate(
                _startDate,
                _selectedCycleType,
              );
            });
          },
        ),
        if (_selectedCycleType == CycleType.custom) ...[
          AppSpacing.gapVerticalM,
          Text('عدد أيام الدورية المخصصة *', style: AppTypography.titleSmall),
          AppSpacing.gapVerticalXs,
          TextFormField(
            key: const Key('subscription_custom_days_field'),
            controller: _customDaysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'مثال: 45 يوماً',
              errorText: _customDaysError,
              prefixIcon: const Icon(Icons.repeat_rounded),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التصنيف / الفئة', style: AppTypography.titleSmall),
        AppSpacing.gapVerticalXs,
        DropdownButtonFormField<String>(
          key: const Key('subscription_category_dropdown'),
          initialValue: _selectedCategoryId,
          items: [
            for (final cat in _availableCategories)
              DropdownMenuItem(
                value: cat.id,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.gapHorizontalS,
                    Text(cat.name),
                  ],
                ),
              ),
          ],
          onChanged: (val) {
            if (val != null) {
              HapticFeedbackHelper.selection();
              setState(() {
                _isDirty = true;
                _selectedCategoryId = val;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDatesRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تاريخ البدء', style: AppTypography.titleSmall),
              AppSpacing.gapVerticalXs,
              OutlinedButton.icon(
                key: const Key('subscription_start_date_picker'),
                onPressed: () => _pickDate(isStartDate: true),
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(SubscriptionFormatters.formatDate(_startDate)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.inputHeight),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.inputRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapHorizontalM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أول استحقاق', style: AppTypography.titleSmall),
              AppSpacing.gapVerticalXs,
              OutlinedButton.icon(
                key: const Key('subscription_due_date_picker'),
                onPressed: () => _pickDate(isStartDate: false),
                icon: const Icon(Icons.event_available_outlined),
                label: Text(SubscriptionFormatters.formatDate(_dueDate)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.inputHeight),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.inputRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSwitch() {
    return SwitchListTile(
      key: const Key('subscription_reminder_switch'),
      contentPadding: EdgeInsets.zero,
      title: const Text('تفعيل التنبيه المحلي'),
      subtitle: Text('التنبيه قبل الموعد بـ $_reminderLeadDays يوم'),
      value: _reminderEnabled,
      onChanged: (val) {
        HapticFeedbackHelper.selection();
        setState(() {
          _isDirty = true;
          _reminderEnabled = val;
        });
      },
    );
  }

  Widget _buildPaymentMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('وسيلة الدفع (اختياري)', style: AppTypography.titleSmall),
        AppSpacing.gapVerticalXs,
        TextFormField(
          key: const Key('subscription_payment_method_field'),
          controller: _paymentMethodController,
          maxLength: 50,
          decoration: const InputDecoration(
            hintText: 'مثال: فيزا 4242، فودافون كاش',
            counterText: '',
            prefixIcon: Icon(Icons.credit_card_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ملاحظات (اختياري)', style: AppTypography.titleSmall),
        AppSpacing.gapVerticalXs,
        TextFormField(
          key: const Key('subscription_notes_field'),
          controller: _notesController,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'أي تفاصيل أو شروط خاصة بالاشتراك...',
            counterText: '',
          ),
        ),
      ],
    );
  }
}

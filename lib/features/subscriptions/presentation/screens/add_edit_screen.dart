import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/theme/widgets/app_background.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../domain/value_objects/billing_cycle.dart';
import '../../domain/value_objects/obligation_type.dart';
import '../formatters/currency_icon_resolver.dart';
import '../formatters/date_formatter.dart';
import '../state/add_edit_subscription_controller.dart';
import '../state/view_state.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';

/// Screen for adding and editing subscriptions with defensive validation and 4 view states.
///
/// Complies with:
/// - [FR-01] Add subscription with name, price, currency, cycle, start date, category.
/// - [FR-04] Edit subscription with original values pre-populated.
/// - [EC-01-1]..[EC-01-5] Validation rules, trimming, and double-tap submit lock.
/// - [EC-01-4] Unsaved changes warning on back navigation.
/// - [NFR-04] Min 48x48 dp touch targets.
class AddEditSubscriptionScreen extends StatefulWidget {
  final AddEditSubscriptionController controller;
  final String? subscriptionId;
  final String defaultCurrency;

  const AddEditSubscriptionScreen({
    super.key,
    required this.controller,
    this.subscriptionId,
    this.defaultCurrency = 'USD',
  });

  @override
  State<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _customDaysController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _customDaysController = TextEditingController(text: '30');
    _paymentMethodController = TextEditingController();
    _notesController = TextEditingController();

    widget.controller.initialize(
      subscriptionId: widget.subscriptionId,
      defaultCurrency: widget.defaultCurrency,
    );

    widget.controller.addListener(_syncTextControllers);
  }

  void _syncTextControllers() {
    final state = widget.controller.state;
    if (state is ViewStateData<AddEditFormState>) {
      final form = state.data;
      if (_nameController.text != form.name) {
        _nameController.value = TextEditingValue(
          text: form.name,
          selection: TextSelection.collapsed(offset: form.name.length),
        );
      }
      if (_priceController.text != form.priceText) {
        _priceController.value = TextEditingValue(
          text: form.priceText,
          selection: TextSelection.collapsed(offset: form.priceText.length),
        );
      }
      if (form.cycle.isCustom) {
        final days = form.cycle.customDays?.toString() ?? '30';
        if (_customDaysController.text != days) {
          _customDaysController.text = days;
        }
      }
      if (_paymentMethodController.text != form.paymentMethodDesc) {
        _paymentMethodController.text = form.paymentMethodDesc;
      }
      if (_notesController.text != form.notes) {
        _notesController.text = form.notes;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncTextControllers);
    _nameController.dispose();
    _priceController.dispose();
    _customDaysController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(
    BuildContext context,
    AddEditFormState formState,
  ) async {
    if (!formState.hasUnsavedChanges || formState.isSubmitting) {
      return true;
    }

    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.unsavedChangesTitle ?? 'تغييرات غير محفوظة'),
        content: Text(
          l10n?.unsavedChangesMessage ??
              'لديك تعديلات غير محفوظة. هل أنت متأكد من رغبتك في المغادرة وتجاهل التغييرات؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.keepEditing ?? 'متابعة التعديل'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.discardChanges ?? 'تجاهل التغييرات'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        return switch (state) {
          ViewStateLoading() => Scaffold(
            appBar: AppBar(
              title: Text(
                widget.subscriptionId == null
                    ? (l10n?.addSubscription ?? 'إضافة اشتراك جديد')
                    : (l10n?.editSubscription ?? 'تعديل الاشتراك'),
              ),
            ),
            body: AppLoadingView(
              message: l10n?.subscriptionsTab ?? 'جاري التحميل...',
            ),
          ),
          ViewStateError(message: final msg, onRetry: final retry) => Scaffold(
            appBar: AppBar(
              title: Text(
                widget.subscriptionId == null
                    ? (l10n?.addSubscription ?? 'إضافة اشتراك جديد')
                    : (l10n?.editSubscription ?? 'تعديل الاشتراك'),
              ),
            ),
            body: AppErrorView(
              message: msg,
              onRetry: retry,
              retryLabel: l10n?.retry ?? 'إعادة المحاولة',
            ),
          ),
          ViewStateEmpty(title: final t, subtitle: final sub) => Scaffold(
            appBar: AppBar(
              title: Text(l10n?.addSubscription ?? 'إضافة اشتراك'),
            ),
            body: AppEmptyView(title: t, subtitle: sub),
          ),
          ViewStateData(data: final formState) => PopScope(
            canPop: !formState.hasUnsavedChanges || formState.isSubmitting,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await _onWillPop(context, formState);
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  formState.isEditMode
                      ? (l10n?.editSubscription ?? 'تعديل الاشتراك')
                      : (l10n?.addSubscription ?? 'إضافة اشتراك جديد'),
                ),
              ),
              body: AppBackground(child: _buildForm(context, formState, l10n)),
              bottomNavigationBar: _buildBottomBar(context, formState, l10n),
            ),
          ),
        };
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    AddEditFormState formState,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (formState.generalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Text(
                    formState.generalError!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Obligation Type Selector
              Text(
                'نوع الالتزام / الدفعة',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<ObligationType>(
                  key: const Key('add_edit_obligation_type_segmented_button'),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ObligationType.subscription,
                      label: Text('اشتراك'),
                      icon: Icon(Icons.subscriptions_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: ObligationType.bill,
                      label: Text('فاتورة'),
                      icon: Icon(Icons.receipt_long_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: ObligationType.rent,
                      label: Text('إيجار'),
                      icon: Icon(Icons.home_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: ObligationType.other,
                      label: Text('أخرى'),
                      icon: Icon(Icons.more_horiz, size: 18),
                    ),
                  ],
                  selected: {formState.obligationType},
                  onSelectionChanged: (selected) {
                    widget.controller.updateObligationType(selected.first);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Name field
              TextFormField(
                key: const Key('add_edit_name_field'),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n?.subscriptionName ?? 'اسم الاشتراك',
                  hintText: 'مثال: Netflix, Spotify',
                  prefixIcon: const Icon(Icons.label_outline),
                  errorText: formState.nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onChanged: widget.controller.updateName,
              ),
              const SizedBox(height: AppSpacing.md),

              // Price and Currency row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: const Key('add_edit_price_field'),
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n?.subscriptionPrice ?? 'المبلغ / القيمة',
                        hintText: '0.00',
                        prefixIcon: CurrencyIconResolver.buildCurrencyPrefix(
                          formState.currency,
                          color: theme.colorScheme.primary,
                        ),
                        errorText: formState.priceError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: widget.controller.updatePriceText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      key: const Key('add_edit_currency_dropdown'),
                      isExpanded: true,
                      initialValue: formState.currency,
                      decoration: InputDecoration(
                        labelText: l10n?.currency ?? 'العملة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                        DropdownMenuItem(
                          value: 'SAR',
                          child: Text('SAR (ر.س)'),
                        ),
                        DropdownMenuItem(
                          value: 'AED',
                          child: Text('AED (د.إ)'),
                        ),
                        DropdownMenuItem(
                          value: 'YER',
                          child: Text('YER (ر.ي)'),
                        ),
                        DropdownMenuItem(value: 'JPY', child: Text('JPY (¥)')),
                      ],
                      onChanged: (val) {
                        if (val != null) widget.controller.updateCurrency(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Billing Cycle Segmented Control
              Text(
                l10n?.billingCycle ?? 'دورية الفوترة',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<CycleType>(
                  key: const Key('add_edit_cycle_segmented_button'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: CycleType.monthly,
                      label: Text(l10n?.monthly ?? 'شهرياً'),
                    ),
                    ButtonSegment(
                      value: CycleType.yearly,
                      label: Text(l10n?.yearly ?? 'سنوياً'),
                    ),
                    ButtonSegment(
                      value: CycleType.weekly,
                      label: Text(l10n?.weekly ?? 'أسبوعياً'),
                    ),
                    const ButtonSegment(
                      value: CycleType.custom,
                      label: Text('مخصص'),
                    ),
                  ],
                  selected: {formState.cycle.type},
                  onSelectionChanged: (selected) {
                    final type = selected.first;
                    switch (type) {
                      case CycleType.monthly:
                        widget.controller.updateCycle(
                          const BillingCycle.monthly(),
                        );
                        break;
                      case CycleType.yearly:
                        widget.controller.updateCycle(
                          const BillingCycle.yearly(),
                        );
                        break;
                      case CycleType.weekly:
                        widget.controller.updateCycle(
                          const BillingCycle.weekly(),
                        );
                        break;
                      case CycleType.custom:
                        final days =
                            int.tryParse(_customDaysController.text) ?? 30;
                        widget.controller.updateCycle(
                          BillingCycle.custom(days),
                        );
                        break;
                    }
                  },
                ),
              ),

              if (formState.cycle.isCustom) ...[
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  key: const Key('add_edit_custom_days_field'),
                  controller: _customDaysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.customDaysInterval ??
                        'عدد الأيام للدورية المخصصة',
                    hintText: '30',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  onChanged: (val) {
                    final days = int.tryParse(val);
                    if (days != null && days > 0) {
                      widget.controller.updateCycle(BillingCycle.custom(days));
                    }
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Date Pickers Row
              Row(
                children: [
                  Expanded(
                    child: _buildDatePickerCard(
                      context: context,
                      key: const Key('add_edit_start_date_picker'),
                      label: l10n?.startDate ?? 'تاريخ البدء',
                      formattedDate: DateFormatter.formatDate(
                        formState.startDate,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: formState.startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          widget.controller.updateStartDate(picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildDatePickerCard(
                      context: context,
                      key: const Key('add_edit_next_due_date_picker'),
                      label: l10n?.nextDueDate ?? 'تاريخ الاستحقاق',
                      formattedDate: DateFormatter.formatDate(
                        formState.nextDueDate,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: formState.nextDueDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          widget.controller.updateNextDueDate(picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Category Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.category ?? 'الفئة',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('add_edit_new_category_button'),
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('فئة جديدة'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                key: const Key('add_edit_category_dropdown'),
                isExpanded: true,
                initialValue:
                    formState.availableCategories.any(
                      (c) => c.id == formState.categoryId,
                    )
                    ? formState.categoryId
                    : (formState.availableCategories.isNotEmpty
                          ? formState.availableCategories.first.id
                          : null),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                items: formState.availableCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(cat.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) widget.controller.updateCategory(val);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Payment Method (Optional)
              TextFormField(
                key: const Key('add_edit_payment_method_field'),
                controller: _paymentMethodController,
                decoration: InputDecoration(
                  labelText: l10n?.paymentMethod ?? 'وسيلة الدفع (اختياري)',
                  hintText: 'مثال: بطاقة مدى / Visa',
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onChanged: widget.controller.updatePaymentMethod,
              ),
              const SizedBox(height: AppSpacing.md),

              // Notes (Optional)
              TextFormField(
                key: const Key('add_edit_notes_field'),
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n?.notes ?? 'ملاحظات (اختياري)',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                onChanged: widget.controller.updateNotes,
              ),
              const SizedBox(height: AppSpacing.md),

              // Reminders & Local Notifications Card (FR-10, US-26)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.cardRadius,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        key: const Key('add_edit_reminder_switch'),
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.indigo500,
                          size: 20,
                        ),
                        title: const Text(
                          'تنبيهات الاستحقاق',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'تلقي إشعار محلي على الجهاز قبل موعد الفاتورة',
                        ),
                        value: formState.reminderEnabled,
                        onChanged: widget.controller.updateReminderEnabled,
                      ),
                      if (formState.reminderEnabled) ...[
                        const Divider(height: AppSpacing.md),
                        Text(
                          'تنبيهي قبل موعد الفاتورة بـ:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [1, 2, 3, 7].map((days) {
                            final isSelected =
                                formState.reminderLeadDays == days;
                            return ChoiceChip(
                              label: Text(
                                days == 1
                                    ? 'يوم واحد'
                                    : days == 2
                                    ? 'يومين'
                                    : '$days أيام',
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  AppHaptics.selectionClick();
                                  widget.controller.updateReminderLeadDays(
                                    days,
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('وقت التنبيه:'),
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.access_time_rounded,
                                size: 18,
                              ),
                              label: Text(
                                '${formState.reminderTimeHour.toString().padLeft(2, '0')}:${formState.reminderTimeMinute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: formState.reminderTimeHour,
                                    minute: formState.reminderTimeMinute,
                                  ),
                                );
                                if (time != null) {
                                  widget.controller.updateReminderTime(
                                    time.hour,
                                    time.minute,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard({
    required BuildContext context,
    required Key key,
    required String label,
    required String formattedDate,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MinTouchTarget(
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AddEditFormState formState,
    AppLocalizations? l10n,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: MinTouchTarget(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  key: const Key('add_edit_save_button'),
                  onPressed: formState.isSubmitting
                      ? null
                      : () async {
                          AppHaptics.mediumImpact();
                          final success = await widget.controller
                              .saveSubscription();
                          if (success && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  child: formState.isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(l10n?.save ?? 'حفظ'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    int selectedColor = 0xFF8B5CF6;
    final formKey = GlobalKey<FormState>();

    const colors = [
      0xFF8B5CF6, // Violet
      0xFF3B82F6, // Blue
      0xFF10B981, // Emerald
      0xFFF59E0B, // Amber
      0xFFEF4444, // Red
      0xFFEC4899, // Pink
      0xFF06B6D4, // Cyan
      0xFF84CC16, // Lime
    ];

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.category_rounded, color: AppColors.indigo500),
                SizedBox(width: AppSpacing.sm),
                Text('إضافة فئة جديدة'),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'اسم الفئة',
                        hintText: 'مثال: ألعاب، اتصالات، طعام...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال اسم الفئة';
                        }
                        if (val.trim().length > 24) {
                          return 'اسم الفئة يجب ألا يتجاوز 24 حرفاً';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'لون الفئة:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((col) {
                        final isSelected = selectedColor == col;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedColor = col),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(col),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(
                                          col,
                                        ).withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final cat = await widget.controller.createNewCategory(
                      name: nameController.text.trim(),
                      colorValue: selectedColor,
                    );
                    if (cat != null && ctx.mounted) {
                      Navigator.of(ctx).pop(true);
                    }
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الفئة بنجاح واختيارها تلقائياً'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

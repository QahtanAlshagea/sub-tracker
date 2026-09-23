import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/theme/widgets/app_background.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/get_payment_history_usecase.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/subscription_status.dart';
import '../formatters/arabic_plural_formatter.dart';
import '../formatters/currency_formatter.dart';
import '../formatters/date_formatter.dart';

/// Screen displaying complete subscription details, payment history logs,
/// and quick lifecycle actions.
///
/// Implements [FR-03], [FR-11], [US-06], [US-28].
class SubscriptionDetailsScreen extends StatefulWidget {
  final Subscription subscription;
  final Category? category;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubscriptionDetailsScreen({
    super.key,
    required this.subscription,
    this.category,
    required this.getPaymentHistoryUseCase,
    this.onMarkPaid,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  List<PaymentRecord> _paymentHistory = [];
  bool _isLoadingPayments = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() => _isLoadingPayments = true);
    final result = await widget.getPaymentHistoryUseCase(
      widget.subscription.id,
    );
    if (mounted) {
      setState(() {
        _paymentHistory = result.dataOrNull ?? [];
        _isLoadingPayments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final sub = widget.subscription;

    final daysRemaining = sub.dueDate.daysUntil(DateTime.now());
    final categoryName =
        widget.category?.name ?? (l10n?.uncategorized ?? 'غير مصنّف');
    final categoryColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppColors.indigo600;

    final totalPaidMinorUnits = _paymentHistory.fold<int>(
      0,
      (sum, p) => sum + p.amount.amountMinorUnits,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(sub.name),
        actions: [
          if (widget.onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n?.edit ?? 'تعديل',
              onPressed: () {
                AppHaptics.lightImpact();
                widget.onEdit?.call();
              },
            ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n?.delete ?? 'حذف',
              onPressed: () {
                AppHaptics.mediumImpact();
                widget.onDelete?.call();
              },
            ),
        ],
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: _loadPaymentHistory,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // 1. Header Card with Amount & Status
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                categoryName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.slate100,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.sm,
                                  ),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  sub.obligationType.displayNameArabic,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AccessibleStatusBadge(
                            type: sub.status == SubscriptionStatus.archived
                                ? StatusBadgeType.archived
                                : sub.isTrial
                                ? StatusBadgeType.trial
                                : (sub.isOverdue || daysRemaining < 0)
                                ? StatusBadgeType.overdue
                                : daysRemaining <= 3
                                ? StatusBadgeType.dueSoon
                                : StatusBadgeType.active,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        sub.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(sub.price),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          if (l10n != null)
                            Text(
                              '/ ${DateFormatter.formatCycle(sub.cycle, l10n)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Financial Summary Highlights
              Row(
                children: [
                  Expanded(
                    child: Card(
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
                            Text(
                              'الدفعات المسددة',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ArabicPluralFormatter.formatPaymentsCount(
                                _paymentHistory.length,
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald500,
                              ),
                            ),
                            if (_paymentHistory.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'الإجمالي: ${CurrencyFormatter.format(Money(amountMinorUnits: totalPaidMinorUnits, currencyCode: sub.price.currencyCode))}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Card(
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
                            Text(
                              'الاستحقاق القادم',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              DateFormatter.formatDate(sub.dueDate.date),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Section: سجل الدفعات والتسديدات التاريخية (Payment History)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سجل التسديدات والدفعات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.onMarkPaid != null)
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        AppHaptics.lightImpact();
                        widget.onMarkPaid?.call();
                        await Future.delayed(const Duration(milliseconds: 300));
                        _loadPaymentHistory();
                      },
                      icon: const Icon(Icons.add_task_rounded, size: 18),
                      label: const Text('تسديد دورة'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (_isLoadingPayments)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (_paymentHistory.isEmpty)
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
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'لا توجد دفعات مسجلة بعد',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'هذا الاشتراك جديد بانتظار أول عملية سداد. اضغط على "تسديد دورة" لتوثيق السداد وترحيل الفاتورة.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._paymentHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final payment = entry.value;
                  final paymentNumber = _paymentHistory.length - index;

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.cardRadius,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.emerald500.withValues(
                          alpha: 0.15,
                        ),
                        child: const Icon(
                          Icons.done_all_rounded,
                          color: AppColors.emerald500,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'الدفعة #$paymentNumber (${CurrencyFormatter.format(payment.amount)})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'تاريخ السداد: ${DateFormatter.formatDate(payment.paidAt)}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald500.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: const Text(
                          'مسدد ✓',
                          style: TextStyle(
                            color: AppColors.emerald600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.lg),

              // 4. Subscription Metadata
              Text(
                'بيانات الاشتراك',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('تاريخ البدء'),
                      trailing: Text(
                        DateFormatter.formatDate(sub.startDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payment_outlined),
                      title: const Text('وسيلة الدفع'),
                      trailing: Text(
                        sub.paymentMethodDesc ?? 'غير محددة',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notes_outlined),
                        title: const Text('الملاحظات'),
                        subtitle: Text(sub.notes!),
                      ),
                    ],
                    if (sub.renewalUrl != null &&
                        sub.renewalUrl!.isNotEmpty) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.link_rounded),
                        title: const Text('رابط التجديد'),
                        subtitle: Text(
                          sub.renewalUrl!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

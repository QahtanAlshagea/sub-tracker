import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/theme/widgets/app_background.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/value_objects/due_date.dart';
import '../../domain/value_objects/obligation_type.dart';
import '../formatters/currency_formatter.dart';
import '../formatters/date_formatter.dart';
import '../state/subscriptions_list_controller.dart';
import '../state/view_state.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/subscription_card.dart';
import '../widgets/undo_deletion_snackbar.dart';

/// Primary root screen containing bottom navigation, the active subscriptions
/// list, and the add subscription action button.
///
/// Implements [FR-02], [US-05], [EC-05-1]..[EC-05-4], and [NFR-04]:
/// - Exhaustive Four View States: Data, Loading, Empty, Error.
/// - Minimum 48x48 dp touch target on Floating Action Button.
class HomeScreen extends StatefulWidget {
  final SubscriptionsListController controller;
  final Widget? summaryTab;
  final Widget? settingsTab;
  final VoidCallback? onAddSubscription;
  final void Function(Subscription subscription)? onSubscriptionTap;

  const HomeScreen({
    super.key,
    required this.controller,
    this.summaryTab,
    this.settingsTab,
    this.onAddSubscription,
    this.onSubscriptionTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SubscriptionsFilter { all, dueSoon, settled, overdue }

enum SortOption { nearestDue, highestCost, newestAdded }

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  SubscriptionsFilter _filter = SubscriptionsFilter.all;
  ObligationType? _obligationTypeFilter;
  SortOption _sortOption = SortOption.nearestDue;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Trigger initial load
    widget.controller.loadSubscriptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_currentTabIndex) {
          0 => l10n?.subscriptionsTab ?? 'الاشتراكات',
          1 => l10n?.summaryTab ?? 'الملخص',
          2 => l10n?.settingsTab ?? 'الإعدادات',
          _ => l10n?.appTitle ?? 'متتبع الدفعات الدورية',
        }),
      ),
      body: AppBackground(
        child: switch (_currentTabIndex) {
          0 => _buildSubscriptionsTab(context, l10n),
          1 => widget.summaryTab ?? const SizedBox.shrink(),
          2 => widget.settingsTab ?? const SizedBox.shrink(),
          _ => const SizedBox.shrink(),
        },
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton(
              key: const Key('home_fab_add'),
              onPressed: widget.onAddSubscription ?? () {},
              tooltip: l10n?.addSubscription ?? 'إضافة اشتراك',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          AppHaptics.selectionClick();
          setState(() => _currentTabIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list_alt_rounded),
            label: l10n?.subscriptionsTab ?? 'الاشتراكات',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_rounded),
            label: l10n?.summaryTab ?? 'الملخص',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n?.settingsTab ?? 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsTab(BuildContext context, AppLocalizations? l10n) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        return switch (state) {
          ViewStateLoading() => AppLoadingView(
            message: l10n?.subscriptionsTab ?? 'جاري التحميل...',
          ),
          ViewStateEmpty(
            title: final t,
            subtitle: final sub,
            actionLabel: final act,
          ) =>
            AppEmptyView(
              title: t,
              subtitle: sub,
              actionLabel: act,
              onAction: widget.onAddSubscription,
            ),
          ViewStateError(message: final msg, onRetry: final retry) =>
            AppErrorView(
              message: msg,
              onRetry: retry,
              retryLabel: l10n?.retry ?? 'إعادة المحاولة',
            ),
          ViewStateData(data: final subscriptions) =>
            _buildSubscriptionsDataView(context, subscriptions, l10n),
        };
      },
    );
  }

  Widget _buildSubscriptionsDataView(
    BuildContext context,
    List<Subscription> subscriptions,
    AppLocalizations? l10n,
  ) {
    final now = DateTime.now();
    final paymentCounts = widget.controller.paymentCounts;
    final dueSoonList = subscriptions.where((s) {
      final days = s.dueDate.daysUntil(now);
      final count = paymentCounts[s.id] ?? 0;
      return !s.isOverdue && days >= 0 && (count == 0 || days <= 7);
    }).toList();

    final settledList = subscriptions.where((s) {
      final days = s.dueDate.daysUntil(now);
      final count = paymentCounts[s.id] ?? 0;
      return !s.isOverdue && count > 0 && days > 7;
    }).toList();

    final overdueList = subscriptions.where((s) {
      final days = s.dueDate.daysUntil(now);
      return s.isOverdue || days < 0;
    }).toList();

    var filteredList = switch (_filter) {
      SubscriptionsFilter.all => subscriptions,
      SubscriptionsFilter.dueSoon => dueSoonList,
      SubscriptionsFilter.settled => settledList,
      SubscriptionsFilter.overdue => overdueList,
    };

    if (_obligationTypeFilter != null) {
      filteredList = filteredList
          .where((s) => s.obligationType == _obligationTypeFilter)
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filteredList = filteredList.where((s) {
        final cat =
            widget.controller.categoriesById[s.categoryId]?.name
                .toLowerCase() ??
            '';
        return s.name.toLowerCase().contains(q) ||
            cat.contains(q) ||
            (s.notes?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    filteredList = List.of(filteredList);
    switch (_sortOption) {
      case SortOption.nearestDue:
        filteredList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case SortOption.highestCost:
        filteredList.sort(
          (a, b) =>
              b.price.amountMinorUnits.compareTo(a.price.amountMinorUnits),
        );
        break;
      case SortOption.newestAdded:
        filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return RefreshIndicator(
      onRefresh: () async {
        AppHaptics.lightImpact();
        await widget.controller.loadSubscriptions();
      },
      child: Column(
        children: [
          // Search & Sort Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('home_search_field'),
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم، الفئة، أو الملاحظات...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                PopupMenuButton<SortOption>(
                  key: const Key('home_sort_button'),
                  tooltip: 'ترتيب حسب',
                  icon: const Icon(Icons.sort_rounded),
                  initialValue: _sortOption,
                  onSelected: (option) => setState(() => _sortOption = option),
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                      value: SortOption.nearestDue,
                      child: Text('الأقرب استحقاقاً'),
                    ),
                    PopupMenuItem(
                      value: SortOption.highestCost,
                      child: Text('الأعلى تكلفة'),
                    ),
                    PopupMenuItem(
                      value: SortOption.newestAdded,
                      child: Text('الأحدث إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    key: const Key('filter_chip_all'),
                    avatar: const Icon(Icons.apps_rounded, size: 16),
                    label: Text('الكل (${subscriptions.length})'),
                    selected: _filter == SubscriptionsFilter.all,
                    onSelected: (selected) {
                      if (selected) {
                        AppHaptics.selectionClick();
                        setState(() => _filter = SubscriptionsFilter.all);
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    key: const Key('filter_chip_due_soon'),
                    avatar: Icon(
                      Icons.notification_important_rounded,
                      size: 16,
                      color: dueSoonList.isNotEmpty ? AppColors.amber500 : null,
                    ),
                    label: Text('مستحقة قريباً (${dueSoonList.length})'),
                    selected: _filter == SubscriptionsFilter.dueSoon,
                    onSelected: (selected) {
                      if (selected) {
                        AppHaptics.selectionClick();
                        setState(() => _filter = SubscriptionsFilter.dueSoon);
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    key: const Key('filter_chip_settled'),
                    avatar: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.emerald500,
                    ),
                    label: Text('مسددة ومنتظمة (${settledList.length})'),
                    selected: _filter == SubscriptionsFilter.settled,
                    onSelected: (selected) {
                      if (selected) {
                        AppHaptics.selectionClick();
                        setState(() => _filter = SubscriptionsFilter.settled);
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    key: const Key('filter_chip_overdue'),
                    avatar: Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: overdueList.isNotEmpty ? AppColors.rose500 : null,
                    ),
                    label: Text('متأخرة (${overdueList.length})'),
                    selected: _filter == SubscriptionsFilter.overdue,
                    selectedColor: AppColors.rose500.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      if (selected) {
                        AppHaptics.selectionClick();
                        setState(() => _filter = SubscriptionsFilter.overdue);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Obligation Type Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 2.0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    key: const Key('type_filter_all'),
                    label: const Text('الكل'),
                    backgroundColor: _obligationTypeFilter == null
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () {
                      AppHaptics.selectionClick();
                      setState(() => _obligationTypeFilter = null);
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ActionChip(
                    key: const Key('type_filter_subscription'),
                    avatar: const Icon(Icons.subscriptions_outlined, size: 14),
                    label: const Text('اشتراكات'),
                    backgroundColor:
                        _obligationTypeFilter == ObligationType.subscription
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () {
                      AppHaptics.selectionClick();
                      setState(
                        () =>
                            _obligationTypeFilter = ObligationType.subscription,
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ActionChip(
                    key: const Key('type_filter_bill'),
                    avatar: const Icon(Icons.receipt_long_outlined, size: 14),
                    label: const Text('فواتير'),
                    backgroundColor:
                        _obligationTypeFilter == ObligationType.bill
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () {
                      AppHaptics.selectionClick();
                      setState(
                        () => _obligationTypeFilter = ObligationType.bill,
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ActionChip(
                    key: const Key('type_filter_rent'),
                    avatar: const Icon(Icons.home_outlined, size: 14),
                    label: const Text('إيجارات'),
                    backgroundColor:
                        _obligationTypeFilter == ObligationType.rent
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () {
                      AppHaptics.selectionClick();
                      setState(
                        () => _obligationTypeFilter = ObligationType.rent,
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ActionChip(
                    key: const Key('type_filter_other'),
                    avatar: const Icon(Icons.more_horiz, size: 14),
                    label: const Text('أخرى'),
                    backgroundColor:
                        _obligationTypeFilter == ObligationType.other
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () {
                      AppHaptics.selectionClick();
                      setState(
                        () => _obligationTypeFilter = ObligationType.other,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // List content
          Expanded(
            child: filteredList.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _filter == SubscriptionsFilter.overdue
                                      ? Icons.verified_user_outlined
                                      : (_filter == SubscriptionsFilter.dueSoon
                                            ? Icons.celebration_rounded
                                            : Icons
                                                  .check_circle_outline_rounded),
                                  size: 64,
                                  color: AppColors.emerald500,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _filter == SubscriptionsFilter.overdue
                                      ? 'لا توجد التزامات متأخرة! 👏'
                                      : (_filter == SubscriptionsFilter.dueSoon
                                            ? 'جميع الالتزامات مسددة! 🎉'
                                            : (_searchQuery.isNotEmpty
                                                  ? 'لا توجد نتائج مطابقة للبحث'
                                                  : 'لا توجد عناصر في هذا التبويب')),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _filter == SubscriptionsFilter.overdue
                                      ? 'جميع دفعاتك والتزاماتك الدورية تحت السيطرة وفي موعدها.'
                                      : (_filter == SubscriptionsFilter.dueSoon
                                            ? 'رائع! لا توجد فواتير أو التزامات مستحقة خلال الأيام القادمة.'
                                            : 'العناصر المسددة والمنتظمة ستظهر هنا.'),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;

                      Widget buildCard(Subscription sub) {
                        final category =
                            widget.controller.categoriesById[sub.categoryId];
                        final paymentCount =
                            widget.controller.paymentCounts[sub.id] ?? 0;

                        return SubscriptionCard(
                          subscription: sub,
                          category: category,
                          paymentCount: paymentCount,
                          onTap: () {
                            AppHaptics.selectionClick();
                            widget.onSubscriptionTap?.call(sub);
                          },
                          onMarkPaid: () => _confirmAndMarkPaid(sub, l10n),
                          onDelete: () => _confirmAndDelete(sub, l10n),
                        );
                      }

                      if (isWide) {
                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 450,
                                mainAxisExtent: 190,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                              ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) =>
                              buildCard(filteredList[index]),
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) =>
                            buildCard(filteredList[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isDeleting = false;

  Future<void> _confirmAndDelete(
    Subscription sub,
    AppLocalizations? l10n,
  ) async {
    AppHaptics.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(l10n?.delete ?? 'تأكيد الحذف'),
              content: Text(
                'هل أنت متأكد من رغبتك في حذف الاشتراك "${sub.name}"؟ يمكنك التراجع خلال 5 ثوانٍ.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n?.cancel ?? 'إلغاء'),
                ),
                FilledButton(
                  key: const Key('confirm_delete_dialog_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _isDeleting
                      ? null
                      : () {
                          setDialogState(() => _isDeleting = true);
                          Navigator.of(ctx).pop(true);
                        },
                  child: Text(l10n?.delete ?? 'حذف'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) {
      _isDeleting = false;
      return;
    }

    AppHaptics.mediumImpact();
    final success = await widget.controller.deleteSubscription(sub.id);
    if (!mounted) {
      _isDeleting = false;
      return;
    }

    if (success) {
      UndoDeletionSnackBar.show(
        context: context,
        itemName: sub.name,
        onUndo: () async {
          await widget.controller.restoreSubscription(sub.id);
        },
      );
    }
    _isDeleting = false;
  }

  bool _isProcessingPayment = false;

  Future<void> _confirmAndMarkPaid(
    Subscription sub,
    AppLocalizations? l10n,
  ) async {
    AppHaptics.lightImpact();

    final now = DateTime.now();
    final isOverdue = sub.dueDate.isOverdue(now);
    final standardNextDue = sub.dueDate.nextOccurrence(sub.cycle);
    final todayNextDue = DueDate(now).nextOccurrence(sub.cycle);

    var renewFromToday = isOverdue;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final effectiveNextDate = renewFromToday
                ? todayNextDue
                : standardNextDue;

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.emerald500,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n?.markAsPaid ?? 'تسديد الاشتراك'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sub.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('المبلغ والدورية:'),
                              Text(
                                '${CurrencyFormatter.format(sub.price)} / ${l10n != null ? DateFormatter.formatCycle(sub.cycle, l10n) : ""}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الاستحقاق الحالي:'),
                              Text(
                                DateFormatter.formatDate(sub.dueDate.date),
                                style: TextStyle(
                                  color: isOverdue ? AppColors.rose500 : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الاستحقاق القادم:'),
                              Text(
                                DateFormatter.formatDate(
                                  effectiveNextDate.date,
                                ),
                                style: const TextStyle(
                                  color: AppColors.emerald500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.amber500.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: const Text(
                          'تنبيه: هذا الاشتراك متأخر عن موعده. يمكنك اختيار تجديده بدءاً من اليوم لإنهاء فترة التأخير.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.amber500,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'تجديد الاستحقاق بدءاً من اليوم',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: renewFromToday,
                        onChanged: (val) {
                          setDialogState(() => renewFromToday = val ?? false);
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'ملاحظة: الضغط على "تأكيد السداد" يسجل دفع رسوم الدورة الحالية ويرحل تاريخ الفاتورة القادمة تلقائياً.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n?.cancel ?? 'إلغاء'),
                ),
                FilledButton(
                  key: const Key('confirm_pay_dialog_button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald600,
                  ),
                  onPressed: _isProcessingPayment
                      ? null
                      : () {
                          setDialogState(() => _isProcessingPayment = true);
                          Navigator.of(ctx).pop(true);
                        },
                  child: const Text('تأكيد السداد'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) {
      _isProcessingPayment = false;
      return;
    }

    AppHaptics.mediumImpact();
    final chosenNextDue = renewFromToday ? todayNextDue : standardNextDue;
    final success = await widget.controller.markAsPaid(
      sub.id,
      nextDueDate: isOverdue ? chosenNextDue : null,
    );

    if (!mounted) {
      _isProcessingPayment = false;
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'تم تسجيل سداد "${sub.name}" بنجاح! موعد الاستحقاق القادم: ${DateFormatter.formatDate(chosenNextDue.date)}',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.emerald600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    _isProcessingPayment = false;
  }
}

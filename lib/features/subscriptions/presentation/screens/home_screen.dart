import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../domain/entities/subscription.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Trigger initial load
    widget.controller.loadSubscriptions();
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
          _ => l10n?.appTitle ?? 'متتبع الاشتراكات',
        }),
      ),
      body: switch (_currentTabIndex) {
        0 => _buildSubscriptionsTab(context, l10n),
        1 => widget.summaryTab ?? const SizedBox.shrink(),
        2 => widget.settingsTab ?? const SizedBox.shrink(),
        _ => const SizedBox.shrink(),
      },
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
          ViewStateData(data: final subscriptions) => RefreshIndicator(
            onRefresh: () async {
              AppHaptics.lightImpact();
              await widget.controller.loadSubscriptions();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                Widget buildCard(Subscription sub) {
                  final category =
                      widget.controller.categoriesById[sub.categoryId];

                  return SubscriptionCard(
                    subscription: sub,
                    category: category,
                    onTap: () {
                      AppHaptics.selectionClick();
                      widget.onSubscriptionTap?.call(sub);
                    },
                    onMarkPaid: () async {
                      AppHaptics.lightImpact();
                      await widget.controller.markAsPaid(sub.id);
                    },
                    onDelete: () => _confirmAndDelete(sub, l10n),
                  );
                }

                if (isWide) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450,
                          mainAxisExtent: 190,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) =>
                        buildCard(subscriptions[index]),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) =>
                      buildCard(subscriptions[index]),
                );
              },
            ),
          ),
        };
      },
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
}

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../domain/entities/subscription.dart';
import '../state/subscriptions_list_controller.dart';
import '../state/view_state.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/subscription_card.dart';

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
          ? MinTouchTarget(
              child: FloatingActionButton(
                key: const Key('home_fab_add'),
                onPressed: widget.onAddSubscription ?? () {},
                tooltip: l10n?.addSubscription ?? 'إضافة اشتراك',
                child: const Icon(Icons.add_rounded),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
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
            onRefresh: widget.controller.loadSubscriptions,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                final category =
                    widget.controller.categoriesById[sub.categoryId];

                return SubscriptionCard(
                  subscription: sub,
                  category: category,
                  onTap: () => widget.onSubscriptionTap?.call(sub),
                  onMarkPaid: () => widget.controller.markAsPaid(sub.id),
                );
              },
            ),
          ),
        };
      },
    );
  }
}

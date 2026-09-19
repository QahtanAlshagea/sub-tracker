import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/subscription.dart';
import '../state/subscriptions_controller.dart';
import '../state/subscriptions_view_state.dart';
import '../utils/haptic_feedback_helper.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/loading_shimmer_view.dart';
import '../widgets/subscription_card.dart';
import '../widgets/summary_dashboard.dart';
import 'add_edit_subscription_screen.dart';

/// Main screen displaying the list of active subscriptions, summary board, and managing the 4 UI states.
///
/// Implements [US-05], [US-13], [US-14], and Card C-17 with:
/// - Swipe-to-delete with floating Undo SnackBar.
/// - Tactile haptic feedback on actions.
/// - Responsive state rendering without blank white screens.
class HomeScreen extends StatefulWidget {
  final SubscriptionsController? controller;
  final VoidCallback? onAddSubscription;
  final void Function(Subscription subscription)? onSubscriptionTap;
  final DateTime? referenceDate;

  const HomeScreen({
    super.key,
    this.controller,
    this.onAddSubscription,
    this.onSubscriptionTap,
    this.referenceDate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SubscriptionsController _controller;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = SubscriptionsController();
      _internalController = true;
      _controller.loadSubscriptions();
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _navigateToAddSubscription() {
    HapticFeedbackHelper.light();
    if (widget.onAddSubscription != null) {
      widget.onAddSubscription!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddEditSubscriptionScreen(
          onSaved: (subscription) {
            final currentState = _controller.state;
            if (currentState is SubscriptionsData) {
              final updated = List<Subscription>.from(
                currentState.subscriptions,
              )..add(subscription);
              _controller.setData(
                subscriptions: updated,
                categories: currentState.categories,
              );
            } else {
              _controller.setData(subscriptions: [subscription]);
            }
          },
        ),
      ),
    );
  }

  void _handleDeleteWithUndo(Subscription sub, int originalIndex) {
    final currentState = _controller.state;
    if (currentState is! SubscriptionsData) return;

    final currentSubs = List<Subscription>.from(currentState.subscriptions);
    final updatedSubs = List<Subscription>.from(currentSubs)
      ..removeWhere((item) => item.id == sub.id);

    // Update state immediately
    _controller.setData(
      subscriptions: updatedSubs,
      categories: currentState.categories,
    );

    // Show floating Undo SnackBar (US-13, US-14)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('undo_snackbar'),
        content: Text('تم حذف اشتراك "${sub.name}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          key: const Key('undo_delete_button'),
          label: 'تراجع',
          onPressed: () {
            HapticFeedbackHelper.medium();
            final restoredList = List<Subscription>.from(
              _controller.state is SubscriptionsData
                  ? (_controller.state as SubscriptionsData).subscriptions
                  : updatedSubs,
            );

            if (originalIndex <= restoredList.length) {
              restoredList.insert(originalIndex, sub);
            } else {
              restoredList.add(sub);
            }

            _controller.setData(
              subscriptions: restoredList,
              categories: currentState.categories,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('متتبع الاشتراكات'),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'تحديث البيانات',
              icon: const Icon(Icons.sync_rounded),
              onPressed: () {
                HapticFeedbackHelper.light();
                _controller.loadSubscriptions();
              },
            ),
          ],
        ),
        body: ValueListenableBuilder<SubscriptionsViewState>(
          valueListenable: _controller,
          builder: (context, state, child) {
            return switch (state) {
              SubscriptionsLoading() => const LoadingShimmerView(
                key: Key('home_loading_view'),
              ),
              SubscriptionsEmpty(:final title, :final message) =>
                EmptyStateView(
                  key: const Key('home_empty_view'),
                  title: title,
                  message: message,
                  onAction: _navigateToAddSubscription,
                ),
              SubscriptionsError(:final message, :final onRetry) =>
                ErrorStateView(
                  key: const Key('home_error_view'),
                  message: message,
                  onRetry: onRetry,
                ),
              SubscriptionsData(
                :final subscriptions,
                :final categories,
                :final summary,
              ) =>
                RefreshIndicator(
                  onRefresh: () => _controller.loadSubscriptions(),
                  child: ListView.builder(
                    key: const Key('home_subscriptions_list'),
                    padding: AppSpacing.screenPadding,
                    itemCount: subscriptions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SummaryDashboard(
                          key: const Key('home_summary_dashboard'),
                          summary: summary,
                        );
                      }
                      final subIndex = index - 1;
                      final sub = subscriptions[subIndex];
                      return SubscriptionCard(
                        key: Key('subscription_card_${sub.id}'),
                        subscription: sub,
                        category: categories[sub.categoryId],
                        referenceDate: widget.referenceDate,
                        onDismissed: (_) =>
                            _handleDeleteWithUndo(sub, subIndex),
                        onTap: () {
                          if (widget.onSubscriptionTap != null) {
                            widget.onSubscriptionTap!(sub);
                          }
                        },
                      );
                    },
                  ),
                ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('add_subscription_fab'),
          onPressed: _navigateToAddSubscription,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة التزام'),
        ),
      ),
    );
  }
}

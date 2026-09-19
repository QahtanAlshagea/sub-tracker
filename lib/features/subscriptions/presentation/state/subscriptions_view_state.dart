import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/entities/subscription.dart';
import 'expense_summary.dart';

/// Sealed hierarchy strictly representing the Four States of Subscriptions UI:
/// - Loading (التحميل)
/// - Empty (الفراغ)
/// - Data (عرض البيانات)
/// - Error (الخطأ مع زر إعادة المحاولة)
sealed class SubscriptionsViewState {
  const SubscriptionsViewState();
}

/// Loading state indicating data retrieval or background synchronization.
final class SubscriptionsLoading extends SubscriptionsViewState {
  final String? message;

  const SubscriptionsLoading([this.message]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionsLoading &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Empty state indicating that no subscriptions currently exist.
final class SubscriptionsEmpty extends SubscriptionsViewState {
  final String title;
  final String message;

  const SubscriptionsEmpty({
    this.title = 'لا توجد التزامات دورية بعد',
    this.message =
        'أضف اشتراكاتك وفواتيرك الدورية لتتبّع مواعيد استحقاقها ومصروفاتها الشهرية بدقة.',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionsEmpty &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message;

  @override
  int get hashCode => Object.hash(title, message);
}

/// Data state holding verified subscription list, categories lookup, and expense analytics.
final class SubscriptionsData extends SubscriptionsViewState {
  final List<Subscription> subscriptions;
  final Map<String, Category> categories;
  final ExpenseSummary summary;

  const SubscriptionsData({
    required this.subscriptions,
    required this.categories,
    required this.summary,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionsData &&
          runtimeType == other.runtimeType &&
          listEquals(subscriptions, other.subscriptions) &&
          mapEquals(categories, other.categories) &&
          summary == other.summary;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(subscriptions),
    Object.hashAll(categories.entries),
    summary,
  );
}

/// Error state indicating failure, providing user-facing Arabic message and retry handler.
final class SubscriptionsError extends SubscriptionsViewState {
  final String message;
  final VoidCallback? onRetry;

  const SubscriptionsError({
    this.message = 'تعذّر تحميل البيانات. يرجى المحاولة مرة أخرى.',
    this.onRetry,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionsError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

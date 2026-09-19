import '../value_objects/money.dart';

/// Aggregated spending metrics for a single category within a specific currency.
///
/// Implements FR-07, US-19, EC-19-1..3.
/// Pure Dart — zero external dependencies.
class CategoryDistributionItem {
  /// Unique identifier of the category, or system uncategorized ID.
  final String categoryId;

  /// Display name of the category (e.g., "ترفيه", "خدمات", or "غير مصنّف").
  final String categoryName;

  /// 32-bit ARGB color value integer for UI charts and tags.
  final int colorValue;

  /// Optional icon code identifier.
  final String? iconCode;

  /// Total monthly equivalent spending for all subscriptions in this category.
  final Money totalMonthlyEquivalent;

  /// Percentage of overall monthly spending in this currency (0.0 to 100.0).
  final double percentage;

  /// Number of active subscriptions in this category.
  final int subscriptionsCount;

  /// Indicates if this item groups uncategorized subscriptions (EC-19-1..3).
  final bool isUncategorized;

  const CategoryDistributionItem({
    required this.categoryId,
    required this.categoryName,
    required this.colorValue,
    this.iconCode,
    required this.totalMonthlyEquivalent,
    required this.percentage,
    required this.subscriptionsCount,
    this.isUncategorized = false,
  }) : assert(
         percentage >= 0.0 && percentage <= 100.0,
         'percentage must be between 0.0 and 100.0',
       ),
       assert(subscriptionsCount >= 0, 'subscriptionsCount cannot be negative');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDistributionItem &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          colorValue == other.colorValue &&
          iconCode == other.iconCode &&
          totalMonthlyEquivalent == other.totalMonthlyEquivalent &&
          (percentage - other.percentage).abs() < 0.001 &&
          subscriptionsCount == other.subscriptionsCount &&
          isUncategorized == other.isUncategorized;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      categoryName.hashCode ^
      colorValue.hashCode ^
      iconCode.hashCode ^
      totalMonthlyEquivalent.hashCode ^
      percentage.hashCode ^
      subscriptionsCount.hashCode ^
      isUncategorized.hashCode;

  @override
  String toString() =>
      'CategoryDistributionItem($categoryName, ${totalMonthlyEquivalent.amountMinorUnits} ${totalMonthlyEquivalent.currencyCode}, '
      '${percentage.toStringAsFixed(1)}%, count: $subscriptionsCount, uncategorized: $isUncategorized)';
}

/// Complete report of category spending distribution for a specific currency.
class CategoryDistributionResult {
  /// The ISO 4217 currency code of this report.
  final String currencyCode;

  /// Grand total monthly equivalent spending across all active categories in this currency.
  final Money totalMonthlyEquivalent;

  /// Categorized spending breakdown sorted descending by cost.
  final List<CategoryDistributionItem> items;

  const CategoryDistributionResult({
    required this.currencyCode,
    required this.totalMonthlyEquivalent,
    required this.items,
  });

  /// Creates an empty result representing zero subscriptions (EC-19-3).
  factory CategoryDistributionResult.empty(String currencyCode) {
    return CategoryDistributionResult(
      currencyCode: currencyCode,
      totalMonthlyEquivalent: Money.zero(currencyCode),
      items: const [],
    );
  }

  /// True if there are no categories / active subscriptions in this currency.
  bool get isEmpty => items.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDistributionResult &&
          runtimeType == other.runtimeType &&
          currencyCode == other.currencyCode &&
          totalMonthlyEquivalent == other.totalMonthlyEquivalent &&
          _itemsEqual(items, other.items);

  static bool _itemsEqual(
    List<CategoryDistributionItem> a,
    List<CategoryDistributionItem> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      currencyCode.hashCode ^
      totalMonthlyEquivalent.hashCode ^
      items.length.hashCode;

  @override
  String toString() =>
      'CategoryDistributionResult($currencyCode, total: $totalMonthlyEquivalent, categories: ${items.length})';
}

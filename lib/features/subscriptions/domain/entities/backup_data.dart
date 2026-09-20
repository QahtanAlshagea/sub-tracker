import 'category.dart';
import 'price_history_entry.dart';
import 'subscription.dart';

/// Pure domain entity representing complete backup data.
/// Zero Flutter or persistence dependencies.
class BackupData {
  final int schemaVersion;
  final DateTime exportedAt;
  final String appVersion;
  final List<Category> categories;
  final List<Subscription> subscriptions;
  final List<PriceHistoryEntry> priceHistory;
  final Map<String, dynamic> settings;

  const BackupData({
    required this.schemaVersion,
    required this.exportedAt,
    this.appVersion = '1.0.0',
    required this.categories,
    required this.subscriptions,
    required this.priceHistory,
    this.settings = const <String, dynamic>{},
  });

  /// Whether the backup contains zero user subscriptions and zero user-created categories.
  bool get isEmpty =>
      subscriptions.isEmpty && categories.where((c) => !c.isSystem).isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupData &&
          runtimeType == other.runtimeType &&
          schemaVersion == other.schemaVersion &&
          exportedAt == other.exportedAt &&
          appVersion == other.appVersion &&
          _listEquals(categories, other.categories) &&
          _listEquals(subscriptions, other.subscriptions) &&
          _listEquals(priceHistory, other.priceHistory);

  @override
  int get hashCode =>
      schemaVersion.hashCode ^
      exportedAt.hashCode ^
      appVersion.hashCode ^
      categories.length.hashCode ^
      subscriptions.length.hashCode ^
      priceHistory.length.hashCode;

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

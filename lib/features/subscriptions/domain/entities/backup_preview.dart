/// Pure domain entity representing a pre-import preview of a backup file.
/// Zero Flutter or persistence dependencies.
class BackupPreview {
  final int schemaVersion;
  final DateTime exportedAt;
  final String appVersion;
  final int totalCategories;
  final int newCategories;
  final int duplicateCategories;
  final int totalSubscriptions;
  final int newSubscriptions;
  final int duplicateSubscriptions;
  final int totalPriceHistories;

  const BackupPreview({
    required this.schemaVersion,
    required this.exportedAt,
    this.appVersion = '1.0.0',
    required this.totalCategories,
    required this.newCategories,
    required this.duplicateCategories,
    required this.totalSubscriptions,
    required this.newSubscriptions,
    required this.duplicateSubscriptions,
    required this.totalPriceHistories,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupPreview &&
          runtimeType == other.runtimeType &&
          schemaVersion == other.schemaVersion &&
          exportedAt == other.exportedAt &&
          totalCategories == other.totalCategories &&
          newCategories == other.newCategories &&
          duplicateCategories == other.duplicateCategories &&
          totalSubscriptions == other.totalSubscriptions &&
          newSubscriptions == other.newSubscriptions &&
          duplicateSubscriptions == other.duplicateSubscriptions &&
          totalPriceHistories == other.totalPriceHistories;

  @override
  int get hashCode =>
      schemaVersion.hashCode ^
      exportedAt.hashCode ^
      totalCategories.hashCode ^
      newCategories.hashCode ^
      duplicateCategories.hashCode ^
      totalSubscriptions.hashCode ^
      newSubscriptions.hashCode ^
      duplicateSubscriptions.hashCode ^
      totalPriceHistories.hashCode;

  @override
  String toString() =>
      'BackupPreview(v$schemaVersion, categories: $totalCategories (+$newCategories/=$duplicateCategories), subscriptions: $totalSubscriptions (+$newSubscriptions/=$duplicateSubscriptions), priceHistory: $totalPriceHistories)';
}

/// The chosen strategy when importing a backup.
enum ImportStrategy {
  /// Appends new records and skips identical/duplicate records without modifying existing data.
  merge,

  /// Completely wipes existing non-system user records and substitutes them with backup records atomically.
  replace,
}

/// Results of a successfully completed import operation.
class ImportResult {
  final int importedCategories;
  final int importedSubscriptions;
  final int importedPriceHistories;
  final ImportStrategy strategy;

  const ImportResult({
    required this.importedCategories,
    required this.importedSubscriptions,
    required this.importedPriceHistories,
    required this.strategy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportResult &&
          runtimeType == other.runtimeType &&
          importedCategories == other.importedCategories &&
          importedSubscriptions == other.importedSubscriptions &&
          importedPriceHistories == other.importedPriceHistories &&
          strategy == other.strategy;

  @override
  int get hashCode =>
      importedCategories.hashCode ^
      importedSubscriptions.hashCode ^
      importedPriceHistories.hashCode ^
      strategy.hashCode;

  @override
  String toString() =>
      'ImportResult(importedCategories: $importedCategories, importedSubscriptions: $importedSubscriptions, importedPriceHistories: $importedPriceHistories, strategy: $strategy)';
}

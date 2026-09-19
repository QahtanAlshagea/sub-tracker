import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

/// Data Access Object for application settings and user preferences.
///
/// Implements typed queries, reactive streams, and upsert operations for the
/// singleton settings record according to ARCHITECTURE.md §3.2.4.
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Retrieves the application settings singleton row.
  Future<Setting?> getSettings() {
    return (select(
      settings,
    )..where((tbl) => tbl.id.equals(kDefaultSettingsId))).getSingleOrNull();
  }

  /// Emits a stream of the application settings singleton row.
  Stream<Setting?> watchSettings() {
    return (select(
      settings,
    )..where((tbl) => tbl.id.equals(kDefaultSettingsId))).watchSingleOrNull();
  }

  /// Upserts the application settings record.
  Future<int> upsertSettings(SettingsCompanion companion) {
    return into(settings).insertOnConflictUpdate(companion);
  }

  /// Updates the last backup export timestamp and sets updatedAt to now.
  Future<int> updateBackupTimestamp(DateTime backupTime) {
    return (update(
      settings,
    )..where((tbl) => tbl.id.equals(kDefaultSettingsId))).write(
      SettingsCompanion(
        lastBackupAt: Value(backupTime),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Updates the UI theme mode ('system', 'light', 'dark').
  Future<int> updateThemeMode(String themeMode) {
    return (update(
      settings,
    )..where((tbl) => tbl.id.equals(kDefaultSettingsId))).write(
      SettingsCompanion(
        themeMode: Value(themeMode),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Updates the default currency for new subscriptions.
  Future<int> updateDefaultCurrency(String currencyCode) {
    return (update(
      settings,
    )..where((tbl) => tbl.id.equals(kDefaultSettingsId))).write(
      SettingsCompanion(
        defaultCurrency: Value(currencyCode),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}

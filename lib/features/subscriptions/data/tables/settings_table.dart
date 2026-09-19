import 'package:drift/drift.dart';

/// Application settings and preferences table schema.
///
/// Stores user global settings in a singleton record (`id = 'app_settings'`).
/// Implements ARCHITECTURE.md §3.2.4.
class Settings extends Table {
  /// Singleton record key, always 'app_settings'.
  TextColumn get id => text().withDefault(const Constant('app_settings'))();

  /// UI theme mode ('system', 'light', 'dark').
  TextColumn get themeMode =>
      text().named('theme_mode').withDefault(const Constant('system'))();

  /// Default ISO 4217 currency code for new subscriptions.
  TextColumn get defaultCurrency => text()
      .named('default_currency')
      .withLength(min: 3, max: 3)
      .withDefault(const Constant('USD'))();

  /// Default reminder lead time in days (0 to 30).
  IntColumn get defaultReminderDays =>
      integer().named('default_reminder_days').withDefault(const Constant(1))();

  /// Default reminder trigger hour (0 to 23).
  IntColumn get defaultReminderHour =>
      integer().named('default_reminder_hour').withDefault(const Constant(9))();

  /// Default reminder trigger minute (0 to 59).
  IntColumn get defaultReminderMinute => integer()
      .named('default_reminder_minute')
      .withDefault(const Constant(0))();

  /// Default subscription sort ordering identifier.
  TextColumn get defaultSortOrder => text()
      .named('default_sort_order')
      .withDefault(const Constant('due_date_asc'))();

  /// Timestamp of the last successful backup export, or null if never exported.
  DateTimeColumn get lastBackupAt =>
      dateTime().named('last_backup_at').nullable()();

  /// Recorded schema version for consistency verification.
  IntColumn get schemaVersion =>
      integer().named('schema_version').withDefault(const Constant(2))();

  /// Timestamp of the last settings update in UTC.
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (default_reminder_days >= 0 AND default_reminder_days <= 30)',
    'CHECK (default_reminder_hour >= 0 AND default_reminder_hour <= 23)',
    'CHECK (default_reminder_minute >= 0 AND default_reminder_minute <= 59)',
  ];
}

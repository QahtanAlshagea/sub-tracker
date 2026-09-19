import 'package:drift/drift.dart';
import 'categories_table.dart';

/// Subscriptions table schema.
///
/// Central table for all subscription records, recurrence rules, and notification metadata.
/// Implements ARCHITECTURE.md §3.2.2 and §3.4.
@TableIndex(name: 'idx_subscriptions_due_date', columns: {#nextDueDate})
@TableIndex(name: 'idx_subscriptions_category_id', columns: {#categoryId})
@TableIndex(name: 'idx_subscriptions_status', columns: {#status})
@TableIndex(
  name: 'idx_subscriptions_dup_check',
  columns: {#name, #cycleType, #nextDueDate},
)
class Subscriptions extends Table {
  /// Unique identifier (UUID v4).
  TextColumn get id => text()();

  /// Normalized subscription name (1 to 60 chars).
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Amount in integer minor units (non-negative).
  IntColumn get priceMinorUnits => integer().named('price_minor_units')();

  /// 3-letter ISO 4217 uppercase currency code.
  TextColumn get currencyCode =>
      text().named('currency_code').withLength(min: 3, max: 3)();

  /// Recurrence cycle type ('monthly', 'yearly', 'weekly', 'custom').
  TextColumn get cycleType => text().named('cycle_type')();

  /// Custom recurrence interval in days (1 to 3650, null if not custom).
  IntColumn get customCycleDays =>
      integer().named('custom_cycle_days').nullable()();

  /// Initial start date in UTC.
  DateTimeColumn get startDate => dateTime().named('start_date')();

  /// Next calculated due date in UTC.
  DateTimeColumn get nextDueDate => dateTime().named('next_due_date')();

  /// Original anchor day of month (1 to 31) for preserving day across months.
  IntColumn get originalAnchorDay => integer().named('original_anchor_day')();

  /// Foreign key referencing Categories(id) with RESTRICT on delete.
  TextColumn get categoryId => text()
      .named('category_id')
      .references(Categories, #id, onDelete: KeyAction.restrict)();

  /// Lifecycle status ('active', 'archived', 'in_trash').
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Flag indicating if the subscription is currently a free trial.
  BoolColumn get isTrial =>
      boolean().named('is_trial').withDefault(const Constant(false))();

  /// Optional notes (max 500 characters).
  TextColumn get notes => text().withLength(max: 500).nullable()();

  /// Optional renewal/management URL.
  TextColumn get renewalUrl => text().named('renewal_url').nullable()();

  /// Optional payment method description (max 50 characters).
  TextColumn get paymentMethodDesc =>
      text().named('payment_method_desc').withLength(max: 50).nullable()();

  /// Whether local reminders are enabled.
  BoolColumn get reminderEnabled =>
      boolean().named('reminder_enabled').withDefault(const Constant(true))();

  /// Days before due date to notify (0 to 30).
  IntColumn get reminderLeadDays =>
      integer().named('reminder_lead_days').withDefault(const Constant(1))();

  /// Notification trigger hour (0 to 23).
  IntColumn get reminderTimeHour =>
      integer().named('reminder_time_hour').withDefault(const Constant(9))();

  /// Notification trigger minute (0 to 59).
  IntColumn get reminderTimeMinute =>
      integer().named('reminder_time_minute').withDefault(const Constant(0))();

  /// Record creation timestamp in UTC.
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// Record last update timestamp in UTC.
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  /// Soft deletion timestamp in UTC (null if not in trash).
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  /// Archival timestamp in UTC (null if not archived).
  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (price_minor_units >= 0)',
    'CHECK (custom_cycle_days IS NULL OR (custom_cycle_days >= 1 AND custom_cycle_days <= 3650))',
    'CHECK (original_anchor_day >= 1 AND original_anchor_day <= 31)',
    'CHECK (reminder_lead_days >= 0 AND reminder_lead_days <= 30)',
    'CHECK (reminder_time_hour >= 0 AND reminder_time_hour <= 23)',
    'CHECK (reminder_time_minute >= 0 AND reminder_time_minute <= 59)',
  ];
}

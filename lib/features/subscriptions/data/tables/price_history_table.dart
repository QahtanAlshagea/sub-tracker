import 'package:drift/drift.dart';
import 'subscriptions_table.dart';

/// Price history table schema.
///
/// Tracks price modifications over time for each subscription (US-06, FR-05).
/// Implements ARCHITECTURE.md §3.2.3 and §3.4.
@TableIndex(
  name: 'idx_price_history_sub',
  columns: {#subscriptionId, #changedAt},
)
class PriceHistory extends Table {
  /// Unique identifier (UUID v4).
  TextColumn get id => text()();

  /// Foreign key referencing Subscriptions(id) with CASCADE on delete.
  TextColumn get subscriptionId => text()
      .named('subscription_id')
      .references(Subscriptions, #id, onDelete: KeyAction.cascade)();

  /// Previous amount in integer minor units (non-negative).
  IntColumn get oldPriceMinorUnits =>
      integer().named('old_price_minor_units')();

  /// New amount in integer minor units (non-negative).
  IntColumn get newPriceMinorUnits =>
      integer().named('new_price_minor_units')();

  /// 3-letter ISO 4217 uppercase currency code.
  TextColumn get currencyCode =>
      text().named('currency_code').withLength(min: 3, max: 3)();

  /// Effective timestamp of price change in UTC.
  DateTimeColumn get changedAt => dateTime().named('changed_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (old_price_minor_units >= 0)',
    'CHECK (new_price_minor_units >= 0)',
  ];
}

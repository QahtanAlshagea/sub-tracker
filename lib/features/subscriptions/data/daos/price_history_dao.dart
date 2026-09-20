import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../tables/price_history_table.dart';

part 'price_history_dao.g.dart';

/// Data Access Object for price history tracking.
///
/// Implements typed queries, insertion, and reactive streams for historical price
/// changes ordered by timestamp descending according to ARCHITECTURE.md §3.4.
@DriftAccessor(tables: [PriceHistory])
class PriceHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$PriceHistoryDaoMixin {
  PriceHistoryDao(super.db);

  /// Retrieves the price change history for a given [subscriptionId],
  /// ordered from newest to oldest using idx_price_history_sub.
  Future<List<PriceHistoryData>> getHistoryForSubscription(
    String subscriptionId,
  ) {
    return (select(priceHistory)
          ..where((tbl) => tbl.subscriptionId.equals(subscriptionId))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.changedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Emits a stream of price history changes for [subscriptionId],
  /// ordered from newest to oldest.
  Stream<List<PriceHistoryData>> watchHistoryForSubscription(
    String subscriptionId,
  ) {
    return (select(priceHistory)
          ..where((tbl) => tbl.subscriptionId.equals(subscriptionId))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.changedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  /// Inserts a new historical price change entry.
  Future<int> insertPriceHistory(PriceHistoryCompanion companion) {
    return into(priceHistory).insert(companion);
  }

  /// Deletes all price history records for a specific [subscriptionId].
  Future<int> deleteHistoryForSubscription(String subscriptionId) {
    return (delete(
      priceHistory,
    )..where((tbl) => tbl.subscriptionId.equals(subscriptionId))).go();
  }

  /// Deletes an individual price history entry by its [id].
  Future<int> deleteHistoryEntry(String id) {
    return (delete(priceHistory)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Retrieves all price history records across all subscriptions.
  Future<List<PriceHistoryData>> getAllHistory() {
    return select(priceHistory).get();
  }
}

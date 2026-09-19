import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../tables/price_history_table.dart';
import '../tables/subscriptions_table.dart';

part 'subscription_dao.g.dart';

/// Data Access Object for subscription persistence operations.
///
/// Implements typed queries, reactive streams, filtering, sorting, and atomic
/// multi-row transactions according to ARCHITECTURE.md §3.3 and §3.4.
@DriftAccessor(tables: [Subscriptions, PriceHistory])
class SubscriptionDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionDaoMixin {
  SubscriptionDao(super.db);

  /// Retrieves a subscription by its unique [id].
  Future<Subscription?> getSubscriptionById(String id) {
    return (select(
      subscriptions,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves subscriptions with optional filtering by [status], [categoryId],
  /// and search by [searchKeyword].
  ///
  /// Ordered by next_due_date ASC utilizing idx_subscriptions_due_date.
  Future<List<Subscription>> getAllSubscriptions({
    String? status,
    String? categoryId,
    String? searchKeyword,
  }) {
    final query = select(subscriptions);

    if (status != null) {
      query.where((tbl) => tbl.status.equals(status));
    }
    if (categoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }
    if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
      final pattern = '%${searchKeyword.trim()}%';
      query.where((tbl) => tbl.name.like(pattern));
    }

    query.orderBy([
      (tbl) =>
          OrderingTerm(expression: tbl.nextDueDate, mode: OrderingMode.asc),
    ]);

    return query.get();
  }

  /// Emits a reactive stream of subscriptions matching [status] and [categoryId].
  Stream<List<Subscription>> watchAllSubscriptions({
    String? status,
    String? categoryId,
  }) {
    final query = select(subscriptions);

    if (status != null) {
      query.where((tbl) => tbl.status.equals(status));
    }
    if (categoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }

    query.orderBy([
      (tbl) =>
          OrderingTerm(expression: tbl.nextDueDate, mode: OrderingMode.asc),
    ]);

    return query.watch();
  }

  /// Inserts a new subscription.
  Future<int> insertSubscription(SubscriptionsCompanion companion) {
    return into(subscriptions).insert(companion);
  }

  /// Updates an existing subscription.
  Future<bool> updateSubscription(SubscriptionsCompanion companion) async {
    final updated = await (update(
      subscriptions,
    )..where((tbl) => tbl.id.equals(companion.id.value))).write(companion);
    return updated > 0;
  }

  /// Permanently deletes a subscription by [id].
  ///
  /// Automatically cascades deletion to price_history table via foreign key action.
  Future<int> deleteSubscriptionPermanently(String id) {
    return (delete(subscriptions)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Updates the lifecycle status of a subscription with proper timestamps.
  Future<int> updateStatus(
    String id,
    String newStatus, {
    DateTime? deletedAt,
    DateTime? archivedAt,
  }) {
    return (update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        status: Value(newStatus),
        deletedAt: Value(deletedAt),
        archivedAt: Value(archivedAt),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Advances the [nextDueDate] of a subscription and updates the [updatedAt] timestamp.
  Future<int> renewSubscription(String id, DateTime newDueDate) {
    return (update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        nextDueDate: Value(newDueDate),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Atomically updates a subscription's price and records a new entry in price_history.
  ///
  /// Enforces all-or-nothing execution: if either update or insertion fails,
  /// both operations are rolled back completely.
  Future<void> updateSubscriptionPriceWithHistory({
    required SubscriptionsCompanion subscriptionCompanion,
    required PriceHistoryCompanion priceHistoryCompanion,
  }) {
    return transaction(() async {
      final updated = await update(
        subscriptions,
      ).replace(subscriptionCompanion);
      if (!updated) {
        throw StateError(
          'Failed to update subscription ${subscriptionCompanion.id.value}: record not found.',
        );
      }
      await into(priceHistory).insert(priceHistoryCompanion);
    });
  }

  /// Atomically marks a list of subscriptions as moved to trash (EC-40).
  Future<void> bulkMoveToTrash(List<String> ids, DateTime deletedAt) {
    return transaction(() async {
      final nowUtc = DateTime.now().toUtc();
      for (final id in ids) {
        await (update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
          SubscriptionsCompanion(
            status: const Value('in_trash'),
            deletedAt: Value(deletedAt),
            updatedAt: Value(nowUtc),
          ),
        );
      }
    });
  }

  /// Atomically restores a list of subscriptions from trash to active (EC-40).
  Future<void> bulkRestoreFromTrash(List<String> ids) {
    return transaction(() async {
      final nowUtc = DateTime.now().toUtc();
      for (final id in ids) {
        await (update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
          SubscriptionsCompanion(
            status: const Value('active'),
            deletedAt: const Value(null),
            updatedAt: Value(nowUtc),
          ),
        );
      }
    });
  }

  /// Atomically archives a list of subscriptions (EC-40).
  Future<void> bulkArchive(List<String> ids, DateTime archivedAt) {
    return transaction(() async {
      final nowUtc = DateTime.now().toUtc();
      for (final id in ids) {
        await (update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
          SubscriptionsCompanion(
            status: const Value('archived'),
            archivedAt: Value(archivedAt),
            updatedAt: Value(nowUtc),
          ),
        );
      }
    });
  }

  /// Atomically unarchives a list of subscriptions to active (EC-40).
  Future<void> bulkUnarchive(List<String> ids) {
    return transaction(() async {
      final nowUtc = DateTime.now().toUtc();
      for (final id in ids) {
        await (update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
          SubscriptionsCompanion(
            status: const Value('active'),
            archivedAt: const Value(null),
            updatedAt: Value(nowUtc),
          ),
        );
      }
    });
  }

  /// Atomically permanently deletes a list of subscriptions (EC-40).
  Future<void> bulkPermanentDelete(List<String> ids) {
    return transaction(() async {
      await (delete(subscriptions)..where((tbl) => tbl.id.isIn(ids))).go();
    });
  }

  /// Atomically purges all subscriptions currently in trash.
  Future<int> purgeAllTrash() {
    return transaction(() async {
      return (delete(
        subscriptions,
      )..where((tbl) => tbl.status.equals('in_trash'))).go();
    });
  }

  /// Reassigns all subscriptions pointing to [fromCategoryId] to [toCategoryId].
  Future<int> reassignCategory(String fromCategoryId, String toCategoryId) {
    return (update(
      subscriptions,
    )..where((tbl) => tbl.categoryId.equals(fromCategoryId))).write(
      SubscriptionsCompanion(
        categoryId: Value(toCategoryId),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}

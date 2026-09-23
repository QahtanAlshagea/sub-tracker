import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../daos/subscription_dao.dart';
import '../models/subscription_model.dart';

/// Contract for subscription persistence at the local data source level.
abstract class SubscriptionLocalDataSource {
  /// Inserts a new subscription into SQLite via DAO and returns the persisted model.
  Future<SubscriptionModel> createSubscription(SubscriptionModel model);

  /// Updates an existing subscription record and returns the updated model.
  Future<SubscriptionModel> updateSubscription(SubscriptionModel model);

  /// Retrieves a subscription by its unique [id], or null if not found.
  Future<SubscriptionModel?> getSubscriptionById(String id);

  /// Retrieves all subscriptions matching optional [status], [categoryId], and [searchKeyword].
  Future<List<SubscriptionModel>> getAllSubscriptions({
    String? status,
    String? categoryId,
    String? searchKeyword,
  });

  /// Watches subscriptions matching optional [status] and [categoryId] as a reactive stream.
  Stream<List<SubscriptionModel>> watchSubscriptions({
    String? status,
    String? categoryId,
  });

  /// Transitions a subscription to archived status with current UTC timestamp.
  Future<void> archiveSubscription(String id);

  /// Transitions an archived subscription back to active status.
  Future<void> unarchiveSubscription(String id);

  /// Moves a subscription to trash with current UTC deletion timestamp.
  Future<void> moveToTrash(String id);

  /// Restores a subscription from trash back to active status.
  Future<void> restoreFromTrash(String id);

  /// Permanently removes a subscription and cascades to price history.
  Future<void> permanentlyDeleteSubscription(String id);

  /// Atomically purges all subscriptions currently in the trash.
  Future<void> emptyTrash();
}

/// Concrete implementation of [SubscriptionLocalDataSource] using Drift's [SubscriptionDao].
class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final SubscriptionDao _subscriptionDao;

  const SubscriptionLocalDataSourceImpl(this._subscriptionDao);

  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel model) async {
    final companion = model.toCompanion(forInsert: true);
    await _subscriptionDao.insertSubscription(companion);
    final persisted = await _subscriptionDao.getSubscriptionById(model.id);
    return SubscriptionModel.fromData(persisted!);
  }

  @override
  Future<SubscriptionModel> updateSubscription(SubscriptionModel model) async {
    final existing = await _subscriptionDao.getSubscriptionById(model.id);
    if (existing != null &&
        (existing.priceMinorUnits != model.priceMinorUnits ||
            existing.currencyCode != model.currencyCode)) {
      // Record old price in PriceHistory automatically
      final historyCompanion = PriceHistoryCompanion.insert(
        id: const Uuid().v4(),
        subscriptionId: model.id,
        oldPriceMinorUnits: existing.priceMinorUnits,
        newPriceMinorUnits: model.priceMinorUnits,
        currencyCode: model.currencyCode,
        changedAt: DateTime.now().toUtc(),
      );
      await _subscriptionDao.updateSubscriptionPriceWithHistory(
        subscriptionCompanion: model.toCompanion(),
        priceHistoryCompanion: historyCompanion,
      );
    } else {
      final companion = model.toCompanion();
      await _subscriptionDao.updateSubscription(companion);
    }
    final updated = await _subscriptionDao.getSubscriptionById(model.id);
    return SubscriptionModel.fromData(updated!);
  }

  @override
  Future<SubscriptionModel?> getSubscriptionById(String id) async {
    final data = await _subscriptionDao.getSubscriptionById(id);
    if (data == null) return null;
    return SubscriptionModel.fromData(data);
  }

  @override
  Future<List<SubscriptionModel>> getAllSubscriptions({
    String? status,
    String? categoryId,
    String? searchKeyword,
  }) async {
    final list = await _subscriptionDao.getAllSubscriptions(
      status: status,
      categoryId: categoryId,
      searchKeyword: searchKeyword,
    );
    return list.map(SubscriptionModel.fromData).toList();
  }

  @override
  Stream<List<SubscriptionModel>> watchSubscriptions({
    String? status,
    String? categoryId,
  }) {
    return _subscriptionDao
        .watchAllSubscriptions(status: status, categoryId: categoryId)
        .map((list) => list.map(SubscriptionModel.fromData).toList());
  }

  @override
  Future<void> archiveSubscription(String id) {
    return _subscriptionDao.updateStatus(
      id,
      'archived',
      archivedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> unarchiveSubscription(String id) {
    return _subscriptionDao.updateStatus(id, 'active', archivedAt: null);
  }

  @override
  Future<void> moveToTrash(String id) {
    return _subscriptionDao.updateStatus(
      id,
      'in_trash',
      deletedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> restoreFromTrash(String id) {
    return _subscriptionDao.updateStatus(id, 'active', deletedAt: null);
  }

  @override
  Future<void> permanentlyDeleteSubscription(String id) async {
    await _subscriptionDao.deleteSubscriptionPermanently(id);
  }

  @override
  Future<void> emptyTrash() {
    return _subscriptionDao.purgeAllTrash();
  }
}

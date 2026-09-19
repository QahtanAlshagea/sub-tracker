// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_history_dao.dart';

// ignore_for_file: type=lint
mixin _$PriceHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $SubscriptionsTable get subscriptions => attachedDatabase.subscriptions;
  $PriceHistoryTable get priceHistory => attachedDatabase.priceHistory;
  PriceHistoryDaoManager get managers => PriceHistoryDaoManager(this);
}

class PriceHistoryDaoManager {
  final _$PriceHistoryDaoMixin _db;
  PriceHistoryDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db.attachedDatabase, _db.subscriptions);
  $$PriceHistoryTableTableManager get priceHistory =>
      $$PriceHistoryTableTableManager(_db.attachedDatabase, _db.priceHistory);
}

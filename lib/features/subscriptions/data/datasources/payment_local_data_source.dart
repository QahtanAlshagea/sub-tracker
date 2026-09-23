import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/value_objects/money.dart';

/// Contract for payment records persistence at the local data source level.
abstract class PaymentLocalDataSource {
  Future<void> recordPayment(PaymentRecord record);
  Future<List<PaymentRecord>> getPaymentHistory(String subscriptionId);
  Future<int> getPaymentCount(String subscriptionId);
  Future<Map<String, int>> getAllPaymentCounts();
}

/// Concrete implementation of [PaymentLocalDataSource] using SQLite statements on [AppDatabase].
class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final AppDatabase _database;
  bool _tableInitialized = false;

  PaymentLocalDataSourceImpl(this._database);

  Future<void> _ensureTable() async {
    if (_tableInitialized) return;
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS payment_records (
        id TEXT PRIMARY KEY,
        subscription_id TEXT NOT NULL,
        amount_minor_units INTEGER NOT NULL,
        currency_code TEXT NOT NULL,
        paid_at INTEGER NOT NULL,
        cycle_type TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE
      );
    ''');
    await _database.customStatement('''
      CREATE INDEX IF NOT EXISTS idx_payment_records_sub 
      ON payment_records (subscription_id, paid_at DESC);
    ''');
    _tableInitialized = true;
  }

  @override
  Future<void> recordPayment(PaymentRecord record) async {
    await _ensureTable();
    await _database.customStatement(
      '''
      INSERT INTO payment_records (
        id, subscription_id, amount_minor_units, currency_code, paid_at, cycle_type, note
      ) VALUES (?, ?, ?, ?, ?, ?, ?);
    ''',
      [
        record.id,
        record.subscriptionId,
        record.amount.amountMinorUnits,
        record.amount.currencyCode,
        record.paidAt.millisecondsSinceEpoch,
        record.cycleType,
        record.note,
      ],
    );
  }

  @override
  Future<List<PaymentRecord>> getPaymentHistory(String subscriptionId) async {
    await _ensureTable();
    final rows = await _database
        .customSelect(
          '''
      SELECT id, subscription_id, amount_minor_units, currency_code, paid_at, cycle_type, note
      FROM payment_records
      WHERE subscription_id = ?
      ORDER BY paid_at DESC;
    ''',
          variables: [Variable.withString(subscriptionId)],
        )
        .get();

    return rows.map((row) {
      return PaymentRecord(
        id: row.read<String>('id'),
        subscriptionId: row.read<String>('subscription_id'),
        amount: Money.create(
          amountMinorUnits: row.read<int>('amount_minor_units'),
          currencyCode: row.read<String>('currency_code'),
        ),
        paidAt: DateTime.fromMillisecondsSinceEpoch(
          row.read<int>('paid_at'),
          isUtc: true,
        ),
        cycleType: row.read<String>('cycle_type'),
        note: row.readNullable<String>('note'),
      );
    }).toList();
  }

  @override
  Future<int> getPaymentCount(String subscriptionId) async {
    await _ensureTable();
    final rows = await _database
        .customSelect(
          '''
      SELECT COUNT(*) as count
      FROM payment_records
      WHERE subscription_id = ?;
    ''',
          variables: [Variable.withString(subscriptionId)],
        )
        .get();

    if (rows.isEmpty) return 0;
    return rows.first.read<int>('count');
  }

  @override
  Future<Map<String, int>> getAllPaymentCounts() async {
    await _ensureTable();
    final rows = await _database.customSelect('''
      SELECT subscription_id, COUNT(*) as count
      FROM payment_records
      GROUP BY subscription_id;
    ''').get();

    final map = <String, int>{};
    for (final row in rows) {
      map[row.read<String>('subscription_id')] = row.read<int>('count');
    }
    return map;
  }
}

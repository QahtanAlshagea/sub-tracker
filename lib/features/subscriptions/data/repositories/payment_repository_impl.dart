import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_data_source.dart';

/// Implementation of [PaymentRepository] interacting with [PaymentLocalDataSource].
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource _dataSource;

  const PaymentRepositoryImpl(this._dataSource);

  @override
  Future<Result<void>> recordPayment(PaymentRecord record) async {
    try {
      await _dataSource.recordPayment(record);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to record payment: $e'));
    }
  }

  @override
  Future<Result<List<PaymentRecord>>> getPaymentHistory(
    String subscriptionId,
  ) async {
    try {
      final records = await _dataSource.getPaymentHistory(subscriptionId);
      return Success(records);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load payment history: $e'));
    }
  }

  @override
  Future<Result<int>> getPaymentCount(String subscriptionId) async {
    try {
      final count = await _dataSource.getPaymentCount(subscriptionId);
      return Success(count);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load payment count: $e'));
    }
  }

  @override
  Future<Result<Map<String, int>>> getAllPaymentCounts() async {
    try {
      final map = await _dataSource.getAllPaymentCounts();
      return Success(map);
    } catch (e) {
      return Error(DatabaseFailure('Failed to load payment counts: $e'));
    }
  }
}

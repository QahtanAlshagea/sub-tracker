import '../../../../core/utils/result.dart';
import '../entities/payment_record.dart';

/// Repository interface for payment history and settlement records.
///
/// Complies with Clean Architecture and Interface Segregation Principle (ISP).
/// Implements [FR-11] and [US-28].
abstract class PaymentRepository {
  /// Records a new payment entry in persistent storage.
  Future<Result<void>> recordPayment(PaymentRecord record);

  /// Retrieves the chronological payment history for a given subscription.
  Future<Result<List<PaymentRecord>>> getPaymentHistory(String subscriptionId);

  /// Retrieves the total number of recorded payments for a given subscription.
  Future<Result<int>> getPaymentCount(String subscriptionId);

  /// Retrieves a map of subscriptionId -> total payment counts.
  Future<Result<Map<String, int>>> getAllPaymentCounts();
}

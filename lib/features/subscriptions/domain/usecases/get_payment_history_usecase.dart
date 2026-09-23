import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/payment_record.dart';
import '../repositories/payment_repository.dart';

/// Use case for retrieving the payment history of a subscription.
///
/// Implements [FR-11] and [US-28].
class GetPaymentHistoryUseCase implements UseCase<List<PaymentRecord>, String> {
  final PaymentRepository _paymentRepository;

  const GetPaymentHistoryUseCase(this._paymentRepository);

  @override
  Future<Result<List<PaymentRecord>>> call(String subscriptionId) {
    return _paymentRepository.getPaymentHistory(subscriptionId);
  }
}

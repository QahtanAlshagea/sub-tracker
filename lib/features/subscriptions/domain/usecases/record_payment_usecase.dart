import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/payment_record.dart';
import '../repositories/payment_repository.dart';

/// Use case for recording a payment transaction for a subscription.
///
/// Implements [FR-11] and [US-28].
class RecordPaymentUseCase implements UseCase<void, PaymentRecord> {
  final PaymentRepository _paymentRepository;

  const RecordPaymentUseCase(this._paymentRepository);

  @override
  Future<Result<void>> call(PaymentRecord record) {
    return _paymentRepository.recordPayment(record);
  }
}

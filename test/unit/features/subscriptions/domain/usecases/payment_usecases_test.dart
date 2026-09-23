import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/payment_record.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/payment_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_payment_history_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/record_payment_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

class MockPaymentRepository implements PaymentRepository {
  final List<PaymentRecord> records = [];

  @override
  Future<Result<void>> recordPayment(PaymentRecord record) async {
    records.add(record);
    return const Success(null);
  }

  @override
  Future<Result<List<PaymentRecord>>> getPaymentHistory(
    String subscriptionId,
  ) async {
    final filtered = records
        .where((r) => r.subscriptionId == subscriptionId)
        .toList();
    return Success(filtered);
  }

  @override
  Future<Result<int>> getPaymentCount(String subscriptionId) async {
    final count = records
        .where((r) => r.subscriptionId == subscriptionId)
        .length;
    return Success(count);
  }

  @override
  Future<Result<Map<String, int>>> getAllPaymentCounts() async {
    final map = <String, int>{};
    for (final r in records) {
      map[r.subscriptionId] = (map[r.subscriptionId] ?? 0) + 1;
    }
    return Success(map);
  }
}

void main() {
  group('Payment UseCases Unit Tests', () {
    late MockPaymentRepository repository;
    late RecordPaymentUseCase recordPaymentUseCase;
    late GetPaymentHistoryUseCase getPaymentHistoryUseCase;

    setUp(() {
      repository = MockPaymentRepository();
      recordPaymentUseCase = RecordPaymentUseCase(repository);
      getPaymentHistoryUseCase = GetPaymentHistoryUseCase(repository);
    });

    test(
      'RecordPaymentUseCase successfully appends a new payment record',
      () async {
        final record = PaymentRecord(
          id: 'pay-1',
          subscriptionId: 'sub-1',
          amount: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
          paidAt: DateTime.utc(2026, 9, 22),
          cycleType: 'monthly',
        );

        final result = await recordPaymentUseCase(record);

        expect(result.isSuccess, isTrue);
        expect(repository.records.length, equals(1));
        expect(repository.records.first.id, equals('pay-1'));
        expect(repository.records.first.amount.amountMinorUnits, equals(1500));
      },
    );

    test(
      'GetPaymentHistoryUseCase returns payments sorted for a given subscription',
      () async {
        final record1 = PaymentRecord(
          id: 'pay-1',
          subscriptionId: 'sub-1',
          amount: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          paidAt: DateTime.utc(2026, 8, 1),
          cycleType: 'monthly',
        );
        final record2 = PaymentRecord(
          id: 'pay-2',
          subscriptionId: 'sub-1',
          amount: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          paidAt: DateTime.utc(2026, 9, 1),
          cycleType: 'monthly',
        );
        final recordOther = PaymentRecord(
          id: 'pay-3',
          subscriptionId: 'sub-2',
          amount: Money.create(amountMinorUnits: 500, currencyCode: 'USD'),
          paidAt: DateTime.utc(2026, 9, 15),
          cycleType: 'monthly',
        );

        await recordPaymentUseCase(record1);
        await recordPaymentUseCase(record2);
        await recordPaymentUseCase(recordOther);

        final historyResult = await getPaymentHistoryUseCase('sub-1');

        expect(historyResult.isSuccess, isTrue);
        final history = historyResult.dataOrNull!;
        expect(history.length, equals(2));
        expect(history.map((e) => e.id), containsAll(['pay-1', 'pay-2']));
        expect(history.map((e) => e.id), isNot(contains('pay-3')));
      },
    );

    test(
      'getAllPaymentCounts returns accurate aggregates for subscriptions',
      () async {
        final record1 = PaymentRecord(
          id: 'pay-1',
          subscriptionId: 'sub-1',
          amount: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          paidAt: DateTime.utc(2026, 8, 1),
          cycleType: 'monthly',
        );
        final record2 = PaymentRecord(
          id: 'pay-2',
          subscriptionId: 'sub-1',
          amount: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          paidAt: DateTime.utc(2026, 9, 1),
          cycleType: 'monthly',
        );

        await recordPaymentUseCase(record1);
        await recordPaymentUseCase(record2);

        final countsResult = await repository.getAllPaymentCounts();
        expect(countsResult.isSuccess, isTrue);
        expect(countsResult.dataOrNull!['sub-1'], equals(2));
        expect(countsResult.dataOrNull!['sub-2'], isNull);
      },
    );
  });
}

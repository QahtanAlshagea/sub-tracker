import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/data/datasources/security_local_data_source.dart';
import 'package:sub_tracker/features/subscriptions/data/repositories/security_repository_impl.dart';

class FakeSecurityLocalDataSource implements SecurityLocalDataSource {
  bool _enabled = false;
  String? _hash;

  @override
  Future<bool> isPinEnabled() async => _enabled;

  @override
  Future<String?> getPinHash() async => _hash;

  @override
  Future<void> setPinHash(String hash) async {
    _hash = hash;
    _enabled = true;
  }

  @override
  Future<void> disablePin() async {
    _hash = null;
    _enabled = false;
  }
}

void main() {
  group('SecurityRepositoryImpl Tests', () {
    late FakeSecurityLocalDataSource localDataSource;
    late SecurityRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeSecurityLocalDataSource();
      repository = SecurityRepositoryImpl(localDataSource);
    });

    test('isPinEnabled returns false initially', () async {
      final res = await repository.isPinEnabled();
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull, isFalse);
    });

    test('setPin updates hash and enables PIN', () async {
      final setRes = await repository.setPin('1234');
      expect(setRes.isSuccess, isTrue);

      final isEnabled = await repository.isPinEnabled();
      expect(isEnabled.dataOrNull, isTrue);

      final verifyRes = await repository.verifyPin('1234');
      expect(verifyRes.dataOrNull, isTrue);

      final wrongPinRes = await repository.verifyPin('9999');
      expect(wrongPinRes.dataOrNull, isFalse);
    });

    test('setPin rejects invalid PIN', () async {
      final setRes = await repository.setPin('12');
      expect(setRes.isFailure, isTrue);
    });

    test('disablePin clears PIN', () async {
      await repository.setPin('4321');
      final disableRes = await repository.disablePin();
      expect(disableRes.isSuccess, isTrue);

      final isEnabled = await repository.isPinEnabled();
      expect(isEnabled.dataOrNull, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/usecase/usecase.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/security_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/disable_pin_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/is_pin_enabled_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/set_pin_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/verify_pin_usecase.dart';

class FakeSecurityRepository implements SecurityRepository {
  bool _enabled = false;
  String? _pin;

  @override
  Future<Result<bool>> isPinEnabled() async {
    return Result.success(_enabled);
  }

  @override
  Future<Result<bool>> verifyPin(String candidatePin) async {
    return Result.success(_enabled && _pin == candidatePin);
  }

  @override
  Future<Result<void>> setPin(String newPin) async {
    _pin = newPin;
    _enabled = true;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> disablePin() async {
    _pin = null;
    _enabled = false;
    return const Result.success(null);
  }
}

void main() {
  group('Security PIN UseCases Tests', () {
    late FakeSecurityRepository repository;
    late IsPinEnabledUseCase isPinEnabledUseCase;
    late SetPinUseCase setPinUseCase;
    late VerifyPinUseCase verifyPinUseCase;
    late DisablePinUseCase disablePinUseCase;

    setUp(() {
      repository = FakeSecurityRepository();
      isPinEnabledUseCase = IsPinEnabledUseCase(repository);
      setPinUseCase = SetPinUseCase(repository);
      verifyPinUseCase = VerifyPinUseCase(repository);
      disablePinUseCase = DisablePinUseCase(repository);
    });

    test('initial state has PIN disabled', () async {
      final res = await isPinEnabledUseCase(const NoParams());
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull, isFalse);
    });

    test('setting valid PIN enables PIN and verifies correctly', () async {
      final setResult = await setPinUseCase('1234');
      expect(setResult.isSuccess, isTrue);

      final isEnabled = await isPinEnabledUseCase(const NoParams());
      expect(isEnabled.dataOrNull, isTrue);

      final verifyCorrect = await verifyPinUseCase('1234');
      expect(verifyCorrect.dataOrNull, isTrue);

      final verifyWrong = await verifyPinUseCase('0000');
      expect(verifyWrong.dataOrNull, isFalse);
    });

    test('setting invalid PIN returns validation failure', () async {
      final setResult = await setPinUseCase('12');
      expect(setResult.isFailure, isTrue);
    });

    test('disabling PIN clears security lock', () async {
      await setPinUseCase('5678');
      final disableResult = await disablePinUseCase(const NoParams());
      expect(disableResult.isSuccess, isTrue);

      final isEnabled = await isPinEnabledUseCase(const NoParams());
      expect(isEnabled.dataOrNull, isFalse);
    });
  });
}

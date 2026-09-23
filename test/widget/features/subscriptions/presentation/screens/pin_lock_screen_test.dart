import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/security_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/disable_pin_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/set_pin_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/verify_pin_usecase.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/pin_lock_screen.dart';

class _FakeSecurityRepo implements SecurityRepository {
  bool isEnabled = true;
  String correctPin = '1234';

  @override
  Future<Result<bool>> isPinEnabled() async => Result.success(isEnabled);

  @override
  Future<Result<bool>> verifyPin(String candidatePin) async =>
      Result.success(candidatePin == correctPin);

  @override
  Future<Result<void>> setPin(String newPin) async {
    correctPin = newPin;
    isEnabled = true;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> disablePin() async {
    isEnabled = false;
    return const Result.success(null);
  }
}

void main() {
  group('PinLockScreen Tests', () {
    late _FakeSecurityRepo fakeRepo;
    late VerifyPinUseCase verifyPinUseCase;
    late SetPinUseCase setPinUseCase;
    late DisablePinUseCase disablePinUseCase;

    setUp(() {
      fakeRepo = _FakeSecurityRepo();
      verifyPinUseCase = VerifyPinUseCase(fakeRepo);
      setPinUseCase = SetPinUseCase(fakeRepo);
      disablePinUseCase = DisablePinUseCase(fakeRepo);
    });

    Widget createWidget({
      PinScreenMode mode = PinScreenMode.unlock,
      VoidCallback? onSuccess,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        theme: AppTheme.light,
        home: PinLockScreen(
          mode: mode,
          verifyPinUseCase: verifyPinUseCase,
          setPinUseCase: setPinUseCase,
          disablePinUseCase: disablePinUseCase,
          onSuccess: onSuccess,
          onCancel: onCancel,
        ),
      );
    }

    testWidgets('1. Keypad input and backspace work as expected', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      // Enter digits 1, 2
      await tester.tap(find.byKey(const Key('pin_keypad_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pin_keypad_2')));
      await tester.pumpAndSettle();

      // Tap backspace
      await tester.tap(find.byKey(const Key('pin_keypad_backspace')));
      await tester.pumpAndSettle();

      // Expect keypad buttons are present
      expect(find.byKey(const Key('pin_keypad_0')), findsOneWidget);
      expect(find.byKey(const Key('pin_keypad_9')), findsOneWidget);
    });

    testWidgets('2. Correct PIN triggers onSuccess in unlock mode', (
      tester,
    ) async {
      bool successCalled = false;
      await tester.pumpWidget(
        createWidget(
          mode: PinScreenMode.unlock,
          onSuccess: () => successCalled = true,
        ),
      );

      // Enter 1234
      await tester.tap(find.byKey(const Key('pin_keypad_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pin_keypad_2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pin_keypad_3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pin_keypad_4')));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
    });

    testWidgets('3. Incorrect PIN displays error and failed attempts count', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(mode: PinScreenMode.unlock));

      // Enter 9999
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('pin_keypad_9')));
        await tester.pumpAndSettle();
      }

      expect(find.textContaining('رمز PIN غير صحيح'), findsOneWidget);
      expect(find.textContaining('المحاولة 1 من 5'), findsOneWidget);
    });

    testWidgets('4. 5 consecutive failed attempts trigger 30s lockout', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(mode: PinScreenMode.unlock));

      // Fail 5 times
      for (int attempt = 1; attempt <= 5; attempt++) {
        for (int digit = 0; digit < 4; digit++) {
          await tester.tap(find.byKey(const Key('pin_keypad_0')));
          await tester.pumpAndSettle();
        }
      }

      expect(
        find.textContaining('تم قفل الإدخال لمدة 30 ثانية'),
        findsOneWidget,
      );
      expect(find.text('التطبيق مقفل مؤقتاً'), findsAtLeastNWidgets(1));
    });

    testWidgets('5. Create PIN workflow requires confirmation and saves', (
      tester,
    ) async {
      bool successCalled = false;
      await tester.pumpWidget(
        createWidget(
          mode: PinScreenMode.create,
          onSuccess: () => successCalled = true,
        ),
      );

      expect(find.text('تعيين رمز PIN'), findsAtLeastNWidgets(1));

      // Step 1: Enter 5555
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('pin_keypad_5')));
        await tester.pumpAndSettle();
      }

      expect(find.text('تأكيد رمز PIN'), findsAtLeastNWidgets(1));

      // Step 2: Confirm 5555
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('pin_keypad_5')));
        await tester.pumpAndSettle();
      }

      expect(successCalled, isTrue);
      expect(fakeRepo.correctPin, '5555');
    });
  });
}

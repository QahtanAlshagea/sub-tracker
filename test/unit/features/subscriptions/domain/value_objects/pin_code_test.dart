import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/pin_code.dart';

void main() {
  group('PinCode Value Object Tests', () {
    test('constructs valid 4-digit numeric PIN', () {
      final pin = PinCode('1234');
      expect(pin.value, equals('1234'));
      expect(pin.hash, isNotEmpty);
      expect(pin.toString(), equals('PinCode(****)'));
    });

    test('throws ValidationFailure when PIN length is not 4', () {
      expect(() => PinCode('123'), throwsA(isA<ValidationFailure>()));
      expect(() => PinCode('12345'), throwsA(isA<ValidationFailure>()));
      expect(() => PinCode(''), throwsA(isA<ValidationFailure>()));
    });

    test('throws ValidationFailure when PIN contains non-digits', () {
      expect(() => PinCode('12a4'), throwsA(isA<ValidationFailure>()));
      expect(() => PinCode('abcd'), throwsA(isA<ValidationFailure>()));
      expect(() => PinCode('12-4'), throwsA(isA<ValidationFailure>()));
    });

    test('hashes PIN deterministically with SHA-256', () {
      final hash1 = PinCode.hashPin('9876');
      final hash2 = PinCode.hashPin('9876');
      expect(hash1, equals(hash2));

      final pin = PinCode('9876');
      expect(pin.hash, equals(hash1));
    });

    test('verify returns true for matching PIN and false for mismatch', () {
      final hash = PinCode.hashPin('4321');
      expect(PinCode.verify('4321', hash), isTrue);
      expect(PinCode.verify('1234', hash), isFalse);
      expect(PinCode.verify('9999', hash), isFalse);
      expect(PinCode.verify('432', hash), isFalse);
      expect(PinCode.verify('4321', null), isFalse);
    });

    test('supports value equality and hashCode', () {
      final pin1 = PinCode('0000');
      final pin2 = PinCode('0000');
      final pin3 = PinCode('1111');

      expect(pin1, equals(pin2));
      expect(pin1.hashCode, equals(pin2.hashCode));
      expect(pin1, isNot(equals(pin3)));
    });
  });
}

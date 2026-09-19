import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('Money Value Object Tests', () {
    test(
      'US-01: creates Money successfully with valid minor units and ISO currency',
      () {
        final money = Money.create(amountMinorUnits: 999, currencyCode: 'USD');
        expect(money.amountMinorUnits, 999);
        expect(money.currencyCode, 'USD');
        expect(money.toMajorUnits(), 9.99);
        expect(money.isZero, isFalse);
      },
    );

    test('US-01: creates zero-value Money instance correctly', () {
      final zeroMoney = Money.zero('SAR');
      expect(zeroMoney.amountMinorUnits, 0);
      expect(zeroMoney.currencyCode, 'SAR');
      expect(zeroMoney.isZero, isTrue);
    });

    test(
      'US-01: fromMajorUnits converts decimal currency correctly with round-half-up',
      () {
        final money = Money.fromMajorUnits(
          majorUnits: 19.99,
          currencyCode: 'USD',
        );
        expect(money.amountMinorUnits, 1999);
        expect(money.toMajorUnits(), 19.99);
      },
    );

    test(
      'US-01 / [EC-01-3]: rejects negative amount in minor units with ValidationFailure',
      () {
        expect(
          () => Money.create(amountMinorUnits: -100, currencyCode: 'USD'),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('US-01: rejects invalid currency code formats', () {
      expect(
        () => Money.create(amountMinorUnits: 500, currencyCode: 'US'),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => Money.create(amountMinorUnits: 500, currencyCode: 'US12'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('US-01: adds Money instances of the same currency', () {
      final m1 = Money.create(amountMinorUnits: 1500, currencyCode: 'USD');
      final m2 = Money.create(amountMinorUnits: 2500, currencyCode: 'USD');
      final sum = m1 + m2;
      expect(sum.amountMinorUnits, 4000);
      expect(sum.currencyCode, 'USD');
    });

    test('US-01: rejects addition between different currencies', () {
      final m1 = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
      final m2 = Money.create(amountMinorUnits: 1000, currencyCode: 'EUR');
      expect(() => m1 + m2, throwsA(isA<ValidationFailure>()));
    });

    test('US-01: subtracts Money instances of the same currency', () {
      final m1 = Money.create(amountMinorUnits: 5000, currencyCode: 'USD');
      final m2 = Money.create(amountMinorUnits: 2000, currencyCode: 'USD');
      final diff = m1 - m2;
      expect(diff.amountMinorUnits, 3000);
      expect(diff.currencyCode, 'USD');
    });

    test('US-01: rejects subtraction when result would be negative', () {
      final m1 = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
      final m2 = Money.create(amountMinorUnits: 2000, currencyCode: 'USD');
      expect(() => m1 - m2, throwsA(isA<ValidationFailure>()));
    });

    test('US-01: multiplies Money by a scalar factor', () {
      final m = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
      final multiplied = m * 2.5;
      expect(multiplied.amountMinorUnits, 2500);
    });

    test('US-01: rejects scalar multiplication by negative factor', () {
      final m = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
      expect(() => m * -1, throwsA(isA<ValidationFailure>()));
    });

    test(
      'US-01: equality and hashCode based strictly on value and currency',
      () {
        final m1 = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
        final m2 = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
        final m3 = Money.create(amountMinorUnits: 1000, currencyCode: 'EUR');

        expect(m1, equals(m2));
        expect(m1.hashCode, equals(m2.hashCode));
        expect(m1, isNot(equals(m3)));
      },
    );

    test('US-01: compareTo sorts by amount within same currency', () {
      final m1 = Money.create(amountMinorUnits: 1000, currencyCode: 'USD');
      final m2 = Money.create(amountMinorUnits: 2000, currencyCode: 'USD');

      expect(m1.compareTo(m2), isNegative);
      expect(m2.compareTo(m1), isPositive);
      expect(m1.compareTo(m1), isZero);
    });
  });
}

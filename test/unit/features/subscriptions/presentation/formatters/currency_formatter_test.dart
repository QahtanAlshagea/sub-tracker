import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/formatters/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats 2-decimal currencies correctly (USD, SAR, YER, EUR)', () {
      final usd = Money.create(amountMinorUnits: 999, currencyCode: 'USD');
      expect(CurrencyFormatter.format(usd), equals('\$9.99'));

      final sar = Money.create(amountMinorUnits: 15000, currencyCode: 'SAR');
      expect(CurrencyFormatter.format(sar), equals('150.00 SAR'));

      final yer = Money.create(amountMinorUnits: 500000, currencyCode: 'YER');
      expect(CurrencyFormatter.format(yer), equals('5,000.00 YER'));

      final eur = Money.create(amountMinorUnits: 1999, currencyCode: 'EUR');
      expect(CurrencyFormatter.format(eur), equals('€19.99'));
    });

    test('formats 0-decimal currencies correctly (JPY, KRW)', () {
      final jpy = Money.create(amountMinorUnits: 1000, currencyCode: 'JPY');
      expect(CurrencyFormatter.format(jpy), equals('¥1,000'));

      final krw = Money.create(amountMinorUnits: 25000, currencyCode: 'KRW');
      expect(CurrencyFormatter.format(krw), equals('₩25,000'));
    });

    test('formats 3-decimal currencies correctly (KWD, BHD)', () {
      final kwd = Money.create(amountMinorUnits: 1250, currencyCode: 'KWD');
      expect(CurrencyFormatter.format(kwd), equals('1.250 KWD'));

      final bhd = Money.create(amountMinorUnits: 7500, currencyCode: 'BHD');
      expect(CurrencyFormatter.format(bhd), equals('7.500 BHD'));
    });

    test('formats raw minor units with currency code', () {
      expect(
        CurrencyFormatter.formatMinorUnits(minorUnits: 999, currency: 'USD'),
        equals('\$9.99'),
      );
      expect(
        CurrencyFormatter.formatMinorUnits(minorUnits: 1000, currency: 'JPY'),
        equals('¥1,000'),
      );
    });

    test('formats compact string for high numbers', () {
      final largeMoney = Money.create(
        amountMinorUnits: 125000000,
        currencyCode: 'USD',
      );
      expect(CurrencyFormatter.format(largeMoney), equals('\$1,250,000.00'));
    });
  });
}

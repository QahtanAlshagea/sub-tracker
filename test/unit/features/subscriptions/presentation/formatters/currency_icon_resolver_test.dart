import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/presentation/formatters/currency_icon_resolver.dart';

void main() {
  group('CurrencyIconResolver Tests', () {
    test('resolves Arabic currencies correctly', () {
      expect(CurrencyIconResolver.getCurrencySymbol('YER'), equals('﷼'));
      expect(CurrencyIconResolver.getCurrencySymbol('yer'), equals('﷼'));
      expect(CurrencyIconResolver.getCurrencySymbol('SAR'), equals('ر.س'));
      expect(CurrencyIconResolver.getCurrencySymbol('AED'), equals('د.إ'));
      expect(CurrencyIconResolver.getCurrencySymbol('KWD'), equals('د.ك'));
      expect(CurrencyIconResolver.getCurrencySymbol('EGP'), equals('ج.م'));
    });

    test('resolves International currencies correctly', () {
      expect(CurrencyIconResolver.getCurrencySymbol('USD'), equals('\$'));
      expect(CurrencyIconResolver.getCurrencySymbol('EUR'), equals('€'));
      expect(CurrencyIconResolver.getCurrencySymbol('GBP'), equals('£'));
      expect(CurrencyIconResolver.getCurrencySymbol('JPY'), equals('¥'));
      expect(CurrencyIconResolver.getCurrencySymbol('TRY'), equals('₺'));
    });

    test('falls back to uppercase code for unknown currencies', () {
      expect(CurrencyIconResolver.getCurrencySymbol('xyz'), equals('XYZ'));
      expect(CurrencyIconResolver.getCurrencySymbol('CAD'), equals('CAD'));
    });
  });
}

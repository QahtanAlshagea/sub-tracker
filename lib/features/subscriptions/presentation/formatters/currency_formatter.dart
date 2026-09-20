import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../domain/value_objects/money.dart';

/// Formats monetary amounts and currency values according to ISO 4217 specifications.
///
/// Adheres to ARCHITECTURE.md §3.1 and US-02/US-40:
/// - Stored as integer minor units.
/// - Formats with exact decimal places (2 for USD/SAR/YER, 0 for JPY/KRW, 3 for KWD/BHD).
/// - Includes thousand separators and localized symbols/codes.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, int> _decimalDigits = {
    'JPY': 0,
    'KRW': 0,
    'VND': 0,
    'CLP': 0,
    'HUF': 0,
    'KWD': 3,
    'BHD': 3,
    'OMR': 3,
    'JOD': 3,
    'TND': 3,
  };

  static const Map<String, String> _currencyPrefixSymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'KRW': '₩',
  };

  /// Returns the number of decimal digits for a given ISO 4217 currency code.
  static int getDecimals(String currencyCode) {
    return _decimalDigits[currencyCode.toUpperCase()] ?? 2;
  }

  /// Formats a [Money] instance into a readable monetary string.
  static String format(Money money) {
    return formatMinorUnits(
      minorUnits: money.amountMinorUnits,
      currency: money.currencyCode,
    );
  }

  /// Formats raw minor units and currency code into a readable string.
  static String formatMinorUnits({
    required int minorUnits,
    required String currency,
  }) {
    final normalizedCurrency = currency.trim().toUpperCase();
    final decimals = getDecimals(normalizedCurrency);
    final divisor = math.pow(10, decimals).toDouble();
    final majorAmount = minorUnits / divisor;

    final numberFormat = NumberFormat.currency(
      customPattern: '#,##0${decimals > 0 ? '.' : ''}${'0' * decimals}',
      decimalDigits: decimals,
    );
    final formattedNumber = numberFormat.format(majorAmount).trim();

    final prefixSymbol = _currencyPrefixSymbols[normalizedCurrency];
    if (prefixSymbol != null) {
      return '$prefixSymbol$formattedNumber';
    }

    return '$formattedNumber $normalizedCurrency';
  }
}

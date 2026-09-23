import 'package:flutter/material.dart';

/// Resolves appropriate dynamic icons and symbols for currency display.
///
/// Ensures inputs and summary views present matching currency symbols
/// instead of defaulting to a static "$" symbol.
class CurrencyIconResolver {
  const CurrencyIconResolver._();

  /// Maps standard ISO currency codes to their authentic display symbols.
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase().trim()) {
      case 'YER':
        return '﷼';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'KWD':
        return 'د.ك';
      case 'QAR':
        return 'ر.ق';
      case 'BHD':
        return 'د.ب';
      case 'OMR':
        return 'ر.ع';
      case 'EGP':
        return 'ج.م';
      case 'JOD':
        return 'د.أ';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'TRY':
        return '₺';
      default:
        return currencyCode.toUpperCase();
    }
  }

  /// Builds a formatted prefix widget for text fields and amount displays.
  static Widget buildCurrencyPrefix(
    String currencyCode, {
    Color? color,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    final symbol = getCurrencySymbol(currencyCode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        widthFactor: 1.0,
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

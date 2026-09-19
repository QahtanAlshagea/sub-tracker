import 'dart:math' as math;
import 'package:sub_tracker/core/error/failures.dart';

/// Represents an immutable monetary amount stored strictly in minor units
/// (e.g., cents, fils, halalas) to eliminate IEEE 754 floating-point inaccuracies.
///
/// Follows Clean Architecture Domain Purity — Pure Dart with zero external dependencies.
class Money implements Comparable<Money> {
  /// The monetary amount represented in integer minor units (e.g. $9.99 = 999).
  final int amountMinorUnits;

  /// The 3-letter ISO 4217 uppercase currency code (e.g., 'USD', 'EUR', 'SAR', 'YER').
  final String currencyCode;

  const Money({required this.amountMinorUnits, required this.currencyCode})
    : assert(
        amountMinorUnits >= 0,
        'Amount in minor units cannot be negative.',
      ),
      assert(
        currencyCode.length == 3,
        'Currency code must be a 3-letter ISO 4217 code.',
      );

  /// Creates a [Money] instance with validation, throwing [ValidationFailure] on invariant breach.
  factory Money.create({
    required int amountMinorUnits,
    required String currencyCode,
  }) {
    final normalizedCurrency = currencyCode.trim().toUpperCase();
    if (amountMinorUnits < 0) {
      throw const ValidationFailure('Monetary amount cannot be negative.');
    }
    if (normalizedCurrency.length != 3 ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency)) {
      throw ValidationFailure(
        'Invalid ISO 4217 currency code: "$currencyCode".',
      );
    }
    return Money(
      amountMinorUnits: amountMinorUnits,
      currencyCode: normalizedCurrency,
    );
  }

  /// Creates a zero-value [Money] instance.
  factory Money.zero([String currencyCode = 'USD']) {
    return Money.create(amountMinorUnits: 0, currencyCode: currencyCode);
  }

  /// Converts major units (e.g. 9.99) into minor units integer with exact round-half-up.
  factory Money.fromMajorUnits({
    required num majorUnits,
    required String currencyCode,
    int decimalDigits = 2,
  }) {
    if (majorUnits < 0) {
      throw const ValidationFailure('Monetary amount cannot be negative.');
    }
    final factor = math.pow(10, decimalDigits).toDouble();
    final minorUnits = (majorUnits * factor).round();
    return Money.create(
      amountMinorUnits: minorUnits,
      currencyCode: currencyCode,
    );
  }

  /// Converts minor units back to floating-point major units strictly for presentation.
  double toMajorUnits({int decimalDigits = 2}) {
    final factor = math.pow(10, decimalDigits).toDouble();
    return amountMinorUnits / factor;
  }

  /// Convenience getter for the integer amount in minor units.
  int get minorUnits => amountMinorUnits;

  /// Adds two [Money] objects. Both must share the same [currencyCode].
  Money operator +(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ValidationFailure(
        'Cannot add amounts with different currencies ($currencyCode and ${other.currencyCode}).',
      );
    }
    return Money(
      amountMinorUnits: amountMinorUnits + other.amountMinorUnits,
      currencyCode: currencyCode,
    );
  }

  /// Subtracts another [Money] object from this.
  Money operator -(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ValidationFailure(
        'Cannot subtract amounts with different currencies ($currencyCode and ${other.currencyCode}).',
      );
    }
    final result = amountMinorUnits - other.amountMinorUnits;
    if (result < 0) {
      throw const ValidationFailure(
        'Monetary subtraction resulted in negative amount.',
      );
    }
    return Money(amountMinorUnits: result, currencyCode: currencyCode);
  }

  /// Multiplies the amount by a non-negative scalar factor.
  Money operator *(num factor) {
    if (factor < 0) {
      throw const ValidationFailure(
        'Cannot multiply monetary amount by a negative factor.',
      );
    }
    final multiplied = (amountMinorUnits * factor).round();
    return Money(amountMinorUnits: multiplied, currencyCode: currencyCode);
  }

  /// Whether the monetary value is zero.
  bool get isZero => amountMinorUnits == 0;

  @override
  int compareTo(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ValidationFailure(
        'Cannot compare amounts with different currencies ($currencyCode and ${other.currencyCode}).',
      );
    }
    return amountMinorUnits.compareTo(other.amountMinorUnits);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amountMinorUnits == other.amountMinorUnits &&
          currencyCode == other.currencyCode;

  @override
  int get hashCode => amountMinorUnits.hashCode ^ currencyCode.hashCode;

  @override
  String toString() => 'Money($amountMinorUnits $currencyCode)';
}

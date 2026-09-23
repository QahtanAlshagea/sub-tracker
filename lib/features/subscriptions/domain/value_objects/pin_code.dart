import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/error/failures.dart';

/// Represents a secure 4-digit PIN code used for local app security locking.
///
/// Ensures inputs strictly consist of 4 numeric characters and provides
/// cryptographic SHA-256 hashing for offline-first local verification.
class PinCode {
  /// The required length of a valid PIN.
  static const int requiredLength = 4;

  /// The raw 4-digit PIN string (only kept in memory momentarily).
  final String value;

  const PinCode._(this.value);

  /// Validates and constructs a [PinCode] instance.
  /// Throws [ValidationFailure] if the PIN is not exactly 4 digits.
  factory PinCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length != 4 || !RegExp(r'^\d{4}$').hasMatch(trimmed)) {
      throw const ValidationFailure('رمز PIN يجب أن يتكون من 4 أرقام دقيقة.');
    }
    return PinCode._(trimmed);
  }

  /// Factory constructor that returns null or throws on invalid PIN.
  factory PinCode.create(String raw) => PinCode(raw);

  /// Computes the SHA-256 hash of this PIN code.
  String get hash => hashPin(value);

  /// Utility method to hash any 4-digit PIN string with SHA-256.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies whether the provided [candidatePin] matches the stored [expectedHash].
  static bool verify(String candidatePin, String? expectedHash) {
    if (expectedHash == null || expectedHash.isEmpty) return false;
    if (candidatePin.trim().length != 4) return false;
    return hashPin(candidatePin) == expectedHash;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinCode &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PinCode(****)';
}

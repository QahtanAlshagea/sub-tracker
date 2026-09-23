import '../../../../core/utils/result.dart';

/// Contract for managing application PIN security locking in local persistence.
///
/// Implements Clean Architecture repository pattern for offline security.
abstract class SecurityRepository {
  /// Checks whether PIN locking is currently enabled by the user.
  Future<Result<bool>> isPinEnabled();

  /// Verifies a candidate PIN against the stored cryptographic hash.
  Future<Result<bool>> verifyPin(String candidatePin);

  /// Sets or updates the 4-digit PIN code, storing its SHA-256 hash.
  Future<Result<void>> setPin(String newPin);

  /// Disables PIN locking and removes the stored hash.
  Future<Result<void>> disablePin();
}

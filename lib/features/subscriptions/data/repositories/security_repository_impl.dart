import 'package:drift/native.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/value_objects/pin_code.dart';
import '../datasources/security_local_data_source.dart';

/// Concrete implementation of [SecurityRepository] managing local offline PIN locking.
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityLocalDataSource _localDataSource;

  const SecurityRepositoryImpl(this._localDataSource);

  @override
  Future<Result<bool>> isPinEnabled() async {
    try {
      final enabled = await _localDataSource.isPinEnabled();
      return Result.success(enabled);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> verifyPin(String candidatePin) async {
    try {
      final enabled = await _localDataSource.isPinEnabled();
      if (!enabled) return const Result.success(true);

      final hash = await _localDataSource.getPinHash();
      final isMatch = PinCode.verify(candidatePin, hash);
      return Result.success(isMatch);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setPin(String newPin) async {
    try {
      final pin = PinCode(newPin);
      await _localDataSource.setPinHash(pin.hash);
      return const Result.success(null);
    } on ValidationFailure catch (f) {
      return Result.failure(f);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> disablePin() async {
    try {
      await _localDataSource.disablePin();
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}

/// Base class for all domain-level failures in Sub Tracker.
/// Pure Dart — zero dependencies on Flutter or persistence frameworks.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ message.hashCode;
}

/// Generic database or local persistence failure.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A local database error occurred.']);
}

/// Record or entity not found in storage.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Requested entity was not found.']);
}

/// Invariant validation failure (e.g. invalid name, negative price).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Storage capacity full or disk write quota exceeded.
class StorageFullFailure extends Failure {
  const StorageFullFailure([super.message = 'Device storage is full.']);
}

/// Corrupted file or incompatible schema migration failure.
class CorruptedDataFailure extends Failure {
  const CorruptedDataFailure([
    super.message = 'Stored data is corrupt or incompatible.',
  ]);
}

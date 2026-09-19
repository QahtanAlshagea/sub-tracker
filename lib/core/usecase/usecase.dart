import '../utils/result.dart';

/// Base contract for all asynchronous application use cases.
/// Pure Dart — implements Dependency Inversion Principle (DIP).
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Base contract for reactive stream-based application use cases.
/// Pure Dart — implements Dependency Inversion Principle (DIP).
abstract class StreamUseCase<T, Params> {
  Stream<Result<T>> call(Params params);
}

/// Convenience class representing empty parameters for parameterless use cases.
class NoParams {
  const NoParams();
}

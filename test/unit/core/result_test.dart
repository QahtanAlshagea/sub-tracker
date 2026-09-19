import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/core/utils/result.dart';

void main() {
  group('Result & Failure SOLID Contracts', () {
    test('Success wraps data correctly and fold invokes onSuccess', () {
      const result = Success<int>(100);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals(100));
      expect(result.failureOrNull, isNull);

      final folded = result.fold(
        onFailure: (f) => 'Failed: ${f.message}',
        onSuccess: (data) => 'Success: $data',
      );

      expect(folded, equals('Success: 100'));
    });

    test('Error wraps Failure correctly and fold invokes onFailure', () {
      const failure = ValidationFailure('Invalid amount');
      const result = Error<int>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));

      final folded = result.fold(
        onFailure: (f) => 'Failed: ${f.message}',
        onSuccess: (data) => 'Success: $data',
      );

      expect(folded, equals('Failed: Invalid amount'));
    });

    test('Failures are strongly typed and adhere to LSP', () {
      const dbFailure = DatabaseFailure();
      const notFound = NotFoundFailure();
      const validation = ValidationFailure('Too short');

      expect(dbFailure, isA<Failure>());
      expect(notFound, isA<Failure>());
      expect(validation, isA<Failure>());
      expect(validation.message, equals('Too short'));
    });
  });
}

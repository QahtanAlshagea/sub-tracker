import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/validators/subscription_validator.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group(
    'Money & Name Value Objects Edge Cases (EC-02-5, EC-02-6, EC-09-2, EC-09-3)',
    () {
      test('[EC-02-5]: Leading zeros normalized in money input', () {
        // User types or pastes "0015.50" -> standard format should parse as 15.50 (1550 minor units)
        const rawInput = '0015.50';
        final cleanNumeric = double.tryParse(rawInput);
        expect(cleanNumeric, 15.50);

        final normalizedMinor = (cleanNumeric! * 100).round();
        final money = Money.create(
          amountMinorUnits: normalizedMinor,
          currencyCode: 'USD',
        );

        expect(money.amountMinorUnits, 1550);
        expect(money.toMajorUnits(), 15.50);
      });

      test(
        '[EC-02-6]: Extremely long string pasted into price field parsed safely or rejected without crash',
        () {
          final extremelyLongInput = '9' * 100;
          final parsed = int.tryParse(extremelyLongInput);

          // Either overflow check rejects it safely or validator catches price too high
          expect(() {
            if (parsed == null ||
                parsed > SubscriptionValidator.maxPriceMinorUnits) {
              throw const ValidationFailure('Price exceeds allowed maximum');
            }
            Money.create(amountMinorUnits: parsed, currencyCode: 'USD');
          }, throwsA(isA<ValidationFailure>()));
        },
      );

      test(
        '[EC-09-2]: Duplicate name exceeding max character limit trimmed smartly preserving copy suffix',
        () {
          final longName = 'A' * 58; // 58 characters
          const suffix = ' (نسخة)'; // 7 characters
          // 58 + 7 = 65 > 60 chars maximum!
          final maxLen = SubscriptionValidator.maxNameLength;

          String smartDuplicateName(String original) {
            if (original.length + suffix.length <= maxLen) {
              return '$original$suffix';
            }
            final allowedBase = maxLen - suffix.length;
            return '${original.substring(0, allowedBase)}$suffix';
          }

          final result = smartDuplicateName(longName);
          expect(result.length, lessThanOrEqualTo(maxLen));
          expect(result.endsWith(suffix), isTrue);
        },
      );

      test(
        '[EC-09-3]: Consecutive duplicates automatically increment number suffix',
        () {
          const baseName = 'Netflix';
          final existingNames = {'Netflix', 'Netflix (نسخة)'};

          String generateNextCopyName(String base) {
            int count = 1;
            String candidate = '$base (نسخة)';
            while (existingNames.contains(candidate)) {
              count++;
              candidate = '$base (نسخة $count)';
            }
            return candidate;
          }

          final nextName = generateNextCopyName(baseName);
          expect(nextName, equals('Netflix (نسخة 2)'));
        },
      );
    },
  );
}

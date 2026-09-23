import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/obligation_type.dart';

void main() {
  group('ObligationType Value Object Tests', () {
    test('fromString parses exact names correctly', () {
      expect(
        ObligationType.fromString('subscription'),
        equals(ObligationType.subscription),
      );
      expect(ObligationType.fromString('bill'), equals(ObligationType.bill));
      expect(ObligationType.fromString('rent'), equals(ObligationType.rent));
      expect(ObligationType.fromString('other'), equals(ObligationType.other));
    });

    test('fromString handles case insensitivity and whitespace', () {
      expect(
        ObligationType.fromString('  SUBSCRIPTION  '),
        equals(ObligationType.subscription),
      );
      expect(ObligationType.fromString('Bill'), equals(ObligationType.bill));
      expect(ObligationType.fromString('RENT'), equals(ObligationType.rent));
    });

    test(
      'fromString handles null and unknown values by defaulting to subscription',
      () {
        expect(
          ObligationType.fromString(null),
          equals(ObligationType.subscription),
        );
        expect(
          ObligationType.fromString('unknown_val'),
          equals(ObligationType.subscription),
        );
        expect(
          ObligationType.fromString(''),
          equals(ObligationType.subscription),
        );
      },
    );

    test('displayNameArabic returns correct Arabic labels', () {
      expect(ObligationType.subscription.displayNameArabic, equals('اشتراك'));
      expect(ObligationType.bill.displayNameArabic, equals('فاتورة'));
      expect(ObligationType.rent.displayNameArabic, equals('إيجار'));
      expect(ObligationType.other.displayNameArabic, equals('التزام آخر'));
    });

    test('displayNameEnglish returns correct English labels', () {
      expect(
        ObligationType.subscription.displayNameEnglish,
        equals('Subscription'),
      );
      expect(ObligationType.bill.displayNameEnglish, equals('Bill'));
      expect(ObligationType.rent.displayNameEnglish, equals('Rent'));
      expect(ObligationType.other.displayNameEnglish, equals('Other'));
    });
  });
}

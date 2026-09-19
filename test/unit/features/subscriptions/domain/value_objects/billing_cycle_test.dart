import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';

void main() {
  group('BillingCycle Value Object Tests', () {
    test('US-01: creates standard monthly, yearly, and weekly cycles', () {
      const monthly = BillingCycle.monthly();
      expect(monthly.isMonthly, isTrue);
      expect(monthly.type, CycleType.monthly);
      expect(monthly.customDays, isNull);
      expect(monthly.name, 'monthly');

      const yearly = BillingCycle.yearly();
      expect(yearly.isYearly, isTrue);
      expect(yearly.name, 'yearly');

      const weekly = BillingCycle.weekly();
      expect(weekly.isWeekly, isTrue);
      expect(weekly.name, 'weekly');
    });

    test('US-01: creates custom cycle within valid range (1 to 3650 days)', () {
      final custom = BillingCycle.custom(45);
      expect(custom.isCustom, isTrue);
      expect(custom.customDays, 45);
      expect(custom.type, CycleType.custom);
      expect(custom.name, 'custom');
    });

    test('US-01 / [EC-01-5]: rejects custom cycle with 0 or negative days', () {
      expect(() => BillingCycle.custom(0), throwsA(isA<ValidationFailure>()));
      expect(() => BillingCycle.custom(-5), throwsA(isA<ValidationFailure>()));
    });

    test(
      'US-01 / [EC-01-5]: rejects custom cycle exceeding 3650 days (10 years)',
      () {
        expect(
          () => BillingCycle.custom(3651),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('US-01: parses BillingCycle from valid strings', () {
      expect(
        BillingCycle.fromString('monthly'),
        equals(const BillingCycle.monthly()),
      );
      expect(
        BillingCycle.fromString('yearly'),
        equals(const BillingCycle.yearly()),
      );
      expect(
        BillingCycle.fromString('weekly'),
        equals(const BillingCycle.weekly()),
      );
      expect(
        BillingCycle.fromString('custom', 14),
        equals(BillingCycle.custom(14)),
      );
    });

    test(
      'US-01: rejects parsing custom without customDays or invalid string',
      () {
        expect(
          () => BillingCycle.fromString('custom'),
          throwsA(isA<ValidationFailure>()),
        );
        expect(
          () => BillingCycle.fromString('biweekly'),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('US-01: equality and hashCode verify type and custom days', () {
      expect(
        const BillingCycle.monthly(),
        equals(const BillingCycle.monthly()),
      );
      expect(BillingCycle.custom(30), equals(BillingCycle.custom(30)));
      expect(BillingCycle.custom(30), isNot(equals(BillingCycle.custom(60))));
      expect(
        const BillingCycle.monthly(),
        isNot(equals(const BillingCycle.yearly())),
      );
      expect(const BillingCycle.monthly().hashCode, isNotNull);
      expect(const BillingCycle.monthly().toString(), contains('monthly'));
      expect(BillingCycle.custom(45).toString(), contains('45 days'));
    });
  });
}

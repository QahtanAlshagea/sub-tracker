import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/highest_cost_subscription_result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('HighestCostSubscriptionResult Entity Tests', () {
    final sub = Subscription.create(
      id: 'sub-1',
      name: 'AWS Hosting',
      price: const Money(amountMinorUnits: 5000, currencyCode: 'USD'),
      cycle: const BillingCycle.monthly(),
      startDate: DateTime.utc(2026, 1, 1),
      dueDate: DueDate.create(date: DateTime.utc(2026, 2, 1)),
      categoryId: 'cat-1',
    );

    test('constructor, assertions, toString, equality and hashCode', () {
      final res1 = HighestCostSubscriptionResult(
        subscription: sub,
        monthlyEquivalent: const Money(
          amountMinorUnits: 5000,
          currencyCode: 'USD',
        ),
        percentageOfTotal: 65.5,
        hasTie: false,
        isSingleSubscription: false,
      );

      final res2 = HighestCostSubscriptionResult(
        subscription: sub,
        monthlyEquivalent: const Money(
          amountMinorUnits: 5000,
          currencyCode: 'USD',
        ),
        percentageOfTotal: 65.5,
        hasTie: false,
        isSingleSubscription: false,
      );

      final resDiff = HighestCostSubscriptionResult(
        subscription: sub,
        monthlyEquivalent: const Money(
          amountMinorUnits: 5000,
          currencyCode: 'USD',
        ),
        percentageOfTotal: 100.0,
        hasTie: false,
        isSingleSubscription: true,
      );

      expect(res1, equals(res2));
      expect(res1.hashCode, equals(res2.hashCode));
      expect(res1, isNot(equals(resDiff)));
      expect(res1 == Object(), isFalse);
      expect(
        res1.toString(),
        contains('HighestCostSubscriptionResult(AWS Hosting'),
      );
      expect(res1.toString(), contains('share: 65.5%'));

      expect(
        () => HighestCostSubscriptionResult(
          subscription: sub,
          monthlyEquivalent: const Money(
            amountMinorUnits: 5000,
            currencyCode: 'USD',
          ),
          percentageOfTotal: 105.0,
          hasTie: false,
          isSingleSubscription: false,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/error/failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/price_history_entry.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('PriceHistoryEntry Entity Tests', () {
    test(
      'US-06 / [EC-06-1]: creates entry with correct delta and increase flag',
      () {
        final entry = PriceHistoryEntry.create(
          id: 'ph-1',
          subscriptionId: 'sub-1',
          oldPrice: Money.create(amountMinorUnits: 999, currencyCode: 'USD'),
          newPrice: Money.create(amountMinorUnits: 1299, currencyCode: 'USD'),
        );

        expect(entry.id, 'ph-1');
        expect(entry.subscriptionId, 'sub-1');
        expect(entry.priceDeltaMinorUnits, 300);
        expect(entry.isPriceIncrease, isTrue);
        expect(entry.isPriceDecrease, isFalse);
      },
    );

    test('US-06: detects price decrease correctly', () {
      final entry = PriceHistoryEntry.create(
        id: 'ph-2',
        subscriptionId: 'sub-1',
        oldPrice: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
        newPrice: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
      );

      expect(entry.priceDeltaMinorUnits, -500);
      expect(entry.isPriceDecrease, isTrue);
      expect(entry.isPriceIncrease, isFalse);
    });

    test('US-06: rejects currency mismatch between old and new price', () {
      expect(
        () => PriceHistoryEntry.create(
          id: 'ph-3',
          subscriptionId: 'sub-1',
          oldPrice: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          newPrice: Money.create(amountMinorUnits: 1000, currencyCode: 'EUR'),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('US-06: copyWith, toString and equality work accurately', () {
      final p1 = PriceHistoryEntry.create(
        id: 'ph-1',
        subscriptionId: 'sub-1',
        oldPrice: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
        newPrice: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
      );
      final p2 = p1.copyWith(
        id: 'ph-2',
        subscriptionId: 'sub-2',
        oldPrice: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
        newPrice: Money.create(amountMinorUnits: 2000, currencyCode: 'USD'),
        changedAt: DateTime.utc(2026, 8, 1),
      );

      expect(p2.id, 'ph-2');
      expect(p2.subscriptionId, 'sub-2');
      expect(p2.oldPrice.amountMinorUnits, 1500);
      expect(p2.newPrice.amountMinorUnits, 2000);
      expect(p1, equals(p1.copyWith()));
      expect(p1.hashCode, isNotNull);
      expect(p1.toString(), contains('ph-1'));
    });
  });
}

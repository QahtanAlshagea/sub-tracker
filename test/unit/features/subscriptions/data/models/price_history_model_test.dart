import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart' as db;
import 'package:sub_tracker/features/subscriptions/data/models/price_history_model.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/price_history_entry.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('PriceHistoryModel Tests (C-13)', () {
    final changedAt = DateTime.utc(2026, 4, 1, 12, 0);

    test(
      'PriceHistoryModel.fromEntity and toEntity preserve minor units and currency ISO',
      () {
        final entry = PriceHistoryEntry(
          id: 'hist_1',
          subscriptionId: 'sub_netflix',
          oldPrice: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          newPrice: const Money(amountMinorUnits: 1299, currencyCode: 'USD'),
          changedAt: changedAt,
        );

        final model = PriceHistoryModel.fromEntity(entry);
        expect(model.id, equals('hist_1'));
        expect(model.subscriptionId, equals('sub_netflix'));
        expect(model.oldPriceMinorUnits, equals(1000));
        expect(model.newPriceMinorUnits, equals(1299));
        expect(model.currencyCode, equals('USD'));
        expect(model.changedAt, equals(changedAt));

        final restored = model.toEntity();
        expect(restored.id, equals('hist_1'));
        expect(restored.subscriptionId, equals('sub_netflix'));
        expect(restored.oldPrice.amountMinorUnits, equals(1000));
        expect(restored.newPrice.amountMinorUnits, equals(1299));
        expect(restored.oldPrice.currencyCode, equals('USD'));
        expect(restored.priceDeltaMinorUnits, equals(299));
        expect(restored.isPriceIncrease, isTrue);

        final companion = model.toCompanion();
        expect(companion.id.value, equals('hist_1'));
        expect(companion.subscriptionId.value, equals('sub_netflix'));
        expect(companion.oldPriceMinorUnits.value, equals(1000));
        expect(companion.newPriceMinorUnits.value, equals(1299));
        expect(companion.currencyCode.value, equals('USD'));
      },
    );

    test('PriceHistoryModel.fromData maps Drift price_history row class', () {
      final data = db.PriceHistoryData(
        id: 'hist_drift',
        subscriptionId: 'sub_spotify',
        oldPriceMinorUnits: 500,
        newPriceMinorUnits: 600,
        currencyCode: 'EUR',
        changedAt: changedAt,
      );

      final model = PriceHistoryModel.fromData(data);
      expect(model.id, equals('hist_drift'));
      expect(model.subscriptionId, equals('sub_spotify'));
      expect(model.oldPriceMinorUnits, equals(500));
      expect(model.newPriceMinorUnits, equals(600));
      expect(model.currencyCode, equals('EUR'));
    });

    test('PriceHistoryModel JSON serialization and deserialization', () {
      final model = PriceHistoryModel(
        id: 'hist_json',
        subscriptionId: 'sub_chatgpt',
        oldPriceMinorUnits: 2000,
        newPriceMinorUnits: 2500,
        currencyCode: 'USD',
        changedAt: changedAt,
      );

      final json = model.toJson();
      final fromJson = PriceHistoryModel.fromJson(json);

      expect(fromJson, equals(model));
      expect(fromJson.hashCode, equals(model.hashCode));
      expect(fromJson.toString(), contains('sub_chatgpt'));
    });
  });
}

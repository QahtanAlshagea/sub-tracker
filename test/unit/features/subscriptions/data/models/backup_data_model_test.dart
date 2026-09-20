import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/data/models/backup_data_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/category_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/price_history_model.dart';
import 'package:sub_tracker/features/subscriptions/data/models/subscription_model.dart';

void main() {
  group('BackupDataModel & The 5 Backup Test Files (Card C-14 / US-29, US-30)', () {
    // -------------------------------------------------------------
    // FILE 1: VALID (سليم) — US-29 / [EC-29-4]
    // -------------------------------------------------------------
    test(
      'File 1 (Valid): serializes and deserializes valid backup JSON including Arabic text and emojis [EC-29-4]',
      () {
        final now = DateTime.utc(2026, 9, 20, 4, 0, 0);
        final validModel = BackupDataModel(
          schemaVersion: 2,
          exportedAt: now,
          appVersion: '1.0.0',
          categories: [
            CategoryModel(
              id: 'cat-ar',
              name: 'ترفيه وموسيقى 🎵',
              colorValue: 0xFFEF4444,
              iconCode: 'music_note',
              isSystem: false,
              createdAt: now,
            ),
          ],
          subscriptions: [
            SubscriptionModel(
              id: 'sub-ar-spotify',
              name: 'سبوتيفاي عائلي 🎧',
              priceMinorUnits: 1199,
              currencyCode: 'SAR',
              cycleType: 'monthly',
              startDate: now,
              nextDueDate: now.add(const Duration(days: 30)),
              originalAnchorDay: 20,
              categoryId: 'cat-ar',
              notes: 'اشتراك عائلي مع الأصدقاء & تجربة ممتازة ⭐',
              paymentMethodDesc: 'بطاقة مدى 1234',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          priceHistory: [
            PriceHistoryModel(
              id: 'ph-1',
              subscriptionId: 'sub-ar-spotify',
              oldPriceMinorUnits: 999,
              newPriceMinorUnits: 1199,
              currencyCode: 'SAR',
              changedAt: now,
            ),
          ],
          settings: {'theme_mode': 'dark', 'default_currency': 'SAR'},
        );

        // Act: Serialize to JSON string
        final jsonString = validModel.toJsonString();
        expect(jsonString, contains('سبوتيفاي عائلي 🎧'));
        expect(jsonString, contains('ترفيه وموسيقى 🎵'));
        expect(jsonString, contains('بطاقة مدى 1234'));

        // Act: Deserialize back from JSON string
        final parsed = BackupDataModel.fromJsonString(jsonString);

        // Assert
        expect(parsed.schemaVersion, equals(2));
        expect(parsed.appVersion, equals('1.0.0'));
        expect(parsed.categories.length, equals(1));
        expect(parsed.categories.first.name, equals('ترفيه وموسيقى 🎵'));
        expect(parsed.subscriptions.length, equals(1));
        expect(parsed.subscriptions.first.name, equals('سبوتيفاي عائلي 🎧'));
        expect(
          parsed.subscriptions.first.paymentMethodDesc,
          equals('بطاقة مدى 1234'),
        );
        expect(parsed.priceHistory.length, equals(1));
        expect(parsed.priceHistory.first.oldPriceMinorUnits, equals(999));
        expect(parsed.settings['theme_mode'], equals('dark'));

        // Verify entity conversion
        final entity = parsed.toEntity();
        expect(entity.isEmpty, isFalse);
        expect(entity.subscriptions.first.name, equals('سبوتيفاي عائلي 🎧'));
      },
    );

    // -------------------------------------------------------------
    // FILE 2: CORRUPT (تالف) — US-30 / [EC-30-1]
    // -------------------------------------------------------------
    test(
      'File 2 (Corrupt): throws FormatException on malformed JSON or missing required root keys [EC-30-1]',
      () {
        // Case A: Syntax error (truncated JSON)
        const truncatedJson = '{"schema_version": 2, "categories": [';
        expect(
          () => BackupDataModel.fromJsonString(truncatedJson),
          throwsA(isA<FormatException>()),
        );

        // Case B: Missing schema_version key
        const missingVersionJson = '{"categories": [], "subscriptions": []}';
        expect(
          () => BackupDataModel.fromJsonString(missingVersionJson),
          throwsA(isA<FormatException>()),
        );

        // Case C: Missing categories array
        const missingCategoriesJson =
            '{"schema_version": 2, "subscriptions": []}';
        expect(
          () => BackupDataModel.fromJsonString(missingCategoriesJson),
          throwsA(isA<FormatException>()),
        );

        // Case D: Invalid JSON root (e.g. array instead of object)
        const arrayRootJson = '["not", "an", "object"]';
        expect(
          () => BackupDataModel.fromJsonString(arrayRootJson),
          throwsA(isA<FormatException>()),
        );
      },
    );

    // -------------------------------------------------------------
    // FILE 3: OLDER (أقدم - V1) — US-30 / [EC-30-2]
    // -------------------------------------------------------------
    test(
      'File 3 (Older V1): automatically upgrades schema_version 1 to schema_version 2 with defaults [EC-30-2]',
      () {
        const v1Json = '''
        {
          "schema_version": 1,
          "app_version": "0.9.0",
          "exported_at": "2026-01-01T00:00:00.000Z",
          "categories": [
            {
              "id": "cat-v1",
              "name": "Old Category",
              "color_value": 4280191200,
              "created_at": "2026-01-01T00:00:00.000Z"
            }
          ],
          "subscriptions": [
            {
              "id": "sub-v1",
              "name": "Old Netflix",
              "price_minor_units": 1500,
              "currency_code": "USD",
              "cycle_type": "monthly",
              "start_date": "2026-01-01T00:00:00.000Z",
              "next_due_date": "2026-02-01T00:00:00.000Z",
              "original_anchor_day": 1,
              "category_id": "cat-v1",
              "created_at": "2026-01-01T00:00:00.000Z",
              "updated_at": "2026-01-01T00:00:00.000Z"
            }
          ]
        }
        ''';

        final upgraded = BackupDataModel.fromJsonString(v1Json);

        // Assert: Automatically upgraded to schemaVersion 2
        expect(upgraded.schemaVersion, equals(2));
        expect(upgraded.subscriptions.length, equals(1));
        // Nullable payment_method_desc added gracefully
        expect(upgraded.subscriptions.first.paymentMethodDesc, isNull);
        // Default settings populated
        expect(upgraded.settings['id'], equals('app_settings'));
        expect(upgraded.settings['default_currency'], equals('USD'));
        expect(upgraded.priceHistory, isEmpty);
      },
    );

    // -------------------------------------------------------------
    // FILE 4: NEWER (أحدث - V3) — US-30 / [EC-30-3]
    // -------------------------------------------------------------
    test(
      'File 4 (Newer V3): rejects schema_version greater than current with BackupSchemaVersionTooNewException [EC-30-3]',
      () {
        const v3Json = '''
        {
          "schema_version": 3,
          "app_version": "2.0.0",
          "exported_at": "2027-01-01T00:00:00.000Z",
          "categories": [],
          "subscriptions": []
        }
        ''';

        expect(
          () => BackupDataModel.fromJsonString(v3Json),
          throwsA(
            isA<BackupSchemaVersionTooNewException>()
                .having((e) => e.fileVersion, 'fileVersion', 3)
                .having((e) => e.supportedVersion, 'supportedVersion', 2),
          ),
        );
      },
    );

    // -------------------------------------------------------------
    // FILE 5: LARGE (ضخم - 1000+ records) — US-30 / [EC-30-4]
    // -------------------------------------------------------------
    test(
      'File 5 (Large): serializes and parses large dataset with 1000+ subscriptions without error [EC-30-4]',
      () {
        final now = DateTime.utc(2026, 9, 20);
        final categories = List.generate(
          10,
          (i) => CategoryModel(
            id: 'cat-$i',
            name: 'Category $i',
            colorValue: 0xFF10B981,
            createdAt: now,
          ),
        );

        final subscriptions = List.generate(
          1000,
          (i) => SubscriptionModel(
            id: 'sub-large-$i',
            name: 'Subscription #$i',
            priceMinorUnits: 500 + (i * 10),
            currencyCode: 'USD',
            cycleType: 'monthly',
            startDate: now,
            nextDueDate: now.add(Duration(days: i % 30)),
            originalAnchorDay: (i % 28) + 1,
            categoryId: 'cat-${i % 10}',
            createdAt: now,
            updatedAt: now,
          ),
        );

        final priceHistories = List.generate(
          500,
          (i) => PriceHistoryModel(
            id: 'ph-$i',
            subscriptionId: 'sub-large-$i',
            oldPriceMinorUnits: 400,
            newPriceMinorUnits: 500 + (i * 10),
            currencyCode: 'USD',
            changedAt: now,
          ),
        );

        final largeModel = BackupDataModel(
          schemaVersion: 2,
          exportedAt: now,
          categories: categories,
          subscriptions: subscriptions,
          priceHistory: priceHistories,
        );

        // Measure serialization time
        final stopwatch = Stopwatch()..start();
        final jsonString = largeModel.toJsonString();
        final encodeTime = stopwatch.elapsedMilliseconds;

        // Measure deserialization time
        stopwatch.reset();
        final parsed = BackupDataModel.fromJsonString(jsonString);
        final decodeTime = stopwatch.elapsedMilliseconds;

        expect(parsed.categories.length, equals(10));
        expect(parsed.subscriptions.length, equals(1000));
        expect(parsed.priceHistory.length, equals(500));

        // Both encode and decode must be performant
        expect(encodeTime, lessThan(2000));
        expect(decodeTime, lessThan(2000));
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/backup_preview.dart';

void main() {
  group('BackupPreview & ImportResult Entity Tests', () {
    final now = DateTime.utc(2026, 9, 21);

    test('BackupPreview properties, toString, equality and hashCode', () {
      final preview1 = BackupPreview(
        schemaVersion: 1,
        exportedAt: now,
        appVersion: '1.0.0',
        totalCategories: 5,
        newCategories: 2,
        duplicateCategories: 3,
        totalSubscriptions: 10,
        newSubscriptions: 4,
        duplicateSubscriptions: 6,
        totalPriceHistories: 15,
      );

      final preview2 = BackupPreview(
        schemaVersion: 1,
        exportedAt: now,
        appVersion: '1.0.0',
        totalCategories: 5,
        newCategories: 2,
        duplicateCategories: 3,
        totalSubscriptions: 10,
        newSubscriptions: 4,
        duplicateSubscriptions: 6,
        totalPriceHistories: 15,
      );

      final previewDiff = BackupPreview(
        schemaVersion: 1,
        exportedAt: now,
        appVersion: '1.0.0',
        totalCategories: 6,
        newCategories: 3,
        duplicateCategories: 3,
        totalSubscriptions: 10,
        newSubscriptions: 4,
        duplicateSubscriptions: 6,
        totalPriceHistories: 15,
      );

      expect(preview1, equals(preview2));
      expect(preview1.hashCode, equals(preview2.hashCode));
      expect(preview1, isNot(equals(previewDiff)));
      expect(preview1 == Object(), isFalse);
      expect(preview1.toString(), contains('BackupPreview(v1'));
      expect(preview1.toString(), contains('categories: 5'));
    });

    test('ImportResult properties, toString, equality and hashCode', () {
      final res1 = ImportResult(
        importedCategories: 2,
        importedSubscriptions: 4,
        importedPriceHistories: 8,
        strategy: ImportStrategy.merge,
      );

      final res2 = ImportResult(
        importedCategories: 2,
        importedSubscriptions: 4,
        importedPriceHistories: 8,
        strategy: ImportStrategy.merge,
      );

      final resReplace = ImportResult(
        importedCategories: 2,
        importedSubscriptions: 4,
        importedPriceHistories: 8,
        strategy: ImportStrategy.replace,
      );

      expect(res1, equals(res2));
      expect(res1.hashCode, equals(res2.hashCode));
      expect(res1, isNot(equals(resReplace)));
      expect(res1 == Object(), isFalse);
      expect(res1.toString(), contains('ImportResult('));
      expect(res1.toString(), contains('strategy: ImportStrategy.merge'));
    });
  });
}

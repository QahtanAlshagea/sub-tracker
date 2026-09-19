import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/subscriptions/data/daos/settings_dao.dart';

void main() {
  late AppDatabase db;
  late SettingsDao settingsDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settingsDao = db.settingsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsDao Queries & Updates (C-12)', () {
    test('getSettings retrieves seeded default application settings', () async {
      final settings = await settingsDao.getSettings();
      expect(settings, isNotNull);
      expect(settings!.id, equals(kDefaultSettingsId));
      expect(settings.themeMode, equals('system'));
      expect(settings.defaultCurrency, equals('USD'));
      expect(settings.defaultReminderDays, equals(1));
      expect(settings.defaultReminderHour, equals(9));
      expect(settings.defaultReminderMinute, equals(0));
      expect(settings.schemaVersion, equals(2));
      expect(settings.lastBackupAt, isNull);
    });

    test(
      'updateThemeMode and updateDefaultCurrency modify preferences',
      () async {
        await settingsDao.updateThemeMode('dark');
        var settings = await settingsDao.getSettings();
        expect(settings!.themeMode, equals('dark'));

        await settingsDao.updateDefaultCurrency('SAR');
        settings = await settingsDao.getSettings();
        expect(settings!.defaultCurrency, equals('SAR'));
      },
    );

    test('updateBackupTimestamp updates lastBackupAt accurately', () async {
      final backupTime = DateTime.utc(2026, 9, 20, 12, 0, 0);
      await settingsDao.updateBackupTimestamp(backupTime);

      final settings = await settingsDao.getSettings();
      expect(
        settings!.lastBackupAt!.millisecondsSinceEpoch ~/ 1000,
        equals(backupTime.millisecondsSinceEpoch ~/ 1000),
      );
    });

    test('watchSettings emits updates reactively upon change', () async {
      final stream = settingsDao.watchSettings();
      final initial = await stream.first;
      expect(initial?.themeMode, equals('system'));

      await settingsDao.updateThemeMode('light');

      final updated = await settingsDao.getSettings();
      expect(updated?.themeMode, equals('light'));
    });

    test('upsertSettings updates multiple settings fields at once', () async {
      await settingsDao.upsertSettings(
        SettingsCompanion(
          id: const Value(kDefaultSettingsId),
          themeMode: const Value('dark'),
          defaultCurrency: const Value('EUR'),
          defaultReminderDays: const Value(3),
          defaultReminderHour: const Value(10),
          defaultReminderMinute: const Value(30),
          defaultSortOrder: const Value('price_desc'),
          schemaVersion: const Value(2),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      final settings = await settingsDao.getSettings();
      expect(settings!.themeMode, equals('dark'));
      expect(settings.defaultCurrency, equals('EUR'));
      expect(settings.defaultReminderDays, equals(3));
      expect(settings.defaultReminderHour, equals(10));
      expect(settings.defaultReminderMinute, equals(30));
      expect(settings.defaultSortOrder, equals('price_desc'));
    });
  });
}

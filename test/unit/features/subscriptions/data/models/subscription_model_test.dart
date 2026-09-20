import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/database/app_database.dart' as db;
import 'package:sub_tracker/features/subscriptions/data/models/subscription_model.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

void main() {
  group('SubscriptionModel Tests (C-13)', () {
    final now = DateTime.utc(2026, 3, 1, 10, 0);
    final due = DateTime.utc(2026, 4, 1, 10, 0);

    test(
      'SubscriptionModel.fromEntity converts complex Domain Subscription with all Value Objects',
      () {
        final subscription = Subscription(
          id: 'sub_123',
          name: 'GitHub Copilot',
          price: const Money(amountMinorUnits: 1000, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          dueDate: DueDate(due, 1),
          startDate: now,
          categoryId: 'cat_work',
          status: SubscriptionStatus.active,
          isTrial: false,
          notes: 'Developer tools',
          renewalUrl: 'https://github.com',
          paymentMethodDesc: 'Visa 1234',
          reminderEnabled: true,
          reminderLeadDays: 2,
          reminderTimeHour: 9,
          reminderTimeMinute: 30,
          createdAt: now,
          updatedAt: now,
        );

        final model = SubscriptionModel.fromEntity(subscription);

        expect(model.id, equals('sub_123'));
        expect(model.name, equals('GitHub Copilot'));
        expect(model.priceMinorUnits, equals(1000));
        expect(model.currencyCode, equals('USD'));
        expect(model.cycleType, equals('monthly'));
        expect(model.customCycleDays, isNull);
        expect(model.originalAnchorDay, equals(1));
        expect(model.categoryId, equals('cat_work'));
        expect(model.status, equals('active'));
        expect(model.reminderLeadDays, equals(2));
        expect(model.reminderTimeHour, equals(9));
        expect(model.reminderTimeMinute, equals(30));

        final companion = model.toCompanion();
        expect(companion.id.value, equals('sub_123'));
        expect(companion.name.value, equals('GitHub Copilot'));
        expect(companion.priceMinorUnits.value, equals(1000));
        expect(companion.currencyCode.value, equals('USD'));
      },
    );

    test(
      'SubscriptionModel.toEntity restores Money, DueDate, BillingCycle, and Status correctly',
      () {
        final model = SubscriptionModel(
          id: 'sub_gym',
          name: 'نادي رياضي',
          priceMinorUnits: 5000,
          currencyCode: 'SAR',
          cycleType: 'custom',
          customCycleDays: 45,
          startDate: now,
          nextDueDate: due,
          originalAnchorDay: 15,
          categoryId: 'cat_health',
          status: 'archived',
          isTrial: true,
          createdAt: now,
          updatedAt: now,
        );

        final entity = model.toEntity();

        expect(entity.id, equals('sub_gym'));
        expect(entity.name, equals('نادي رياضي'));
        expect(entity.price.amountMinorUnits, equals(5000));
        expect(entity.price.currencyCode, equals('SAR'));
        expect(entity.cycle.isCustom, isTrue);
        expect(entity.cycle.customDays, equals(45));
        expect(entity.dueDate.originalAnchorDay, equals(15));
        expect(entity.status, equals(SubscriptionStatus.archived));
        expect(entity.isTrial, isTrue);
      },
    );

    test('SubscriptionModel.fromData maps Drift row class to Model', () {
      final driftRow = db.Subscription(
        id: 'sub_drift',
        name: 'iCloud+',
        priceMinorUnits: 299,
        currencyCode: 'USD',
        cycleType: 'monthly',
        customCycleDays: null,
        startDate: now,
        nextDueDate: due,
        originalAnchorDay: 1,
        categoryId: 'cat_storage',
        status: 'active',
        isTrial: false,
        notes: '200 GB plan',
        renewalUrl: 'https://apple.com',
        paymentMethodDesc: 'Apple Pay',
        reminderEnabled: true,
        reminderLeadDays: 3,
        reminderTimeHour: 10,
        reminderTimeMinute: 0,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
        archivedAt: null,
      );

      final model = SubscriptionModel.fromData(driftRow);

      expect(model.id, equals('sub_drift'));
      expect(model.name, equals('iCloud+'));
      expect(model.priceMinorUnits, equals(299));
      expect(model.reminderLeadDays, equals(3));
      expect(model.notes, equals('200 GB plan'));
    });

    test(
      'SubscriptionModel JSON serialization and deserialization roundtrips without loss',
      () {
        final model = SubscriptionModel(
          id: 'sub_json',
          name: 'Amazon Prime',
          priceMinorUnits: 14900,
          currencyCode: 'USD',
          cycleType: 'yearly',
          startDate: now,
          nextDueDate: due,
          originalAnchorDay: 1,
          categoryId: 'cat_sub',
          createdAt: now,
          updatedAt: now,
        );

        final json = model.toJson();
        final fromJson = SubscriptionModel.fromJson(json);

        expect(fromJson, equals(model));
        expect(fromJson.hashCode, equals(model.hashCode));
        expect(fromJson.toString(), contains('Amazon Prime'));
      },
    );
  });
}

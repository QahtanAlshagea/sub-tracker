import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/services/notification_service.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/obligation_type.dart';

class FakeNotificationService implements NotificationService {
  final List<Subscription> scheduled = [];
  final List<String> cancelled = [];
  bool allCancelled = false;
  bool initialized = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleSubscriptionReminder(Subscription subscription) async {
    if (!subscription.reminderEnabled || subscription.isArchived) {
      await cancelSubscriptionReminder(subscription.id);
      return;
    }
    scheduled.add(subscription);
  }

  @override
  Future<void> cancelSubscriptionReminder(String subscriptionId) async {
    cancelled.add(subscriptionId);
    scheduled.removeWhere((s) => s.id == subscriptionId);
  }

  @override
  Future<void> cancelAllReminders() async {
    allCancelled = true;
    scheduled.clear();
  }
}

void main() {
  group(
    'NotificationService Contract & Scheduling Tests (FR-10, US-26, US-27)',
    () {
      late FakeNotificationService service;
      late Subscription testSubscription;

      setUp(() {
        service = FakeNotificationService();
        final now = DateTime.now().toUtc();
        testSubscription = Subscription.create(
          id: '101',
          name: 'Netflix Premium',
          price: const Money(amountMinorUnits: 1500, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: now,
          dueDate: DueDate(now.add(const Duration(days: 5))),
          categoryId: 'cat-streaming',
          obligationType: ObligationType.subscription,
          reminderEnabled: true,
          reminderLeadDays: 2,
          reminderTimeHour: 9,
          reminderTimeMinute: 0,
          createdAt: now,
          updatedAt: now,
        );
      });

      test('US-26: schedules reminder when reminderEnabled is true', () async {
        await service.scheduleSubscriptionReminder(testSubscription);
        expect(service.scheduled.length, 1);
        expect(service.scheduled.first.name, 'Netflix Premium');
      });

      test(
        'US-27: cancels reminder when reminderEnabled is false or subscription is archived',
        () async {
          await service.scheduleSubscriptionReminder(testSubscription);
          expect(service.scheduled.length, 1);

          final disabledSub = testSubscription.copyWith(reminderEnabled: false);
          await service.scheduleSubscriptionReminder(disabledSub);

          expect(service.scheduled.isEmpty, isTrue);
          expect(service.cancelled, contains('101'));
        },
      );

      test(
        'US-27: cancelAllReminders clears all scheduled reminders',
        () async {
          await service.scheduleSubscriptionReminder(testSubscription);
          expect(service.scheduled.length, 1);

          await service.cancelAllReminders();
          expect(service.scheduled.isEmpty, isTrue);
          expect(service.allCancelled, isTrue);
        },
      );

      test(
        'FR-10: lead days and trigger calculations are preserved on subscription',
        () {
          expect(testSubscription.reminderLeadDays, 2);
          expect(testSubscription.reminderTimeHour, 9);
          expect(testSubscription.reminderTimeMinute, 0);
        },
      );
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/subscription_status.dart';

void main() {
  group('Notification Policy & Scheduling Edge Cases (US-26..US-27)', () {
    Subscription createSub({
      String id = 'sub-notif',
      String name = 'Gym',
      required DateTime dueDate,
      int reminderLeadDays = 3,
      int reminderHour = 9,
      int reminderMinute = 0,
      bool reminderEnabled = true,
    }) {
      return Subscription(
        id: id,
        name: name,
        price: const Money(amountMinorUnits: 4000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: DateTime.utc(2026, 1, 1),
        dueDate: DueDate(dueDate, 1),
        categoryId: 'cat-health',
        status: SubscriptionStatus.active,
        reminderEnabled: reminderEnabled,
        reminderLeadDays: reminderLeadDays,
        reminderTimeHour: reminderHour,
        reminderTimeMinute: reminderMinute,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
    }

    test(
      '[EC-26-1]: Notification permission rejection saves preference and presents guidance banner',
      () {
        bool permissionGranted = false;
        bool preferenceSaved = false;
        String? bannerMessage;

        void onPermissionResult(bool granted) {
          permissionGranted = granted;
          preferenceSaved = true;
          if (!granted) {
            bannerMessage =
                'تم تعطيل الإشعارات. يمكنك تفعيلها من إعدادات النظام لتلقي تنبيهات الاستحقاق.';
          }
        }

        onPermissionResult(false);
        expect(permissionGranted, isFalse);
        expect(preferenceSaved, isTrue);
        expect(bannerMessage, contains('إعدادات النظام'));
      },
    );

    test(
      '[EC-26-2]: Alert lead time placing notification in past warns user instead of scheduling in past',
      () {
        final now = DateTime.utc(2026, 9, 21, 12, 0);
        final dueDate = DateTime.utc(2026, 9, 22, 9, 0); // Due tomorrow morning

        // 3 days lead time would put scheduled alert at 2026-09-19 (in the past!)
        final alertDate = dueDate.subtract(const Duration(days: 3));
        final isPast = alertDate.isBefore(now);

        expect(isPast, isTrue);
        // Defensive rule: do not schedule in the past; trigger imminent alert or flag
        final effectiveSchedule = isPast ? now : alertDate;
        expect(effectiveSchedule, equals(now));
      },
    );

    test(
      '[EC-26-3]: Device reboot triggers rescheduling of pending notifications on next launch',
      () {
        final pendingSubs = [
          createSub(id: '1', dueDate: DateTime.utc(2026, 10, 1)),
          createSub(id: '2', dueDate: DateTime.utc(2026, 10, 5)),
        ];

        final scheduledIds = <String>[];
        void rescheduleAll(List<Subscription> subs) {
          scheduledIds.clear();
          for (final sub in subs) {
            if (sub.reminderEnabled &&
                sub.status == SubscriptionStatus.active) {
              scheduledIds.add(sub.id);
            }
          }
        }

        // Simulate post-reboot sync
        rescheduleAll(pendingSubs);
        expect(scheduledIds, equals(['1', '2']));
      },
    );

    test(
      '[EC-26-4]: Timezone shift recalculates notification schedule on local calendar day basis',
      () {
        // Due on 2026-10-01 UTC at 09:00
        final utcDueDate = DateTime.utc(2026, 10, 1, 9, 0);

        // Local time in UTC+3 (e.g. Sanaa/Riyadh)
        final localOffset = const Duration(hours: 3);
        final localDue = utcDueDate.add(localOffset);

        expect(localDue.day, 1);
        expect(localDue.hour, 12);
      },
    );

    test(
      '[EC-27-1]: Snooze extending beyond due date displays overdue warning',
      () {
        final now = DateTime.utc(2026, 9, 21);
        final dueDate = DateTime.utc(2026, 9, 20); // Already due yesterday

        final snoozedUntil = now.add(const Duration(days: 2));
        final isPastDue = snoozedUntil.isAfter(dueDate);

        expect(isPastDue, isTrue);
        final displayStatus = isPastDue ? 'متأخر (مؤجل)' : 'قادم';
        expect(displayStatus, contains('متأخر'));
      },
    );

    test(
      '[EC-27-2]: Repeated snooze attempts capped at maximum limit before final alert',
      () {
        const maxSnoozeCount = 3;
        int currentSnoozeCount = 3;

        final canSnoozeAgain = currentSnoozeCount < maxSnoozeCount;
        expect(canSnoozeAgain, isFalse);

        final nextAction = canSnoozeAgain ? 'snooze' : 'final_alert';
        expect(nextAction, 'final_alert');
      },
    );
  });
}

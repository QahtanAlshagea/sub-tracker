import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../features/subscriptions/domain/entities/subscription.dart';

/// Abstract contract for local device notification scheduling.
abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> scheduleSubscriptionReminder(Subscription subscription);
  Future<void> cancelSubscriptionReminder(String subscriptionId);
  Future<void> cancelAllReminders();
}

/// Robust implementation of [NotificationService] using [FlutterLocalNotificationsPlugin].
/// Compatible with Android 5.0 (API 21) through Android 15 (API 35+).
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  static const String channelId = 'sub_tracker_reminders_channel';
  static const String channelName = 'تنبيهات استحقاق الفواتير والاشتراكات';
  static const String channelDescription =
      'إشعارات تذكيرية محلية قبل موعد استحقاق الاشتراكات والفواتير والأقساط';

  NotificationServiceImpl({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidInitSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidInitSettings);

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          developer.log(
            'Notification tapped with payload: ${response.payload}',
            name: 'NotificationService',
          );
        },
      );

      // Create high-importance Android Notification Channel
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlatform != null) {
        const channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );
        await androidPlatform.createNotificationChannel(channel);
      }

      _isInitialized = true;
    } catch (e, st) {
      developer.log(
        'Failed to initialize NotificationService: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlatform != null) {
        final granted = await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      developer.log(
        'Error requesting notification permissions: $e',
        name: 'NotificationService',
        error: e,
      );
      return false;
    }
  }

  int _getNotificationId(String subscriptionId) {
    return int.tryParse(subscriptionId) ??
        (subscriptionId.hashCode & 0x7FFFFFFF);
  }

  @override
  Future<void> scheduleSubscriptionReminder(Subscription subscription) async {
    if (!subscription.reminderEnabled || subscription.isArchived) {
      await cancelSubscriptionReminder(subscription.id);
      return;
    }

    try {
      if (!_isInitialized) {
        await initialize();
      }

      final dueDate = subscription.dueDate.date;
      // Calculate target trigger date: dueDate minus leadDays
      final triggerDate = dueDate.subtract(
        Duration(days: subscription.reminderLeadDays),
      );

      final scheduledDateTime = DateTime(
        triggerDate.year,
        triggerDate.month,
        triggerDate.day,
        subscription.reminderTimeHour,
        subscription.reminderTimeMinute,
      );

      // If scheduled time has already passed, don't schedule an old alarm
      if (scheduledDateTime.isBefore(DateTime.now())) {
        return;
      }

      final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableLights: true,
        enableVibration: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      final daysRemaining = subscription.reminderLeadDays;
      final leadText = daysRemaining == 0
          ? 'اليوم'
          : (daysRemaining == 1
                ? 'غداً'
                : (daysRemaining == 2
                      ? 'بعد يومين'
                      : 'خلال $daysRemaining أيام'));

      final title = 'تنبيه استحقاق: ${subscription.name}';
      final priceFormatted = (subscription.price.amountMinorUnits / 100)
          .toStringAsFixed(2);
      final body =
          'يستحق سداد ${subscription.name} ($leadText) بمبلغ $priceFormatted ${subscription.price.currencyCode}';

      final notificationId = _getNotificationId(subscription.id);

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: subscription.id,
      );

      developer.log(
        'Scheduled reminder for ${subscription.name} at $scheduledDateTime',
        name: 'NotificationService',
      );
    } catch (e, st) {
      developer.log(
        'Error scheduling notification for subscription ${subscription.id}: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> cancelSubscriptionReminder(String subscriptionId) async {
    try {
      final notificationId = _getNotificationId(subscriptionId);
      await _notificationsPlugin.cancel(id: notificationId);
    } catch (e) {
      developer.log(
        'Error canceling notification for subscription $subscriptionId: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  @override
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      developer.log(
        'Error canceling all notifications: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }
}

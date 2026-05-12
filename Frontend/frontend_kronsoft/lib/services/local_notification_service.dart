import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<String> onNotificationTapped =
      StreamController<String>.broadcast();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'pill_reminders',
    'Pill Reminders',
    description: 'Notifications for pill reminders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImpl?.createNotificationChannel(_channel);
    await androidImpl?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      onNotificationTapped.add(response.payload!);
    }
  }

  static Future<void> schedulePillNotifications({
    required int pillId,
    required String pillMongoId,
    required String pillName,
    required String dosage,
    required List<String> schedule,
    required int reminderMinutes,
  }) async {
    await cancelPillNotifications(pillId);

    for (int i = 0; i < schedule.length; i++) {
      final timeParts = schedule[i].split(':');
      if (timeParts.length != 2) continue;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final timeStr =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      await _scheduleNotification(
        id: pillId * 100 + i * 2,
        title: '💊 Time to take your pill!',
        body:
            'It\'s time to take $pillName${dosage.isNotEmpty ? ' ($dosage)' : ''}',
        hour: hour,
        minute: minute,
        payload: 'pill|$pillMongoId|$pillName|$dosage|$timeStr',
      );

      if (reminderMinutes > 0) {
        int reminderMinute = minute - reminderMinutes;
        int reminderHour = hour;

        if (reminderMinute < 0) {
          reminderMinute += 60;
          reminderHour -= 1;
          if (reminderHour < 0) reminderHour = 23;
        }

        await _scheduleNotification(
          id: pillId * 100 + i * 2 + 1,
          title: '⏰ Pill reminder',
          body:
              '$pillName in $reminderMinutes minutes${dosage.isNotEmpty ? ' ($dosage)' : ''}',
          hour: reminderHour,
          minute: reminderMinute,
          payload: 'pill_reminder|$pillMongoId|$pillName|$dosage|$timeStr',
        );
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelPillNotifications(int pillId) async {
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(pillId * 100 + i * 2);
      await _plugin.cancel(pillId * 100 + i * 2 + 1);
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminders',
          'Pill Reminders',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        ),
      ),
    );
  }
}

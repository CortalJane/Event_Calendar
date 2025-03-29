import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// 📌 Initialize Notifications
  static Future<void> init() async {
    tz.initializeTimeZones(); // Initialize timezone data
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings);
  }

  /// 🔔 Show Instant Notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Event Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, details);
  }

  /// ⏳ Schedule a Notification
  static Future<void> scheduleNotification(String title, String body, DateTime eventDate, String time) async {
    try {
      DateTime fullDateTime = DateFormat('yyyy-MM-dd HH:mm').parse("${DateFormat('yyyy-MM-dd').format(eventDate)} $time");
      tz.TZDateTime scheduledTime = tz.TZDateTime.from(fullDateTime, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Event Reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        0,
        title,
        body,
        scheduledTime,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }
}

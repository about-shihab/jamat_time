import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    tz.initializeTimeZones();
    await _notificationsPlugin.initialize(settings);

    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification(String prayerName, DateTime prayerTime, int minutesBefore) async {
    final scheduleTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    
    if (scheduleTime.isBefore(DateTime.now())) return;
    
    await _notificationsPlugin.zonedSchedule(
      prayerTime.hashCode,
      'Jamat Reminder',
      '$prayerName Jamat is in $minutesBefore minutes!',
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'jamat_time_channel',
          'Jamat Time Reminders',
          channelDescription: 'Reminders for congregational prayer times',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
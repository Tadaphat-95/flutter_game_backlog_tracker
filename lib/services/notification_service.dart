import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // เริ่มต้น Notification Service
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // ขอ Permission (Android 13+)
  static Future<void> requestPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // แจ้งเตือนทันที
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'game_channel',
      'Game Notifications',
      channelDescription: 'การแจ้งเตือนเกม',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
  }

  // แจ้งเตือนตามเวลาที่กำหนด (รายวัน)
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'game_reminder_channel',
      'Game Reminders',
      channelDescription: 'เตือนให้เล่นเกม',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // ทำซ้ำรายวัน
    );
  }

  // แจ้งเตือนเกินเวลา
  static Future<void> scheduleTimeLimitNotification({
    required int id,
    required String gameName,
    required int hours,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'time_limit_channel',
      'Time Limit Alerts',
      channelDescription: 'แจ้งเตือนเล่นเกินเวลา',
      importance: Importance.max,
      priority: Priority.max,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledTime = tz.TZDateTime.now(tz.local).add(
      Duration(hours: hours),
    );

    await _notifications.zonedSchedule(
      id,
      '⚠️ เล่นเกินกำหนดแล้ว!',
      '$gameName — เล่นมา $hours ชั่วโมงแล้ว พักได้แล้วนะ!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ยกเลิกการแจ้งเตือน
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // ยกเลิกทั้งหมด
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // คำนวณเวลาถัดไปที่จะแจ้งเตือน
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
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
    return scheduled;
  }
}
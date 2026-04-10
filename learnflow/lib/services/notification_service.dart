// lib/services/notification_service.dart
// FIX: เพิ่ม getPendingCount() เพื่อให้ HomePage ตรวจสอบว่ามี reminder ตั้งอยู่หรือเปล่า

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS ||
       defaultTargetPlatform == TargetPlatform.macOS);

  static Future<void> init() async {
    if (!_isSupported || _initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    if (!_isSupported) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    }
  }

  // FIX: เพิ่ม method นี้เพื่อให้ HomePage ดึงจำนวน pending notifications
  static Future<int> getPendingCount() async {
    if (!_isSupported) return 0;
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.length;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isSupported) {
      debugPrint('[Notification] skipped: $title');
      return;
    }
    await _plugin.show(
      id, title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learnflow_channel', 'LearnFlow',
          channelDescription: 'LearnFlow quiz reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleDailyReminder() async {
    if (!_isSupported) return;
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, 9, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      100,
      'LearnFlow — ถึงเวลาฝึกทักษะแล้ว!',
      'อย่าลืมทำ Quiz วันนี้เพื่อรักษา Streak ของคุณ',
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learnflow_daily', 'Daily Reminder',
          channelDescription: 'LearnFlow daily study reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> notifyQuizResult({
    required int score,
    required int total,
    required String grade,
  }) async {
    await showNow(
      id: 200,
      title: 'ผลคะแนน Quiz ของคุณพร้อมแล้ว!',
      body: 'คะแนน $score/$total — เกรด $grade',
    );
  }

  static Future<void> cancelAll() async {
    if (!_isSupported) return;
    await _plugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    if (!_isSupported) return;
    await _plugin.cancel(id);
  }
}

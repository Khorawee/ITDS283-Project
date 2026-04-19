// lib/services/notification_service.dart
// FIX: ตั้งค่า local timezone อย่างถูกต้อง
// FIX: ใช้ inexactAllowWhileIdle แทน exactAllowWhileIdle เพื่อหลีกเลี่ยง permission ปัญหา

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

    // FIX: initialize timezones และ set local timezone เป็น Asia/Bangkok
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok')); // ← FIX หลัก

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
      // FIX: ขอ exact alarm permission ด้วย (Android 12+)
      await android?.requestExactAlarmsPermission();
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

    // FIX: ใช้ tz.local ที่ set เป็น Asia/Bangkok แล้ว
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);

    // ถ้าเวลา 09:00 ผ่านไปแล้ววันนี้ → schedule วันพรุ่งนี้
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      100,
      'LearnFlow — ถึงเวลาฝึกทักษะแล้ว!',
      'อย่าลืมทำ Quiz วันนี้เพื่อรักษา Streak ของคุณ',
      scheduled,
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
      // FIX: เปลี่ยนจาก exactAllowWhileIdle → inexactAllowWhileIdle
      // เพื่อหลีกเลี่ยง SCHEDULE_EXACT_ALARM permission ปัญหาบาง device
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat ทุกวัน
    );
  }

  // FIX: เพิ่ม method สำหรับ test notification ทันที (ใช้ debug)
  static Future<void> scheduleTestNotification() async {
    if (!_isSupported) return;
    final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    await _plugin.zonedSchedule(
      999,
      'LearnFlow Test 🔔',
      'การแจ้งเตือนทำงานปกติ!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learnflow_daily', 'Daily Reminder',
          channelDescription: 'LearnFlow daily study reminder',
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
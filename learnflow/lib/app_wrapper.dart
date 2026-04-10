// lib/app_wrapper.dart
// Global error handler — ดักจับ TokenExpiredException จากทุก page
// แล้ว redirect ไป login โดยอัตโนมัติ

import 'dart:async';
import 'package:flutter/material.dart';
import 'services/api_service.dart';

/// ครอบทุก page ที่ต้องเรียก API
/// วิธีใช้ใน page:
///
///   AppWrapper.run(context, () async {
///     final data = await SomeService.getData();
///     setState(() => _data = data);
///   });
///
class AppWrapper {
  /// รัน [action] — ถ้า TokenExpiredException → redirect login
  /// ถ้า TimeoutException → แสดง snackbar "ไม่สามารถเชื่อมต่อได้"
  /// ถ้า ApiException อื่น → แสดง snackbar message
  static Future<void> run(
    BuildContext context,
    Future<void> Function() action, {
    VoidCallback? onError,
  }) async {
    try {
      await action();
    } on TokenExpiredException {
      if (!context.mounted) return;
      // ล้าง stack และไปหน้า login
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      _showSnackbar(context, 'Session หมดอายุ กรุณา Login ใหม่');
    } on TimeoutException {
      if (!context.mounted) return;
      _showSnackbar(context, 'ไม่สามารถเชื่อมต่อ Server ได้ กรุณาลองใหม่');
      onError?.call();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      _showSnackbar(context, e.message);
      onError?.call();
    } catch (e) {
      if (!context.mounted) return;
      _showSnackbar(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่');
      onError?.call();
    }
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// lib/services/auth_service.dart
// Sync Firebase user → MySQL ผ่าน API หลัง login/register สำเร็จ

import 'api_service.dart';

class AuthService {
  /// เรียกหลัง Google Login สำเร็จ
  /// Flutter ส่ง Firebase token + name → API สร้าง/ดึง user ใน MySQL
  static Future<Map<String, dynamic>> syncGoogleLogin(String name) async {
    return await ApiService.post('/api/auth/login', {
      'name': name,
      'auth_provider': 'google',
    });
  }

  /// เรียกหลัง Email Register สำเร็จ
  /// Flutter ส่ง Firebase token + ข้อมูล user → API สร้าง user ใน MySQL
  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    String? birthDate, // format: YYYY-MM-DD
  }) async {
    return await ApiService.post('/api/auth/register', {
      'first_name': firstName,
      'last_name':  lastName,
      'phone':      phone,
      if (birthDate != null) 'birth_date': birthDate,
    });
  }
}

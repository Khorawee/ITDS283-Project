// lib/services/profile_service.dart

import 'api_service.dart';

class ProfileService {
  /// GET /api/profile — ดึงข้อมูล user + สถิติ
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/api/profile');
  }
}

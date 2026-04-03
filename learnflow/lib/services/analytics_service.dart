// lib/services/analytics_service.dart

import 'api_service.dart';

class AnalyticsService {
  /// GET /api/dashboard — ดึงข้อมูลกราฟ Bar/Line/Radar ทั้งหมด
  static Future<Map<String, dynamic>> getDashboard() async {
    return await ApiService.get('/api/dashboard');
  }

  /// GET /api/analysis — ดึง topic mastery รายวิชา
  static Future<List<Map<String, dynamic>>> getAnalysis() async {
    final data = await ApiService.get('/api/analysis');
    return List<Map<String, dynamic>>.from(data['topics']);
  }
}

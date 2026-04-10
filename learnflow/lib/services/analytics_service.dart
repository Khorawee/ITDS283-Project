// lib/services/analytics_service.dart
// FIX: getDashboard รับ days parameter เพื่อให้ time filter ทำงานจริง

import 'api_service.dart';

class AnalyticsService {
  /// GET /api/dashboard?days=7 — ดึงข้อมูลกราฟ Bar/Line/Radar
  // FIX: เพิ่ม days parameter ส่งไป API
  static Future<Map<String, dynamic>> getDashboard({int days = 7}) async {
    return await ApiService.get('/api/dashboard?days=$days');
  }

  /// GET /api/analysis — ดึง topic mastery รายวิชา
  static Future<List<Map<String, dynamic>>> getAnalysis() async {
    final data = await ApiService.get('/api/analysis');
    return List<Map<String, dynamic>>.from(data['topics']);
  }
}

// lib/services/recommendation_service.dart

import 'api_service.dart';

class RecommendationService {
  /// GET /api/recommendations — ดึง quiz แนะนำ (เรียงจาก mastery ต่ำสุด)
  static Future<List<Map<String, dynamic>>> getRecommendations() async {
    final data = await ApiService.get('/api/recommendations');
    return List<Map<String, dynamic>>.from(data['recommendations']);
  }
}

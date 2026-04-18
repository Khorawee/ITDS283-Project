/// lib/services/analytics_service.dart
/// API client สำหรับข้อมูล Analytics (Dashboard, Growth, Analysis)
/// 
/// Features:
/// - Dashboard: Bar/Radar charts + top topics (cached 5 min)
/// - Growth: All-time progress chart (cached 10 min)
/// - Analysis: Topic mastery by subject (cached 10 min)
/// - forceRefresh: bypass cache สำหรับ refresh manual

import 'api_service.dart';
import 'cache_service.dart';

class AnalyticsService {
  /// ดึง dashboard data (Bar/Radar charts) สำหรับ N วันที่ผ่านมา
  /// Cached per days value for 5 minutes
  static Future<Map<String, dynamic>> getDashboard({int days = 7, bool forceRefresh = false}) async {
    final cacheKey = 'dashboard_$days';
    if (forceRefresh) {
      CacheService.invalidate(cacheKey);
    }
    
    return await CacheService.getCached(
      cacheKey,
      () => ApiService.get('/api/dashboard?days=$days'),
      ttl: const Duration(minutes: 5),
    );
  }

  /// ดึง all-time progress สำหรับ Growth chart
  /// Cached for 10 minutes (growth data changes less frequently)
  static Future<Map<String, dynamic>> getGrowth({bool forceRefresh = false}) async {
    const cacheKey = 'growth';
    if (forceRefresh) {
      CacheService.invalidate(cacheKey);
    }
    
    return await CacheService.getCached(
      cacheKey,
      () => ApiService.get('/api/growth'),
      ttl: const Duration(minutes: 10),
    );
  }

  /// ดึง topic mastery breakdown รายวิชา (all-time)
  /// Cached for 10 minutes
  static Future<List<Map<String, dynamic>>> getAnalysis({bool forceRefresh = false}) async {
    const cacheKey = 'analysis';
    if (forceRefresh) {
      CacheService.invalidate(cacheKey);
    }
    
    final data = await CacheService.getCached(
      cacheKey,
      () => ApiService.get('/api/analysis'),
      ttl: const Duration(minutes: 10),
    );
    return List<Map<String, dynamic>>.from(data['topics']);
  }

  /// ล้าง analytics cache ทั้งหมด (call หลังจาก complete quiz)
  static void invalidateCache() {
    CacheService.invalidate('dashboard_1');
    CacheService.invalidate('dashboard_7');
    CacheService.invalidate('dashboard_14');
    CacheService.invalidate('dashboard_30');
    CacheService.invalidate('growth');
    CacheService.invalidate('analysis');
  }
}

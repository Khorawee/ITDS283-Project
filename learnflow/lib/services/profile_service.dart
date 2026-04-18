/// lib/services/profile_service.dart
/// API client สำหรับดึง user profile data
/// 
/// Features:
/// - getProfile: ดึง user profile + stats (cached 10 min)
/// - forceRefresh: bypass cache
/// - invalidateCache: clear profile cache (call หลังจาก update profile)

import 'api_service.dart';
import 'cache_service.dart';

class ProfileService {
  static const String _cacheKey = 'profile';

  /// ดึง user profile + quiz statistics
  /// Data is cached for 10 minutes by default
  static Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    if (forceRefresh) {
      CacheService.invalidate(_cacheKey);
    }
    
    return await CacheService.getCached(
      _cacheKey,
      () => ApiService.get('/api/profile'),
      ttl: const Duration(minutes: 10),
    );
  }

  /// ล้าง profile cache (call หลังจาก update profile)
  static void invalidateCache() {
    CacheService.invalidate(_cacheKey);
  }
}

/// lib/services/cache_service.dart
/// Generic in-memory caching service with TTL expiration
/// 
/// Features:
/// - getCached: return cached data หรือ fetch fresh
/// - invalidate: clear specific cache entry
/// - cleanup: remove expired entries
/// - Generic type-safe caching

class CachedData<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CachedData(this.data, {Duration? ttl}) 
    : timestamp = DateTime.now(),
      ttl = ttl ?? const Duration(minutes: 5);

  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class CacheService {
  static final Map<String, CachedData> _cache = {};

  /// ดึง cached data หรือ fetch fresh data ถ้า expired
  /// 
  /// Example:
  /// ```dart
  /// final profile = await CacheService.getCached(
  ///   'profile',
  ///   () => ProfileService.getProfile(),
  ///   ttl: Duration(minutes: 10),
  /// );
  /// ```
  static Future<T> getCached<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    // Return cached data if still valid
    if (_cache.containsKey(key)) {
      final cached = _cache[key];
      if (cached != null && !cached.isExpired && cached.data is T) {
        return cached.data as T;
      }
      // Remove expired cache
      _cache.remove(key);
    }

    // Fetch fresh data
    final data = await fetcher();
    
    // Cache the result
    _cache[key] = CachedData(data, ttl: ttl);
    
    return data;
  }

  /// ล้าง cache entry หนึ่งรายการ
  static void invalidate(String key) {
    _cache.remove(key);
  }

  /// ล้าง cache ทั้งหมด
  static void invalidateAll() {
    _cache.clear();
  }

  /// ดึง cache size (สำหรับ debugging)
  static int getCacheSize() {
    return _cache.length;
  }

  /// ล้าง expired entries
  static void cleanup() {
    _cache.removeWhere((_, cached) => cached.isExpired);
  }
}

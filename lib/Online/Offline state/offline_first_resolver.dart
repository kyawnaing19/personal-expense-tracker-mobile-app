import 'package:expense_tracker/cache-first/cache/local_cache_service.dart';
import 'package:expense_tracker/core/connectivity/connectivity_service.dart';

class OfflineFirstResult<T> {
  final T data;
  final bool isFromCache; 
  final DateTime? cachedAt;

  OfflineFirstResult({
    required this.data,
    required this.isFromCache,
    this.cachedAt,
  });
}

class NoCachedDataException implements Exception {
  final String message;
  NoCachedDataException([this.message = 'No internet connection and no cached data available.']);
  @override
  String toString() => message;
}

class OfflineFirstResolver {
  static Future<OfflineFirstResult<T>> load<T>({
    required String cacheKey,
    required Future<T> Function() fetchFromApi,
    required dynamic Function(T data) toJson,
    required T Function(dynamic json) fromJson,
    bool forceRefresh = false,
  }) async {
    final isOnline = await ConnectivityService.instance.checkConnection();

    if (isOnline) {
      try {
        final freshData = await fetchFromApi();
        await LocalCacheService.instance.save(cacheKey, toJson(freshData));
        return OfflineFirstResult<T>(
          data: freshData,
          isFromCache: false,
          cachedAt: DateTime.now(),
        );
      } catch (_) {
        return _loadFromCacheOrThrow<T>(cacheKey, fromJson);
      }
    } else {
      return _loadFromCacheOrThrow<T>(cacheKey, fromJson);
    }
  }

  static Future<OfflineFirstResult<T>> _loadFromCacheOrThrow<T>(
    String cacheKey,
    T Function(dynamic json) fromJson,
  ) async {
    final cachedJson = await LocalCacheService.instance.read(cacheKey);
    if (cachedJson == null) {
      throw NoCachedDataException();
    }
    final cachedAt = await LocalCacheService.instance.lastUpdated(cacheKey);
    return OfflineFirstResult<T>(
      data: fromJson(cachedJson),
      isFromCache: true,
      cachedAt: cachedAt,
    );
  }
}
import '../models/analytics_extra_bundle.dart';

/// In-memory cache for advanced analytics payloads keyed by search scope.
class AnalyticsCacheService {
  AnalyticsCacheService._();

  static final AnalyticsCacheService instance = AnalyticsCacheService._();

  static const maxAge = Duration(minutes: 30);

  final Map<String, AnalyticsExtraBundle> _cache = {};

  String keyFor({String? search, required bool global}) {
    if (global) return '__global__';
    final normalized = search?.trim().toLowerCase();
    return (normalized == null || normalized.isEmpty) ? '__empty__' : normalized;
  }

  AnalyticsExtraBundle? get(String key) {
    final bundle = _cache[key];
    if (bundle == null) return null;
    if (DateTime.now().difference(bundle.loadedAt) > maxAge) {
      _cache.remove(key);
      return null;
    }
    return bundle;
  }

  void put(AnalyticsExtraBundle bundle) {
    _cache[bundle.cacheKey] = bundle;
  }

  void invalidate(String key) => _cache.remove(key);

  void clear() => _cache.clear();
}

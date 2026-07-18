import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/services/analytics_cache_service.dart';
import 'package:journal_trend_analyzer/models/analytics_extra_bundle.dart';
import 'package:journal_trend_analyzer/models/advanced_analytics_data.dart';

void main() {
  tearDown(AnalyticsCacheService.instance.clear);

  test('cache key normalizes search topic', () {
    final cache = AnalyticsCacheService.instance;
    expect(
      cache.keyFor(search: ' Machine Learning ', global: false),
      'machine learning',
    );
    expect(cache.keyFor(search: null, global: true), '__global__');
  });

  test('cache returns bundle within max age', () {
    final cache = AnalyticsCacheService.instance;
    const key = 'ai';
    final bundle = AnalyticsExtraBundle(
      keywords: const [],
      authorScatter: const [],
      journalScatter: const [],
      emergingTrends: const {},
      topicEvolution: const {},
      advanced: AdvancedAnalyticsData.empty,
      cacheKey: key,
      loadedAt: DateTime.now(),
    );
    cache.put(bundle);
    expect(cache.get(key), bundle);
  });

  test('cache expires old bundle', () {
    final cache = AnalyticsCacheService.instance;
    const key = 'expired';
    cache.put(
      AnalyticsExtraBundle(
        keywords: const [],
        authorScatter: const [],
        journalScatter: const [],
        emergingTrends: const {},
        topicEvolution: const {},
        advanced: AdvancedAnalyticsData.empty,
        cacheKey: key,
        loadedAt: DateTime.now().subtract(const Duration(minutes: 31)),
      ),
    );
    expect(cache.get(key), isNull);
  });
}

import 'advanced_analytics_data.dart';
import 'analytics_catalog.dart';
import 'openalex_ranked_entity.dart';

/// Extra OpenAlex metrics loaded for Advanced Analytics (beyond PublicationProvider).
class AnalyticsExtraBundle {
  final List<OpenAlexRankedEntity> keywords;
  final List<ScatterPoint> authorScatter;
  final List<ScatterPoint> journalScatter;
  final Map<String, Map<int, int>> emergingTrends;
  final Map<String, Map<int, int>> topicEvolution;
  final AdvancedAnalyticsData advanced;
  final String cacheKey;
  final DateTime loadedAt;

  const AnalyticsExtraBundle({
    required this.keywords,
    required this.authorScatter,
    required this.journalScatter,
    required this.emergingTrends,
    required this.topicEvolution,
    required this.advanced,
    required this.cacheKey,
    required this.loadedAt,
  });

  static AnalyticsExtraBundle empty(String cacheKey) => AnalyticsExtraBundle(
        keywords: const [],
        authorScatter: const [],
        journalScatter: const [],
        emergingTrends: const {},
        topicEvolution: const {},
        advanced: AdvancedAnalyticsData.empty,
        cacheKey: cacheKey,
        loadedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
}

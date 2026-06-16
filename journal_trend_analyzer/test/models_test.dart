import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/advanced_analytics_data.dart';
import 'package:journal_trend_analyzer/models/analytics_catalog.dart';
import 'package:journal_trend_analyzer/models/openalex_ranked_entity.dart';
import 'package:journal_trend_analyzer/models/openalex_works_result.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/models/research_insight.dart';
import 'package:journal_trend_analyzer/models/search_filters.dart';

void main() {
  group('OpenAlexWorksResult', () {
    test('hasMore compares loaded count to OpenAlex total', () {
      const result = OpenAlexWorksResult(publications: [], totalOnOpenAlex: 100);
      expect(result.hasMore(50), isTrue);
      expect(result.hasMore(100), isFalse);
    });
  });

  group('OpenAlexRankedEntity', () {
    test('entry maps name to count', () {
      const entity = OpenAlexRankedEntity(id: 'A1', name: 'Alice', count: 42);
      expect(entity.entry.key, 'Alice');
      expect(entity.entry.value, 42);
    });
  });

  group('analytics catalog', () {
    test('lists 30 implemented analytics items', () {
      expect(analyticsCatalog, hasLength(30));
      expect(analyticsCatalog.first.no, 1);
      expect(analyticsCatalog.last.displayType, ChartDisplayType.dashboard);
      expect(analyticsCatalog.every((item) => item.status == AnalyticsStatus.implemented), isTrue);
    });

    test('chart point models hold coordinates', () {
      const scatter = ScatterPoint(label: 'Nature', x: 10, y: 20);
      const bubble = BubblePoint(label: 'MIT', x: 1, y: 2, size: 3);
      expect(scatter.label, 'Nature');
      expect(bubble.size, 3);
    });
  });

  group('AdvancedAnalyticsData', () {
    test('empty factory and graph helpers', () {
      expect(AdvancedAnalyticsData.empty.citationQuartiles, isEmpty);
      expect(const NetworkGraphData().isEmpty, isTrue);
      expect(
        const NetworkGraphData(nodes: ['A'], edges: [NetworkEdge(from: 'A', to: 'B')]).isEmpty,
        isFalse,
      );
      expect(const HeatmapData().isEmpty, isTrue);
      expect(
        const HeatmapData(rowLabels: ['R'], colLabels: ['C'], values: [
          [1.0],
        ]).isEmpty,
        isFalse,
      );
      const flow = SankeyFlow(source: 'A', target: 'B', value: 5);
      expect(flow.value, 5);
    });
  });

  group('research insight models', () {
    test('MomentumLevel labels', () {
      expect(MomentumLevel.high.label, 'HIGH');
      expect(MomentumLevel.declining.label, 'DECLINING');
    });

    test('TrendInsight.empty provides fallback copy', () {
      expect(TrendInsight.empty.headline, 'Insufficient data');
      expect(TrendInsight.empty.momentum, MomentumLevel.low);
    });

    test('TopicGrowthInsight formats growth and decline', () {
      const rising = TopicGrowthInsight(id: '1', name: 'AI', growthPercent: 12.4);
      const falling = TopicGrowthInsight(id: '2', name: 'Legacy', growthPercent: -3.2);
      expect(rising.formattedGrowth, '+12%');
      expect(falling.formattedGrowth, '-3%');
      expect(falling.isDeclining, isTrue);
    });

    test('TopicSnapshot and LandscapePulse hold summary fields', () {
      const snapshot = TopicSnapshot(
        topic: 'ML',
        totalPublications: 10,
        growthPercent: 5,
        peakYear: 2024,
        topJournal: 'Nature',
        momentum: MomentumLevel.medium,
        insightLine: 'Steady growth',
      );
      const pulse = LandscapePulse(
        totalPublications: 100,
        yoyGrowthPercent: 8,
        peakYear: 2024,
        averageCitations: 12.5,
        summary: 'Growing field',
      );
      expect(snapshot.topJournal, 'Nature');
      expect(pulse.averageCitations, 12.5);
    });
  });

  group('SearchFilters', () {
    test('isActive detects each filter type', () {
      expect(const SearchFilters(minCitations: 10).isActive, isTrue);
      expect(const SearchFilters(openAccessOnly: true).isActive, isTrue);
      expect(const SearchFilters(publicationType: 'article').isActive, isTrue);
      expect(const SearchFilters(publicationType: '').isActive, isFalse);
    });

    test('SearchSortOption labels are human readable', () {
      expect(SearchSortOption.oldest.label, 'Oldest');
      expect(SearchSortOption.alphabetical.apiValue, 'title:asc');
    });

    test('TopicComparisonResult stores comparison metrics', () {
      const result = TopicComparisonResult(
        topicA: 'AI',
        topicB: 'Robotics',
        publicationsA: 100,
        publicationsB: 80,
        avgCitationsA: 12,
        avgCitationsB: 9,
        authorsA: 50,
        authorsB: 40,
        journalsA: 20,
        journalsB: 15,
      );
      expect(result.publicationsA, 100);
      expect(result.topicB, 'Robotics');
    });
  });

  group('Publication helpers', () {
    test('readUrl prefers open access and pdf links', () {
      final paper = Publication(
        id: 'W1',
        title: 'Test',
        year: 2020,
        citations: 5,
        journal: 'IEEE',
        doi: '10.1/test',
        authorEntries: const [],
        abstractText: 'Abstract',
        openAccessUrl: 'https://oa.example/paper',
        pdfUrl: 'https://pdf.example/paper',
        landingPageUrl: 'https://publisher.example/paper',
      );

      expect(paper.readUrl, 'https://oa.example/paper');
      expect(paper.doiUrl, 'https://doi.org/10.1/test');
      expect(paper.openAlexUrl, 'W1');
    });
  });
}

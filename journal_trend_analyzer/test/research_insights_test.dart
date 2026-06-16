import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/openalex_ranked_entity.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/models/research_insight.dart';
import 'package:journal_trend_analyzer/utils/research_insights.dart';

void main() {
  group('ResearchInsights.analyzeTrend', () {
    test('returns empty insight when fewer than two years', () {
      final insight = ResearchInsights.analyzeTrend(volumeByYear: {2024: 10});
      expect(insight, TrendInsight.empty);
    });

    test('computes growth and momentum for rising trend', () {
      final insight = ResearchInsights.analyzeTrend(
        volumeByYear: {
          2019: 100,
          2020: 120,
          2021: 150,
          2022: 180,
          2023: 220,
          2024: 300,
        },
        topicLabel: 'Artificial Intelligence',
      );

      expect(insight.periodGrowthPercent, 200);
      expect(insight.peakYear, 2024);
      expect(insight.momentum, isNot(MomentumLevel.declining));
      expect(insight.headline, contains('Artificial Intelligence'));
    });

    test('builds declining headline when volume falls', () {
      final insight = ResearchInsights.analyzeTrend(
        volumeByYear: {2020: 300, 2021: 250, 2022: 180, 2023: 120},
        topicLabel: 'Legacy Systems',
      );

      expect(insight.periodGrowthPercent, lessThan(0));
      expect(insight.headline, contains('cooled'));
    });

    test('notes quantity inflation when volume outpaces citations', () {
      final insight = ResearchInsights.analyzeTrend(
        volumeByYear: {2020: 100, 2021: 130, 2022: 160, 2023: 200},
        citationsByYear: {2020: 1000, 2021: 950, 2022: 900, 2023: 850},
      );

      expect(
        insight.citationNote,
        contains('Paper volume is rising faster than citations'),
      );
    });

    test('notes high-quality signal when citations outpace volume', () {
      final insight = ResearchInsights.analyzeTrend(
        volumeByYear: {2020: 100, 2021: 102, 2022: 105, 2023: 108},
        citationsByYear: {2020: 100, 2021: 150, 2022: 220, 2023: 300},
      );

      expect(
        insight.citationNote,
        contains('Fewer papers but rising citations'),
      );
    });
  });

  group('ResearchInsights helpers', () {
    test('computeConceptGrowth compares early and late periods', () {
      final growth = ResearchInsights.computeConceptGrowth({
        2018: 10,
        2019: 12,
        2020: 14,
        2021: 40,
        2022: 50,
        2023: 60,
      });

      expect(growth, greaterThan(100));
    });

    test('computeConceptGrowth handles short timelines', () {
      final growth = ResearchInsights.computeConceptGrowth({2020: 10, 2023: 20});
      expect(growth, 100);
    });

    test('buildLandscapePulse wraps trend summary', () {
      final pulse = ResearchInsights.buildLandscapePulse(
        totalPublications: 500,
        volumeByYear: {2022: 100, 2023: 150, 2024: 200},
        averageCitations: 12.5,
      );

      expect(pulse.totalPublications, 500);
      expect(pulse.averageCitations, 12.5);
      expect(pulse.summary, isNotEmpty);
    });

    test('buildTopicSnapshot includes top journal name', () {
      final snapshot = ResearchInsights.buildTopicSnapshot(
        topic: 'Robotics',
        totalPublications: 80,
        volumeByYear: {2022: 20, 2023: 40, 2024: 60},
        citationsByYear: {2022: 200, 2023: 300, 2024: 500},
        topJournal: const OpenAlexRankedEntity(id: 'J1', name: 'Science Robotics', count: 12),
      );

      expect(snapshot.topic, 'Robotics');
      expect(snapshot.topJournal, 'Science Robotics');
    });

    test('formatGrowth adds sign prefix', () {
      expect(ResearchInsights.formatGrowth(12.6), '+13%');
      expect(ResearchInsights.formatGrowth(-4.2), '-4%');
    });
  });

  group('ResearchInsights copy helpers', () {
    test('influentialPapersInsight handles empty and landmark papers', () {
      expect(
        ResearchInsights.influentialPapersInsight([]),
        contains('will appear once OpenAlex data loads'),
      );

      final landmark = Publication(
        id: '1',
        title: 'Classic',
        year: 2000,
        citations: 60000,
        journal: 'Nature',
        doi: '',
        authorEntries: const [],
        abstractText: '',
      );
      expect(
        ResearchInsights.influentialPapersInsight([landmark]),
        contains('Landmark papers'),
      );

      final regular = Publication(
        id: '2',
        title: 'Recent',
        year: 2024,
        citations: 120,
        journal: 'IEEE Access',
        doi: '',
        authorEntries: const [],
        abstractText: '',
      );
      expect(
        ResearchInsights.influentialPapersInsight([regular]),
        contains('IEEE Access'),
      );
    });

    test('researchLeadersInsight and journalPowerInsight', () {
      expect(
        ResearchInsights.researchLeadersInsight([]),
        contains('Leading researchers appear'),
      );
      expect(
        ResearchInsights.researchLeadersInsight([
          const OpenAlexRankedEntity(id: 'A1', name: 'Alice', count: 1200),
        ]),
        contains('Alice'),
      );

      expect(
        ResearchInsights.journalPowerInsight([]),
        contains('Top publishing venues'),
      );
      expect(
        ResearchInsights.journalPowerInsight([
          const OpenAlexRankedEntity(id: 'J1', name: 'Nature', count: 50),
        ]),
        contains('dominant publishing venue'),
      );
      expect(
        ResearchInsights.journalPowerInsight([
          const OpenAlexRankedEntity(id: 'J1', name: 'Nature', count: 50),
          const OpenAlexRankedEntity(id: 'J2', name: 'Science', count: 40),
        ]),
        contains('Nature and Science'),
      );
    });
  });
}

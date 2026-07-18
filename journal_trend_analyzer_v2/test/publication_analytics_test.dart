import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/models/publication_author.dart';
import 'package:journal_trend_analyzer/utils/publication_analytics.dart';

void main() {
  group('PublicationAnalytics', () {
    final sample = [
      Publication(
        id: '1',
        title: 'Paper A',
        year: 2020,
        citations: 100,
        journal: 'Nature',
        doi: '',
        authorEntries: const [
          PublicationAuthor(id: 'A1', name: 'Alice'),
          PublicationAuthor(id: 'A2', name: 'Bob'),
        ],
        abstractText: '',
        concepts: ['Artificial intelligence', 'Machine learning'],
      ),
      Publication(
        id: '2',
        title: 'Paper B',
        year: 2021,
        citations: 50,
        journal: 'Nature',
        doi: '',
        authorEntries: const [
          PublicationAuthor(id: 'A1', name: 'Alice'),
        ],
        abstractText: '',
        concepts: ['Artificial intelligence'],
      ),
      Publication(
        id: '3',
        title: 'Paper C',
        year: 2020,
        citations: 200,
        journal: 'IEEE Access',
        doi: '',
        authorEntries: const [
          PublicationAuthor(id: 'A3', name: 'Carol'),
        ],
        abstractText: '',
        concepts: ['Data science'],
      ),
    ];

    test('groups by year and ranks top entities', () {
      expect(PublicationAnalytics.groupByYear(sample), {2020: 2, 2021: 1});
      expect(PublicationAnalytics.topJournals(sample).first.key, 'Nature');
      expect(PublicationAnalytics.topAuthors(sample).first.key, 'Alice');
      expect(
        PublicationAnalytics.mostInfluentialPaper(sample).title,
        'Paper C',
      );
      expect(
        PublicationAnalytics.topResearchAreas(sample).first.key,
        'Artificial intelligence',
      );
    });

    test('computes citation metrics and year helpers', () {
      expect(PublicationAnalytics.averageCitation(sample), closeTo(116.67, 0.01));
      expect(PublicationAnalytics.mostActiveYear(sample), '2020');
      expect(PublicationAnalytics.citationsByYear(sample), {2020: 300, 2021: 50});
      expect(PublicationAnalytics.averageCitationsByYear(sample), {2020: 150, 2021: 50});
    });

    test('papersForYear sorts by citations descending', () {
      final papers = PublicationAnalytics.papersForYear(sample, 2020);
      expect(papers.map((paper) => paper.title).toList(), ['Paper C', 'Paper A']);
    });

    test('topResearchAreasForYear limits concepts for a year', () {
      final areas = PublicationAnalytics.topResearchAreasForYear(sample, 2021);
      expect(areas.first.key, 'Artificial intelligence');
    });

    test('topPapers deduplicates by id and respects limit', () {
      final duplicate = [
        ...sample,
        Publication(
          id: '1',
          title: 'Paper A duplicate',
          year: 2022,
          citations: 999,
          journal: 'Nature',
          doi: '',
          authorEntries: const [],
          abstractText: '',
        ),
      ];
      final top = PublicationAnalytics.topPapers(duplicate, limit: 2);
      expect(top, hasLength(2));
      expect(top.first.citations, 999);
    });

    test('ignores unknown journal and author labels', () {
      expect(
        PublicationAnalytics.topJournals([
          Publication(
            id: 'x',
            title: 'Unknown venue',
            year: 2020,
            citations: 1,
            journal: 'Unknown Journal',
            doi: '',
            authorEntries: const [],
            abstractText: '',
          ),
        ]),
        isEmpty,
      );
      expect(
        PublicationAnalytics.topAuthors([
          Publication(
            id: 'y',
            title: 'Unknown author',
            year: 2020,
            citations: 1,
            journal: 'IEEE',
            doi: '',
            authorEntries: const [
              PublicationAuthor(id: 'U', name: 'Unknown Author'),
            ],
            abstractText: '',
          ),
        ]),
        isEmpty,
      );
      expect(
        PublicationAnalytics.groupByYear([
          Publication(
            id: 'z',
            title: 'No year',
            year: 0,
            citations: 0,
            journal: 'IEEE',
            doi: '',
            authorEntries: const [],
            abstractText: '',
          ),
        ]),
        isEmpty,
      );
      expect(PublicationAnalytics.averageCitation([]), 0);
      expect(PublicationAnalytics.mostActiveYear([]), 'N/A');
    });
  });
}

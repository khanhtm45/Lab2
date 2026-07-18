/// Search filters for publication queries.
class SearchFilters {
  final int? yearFrom;
  final int? yearTo;
  final int? minCitations;
  final bool? openAccessOnly;
  final Set<String> publicationTypes;

  const SearchFilters({
    this.yearFrom,
    this.yearTo,
    this.minCitations,
    this.openAccessOnly,
    this.publicationTypes = const {},
  });

  /// Legacy single-year accessor.
  int? get publicationYear =>
      yearFrom != null && yearFrom == yearTo ? yearFrom : null;

  /// Legacy single-type accessor.
  String? get publicationType =>
      publicationTypes.length == 1 ? publicationTypes.first : null;

  bool get isActive =>
      yearFrom != null ||
      yearTo != null ||
      minCitations != null ||
      openAccessOnly == true ||
      publicationTypes.isNotEmpty;
}

enum SearchSortOption {
  relevance('relevance_score:desc', 'Relevance'),
  mostCited('cited_by_count:desc', 'Most Cited'),
  newest('publication_year:desc', 'Newest'),
  oldest('publication_year:asc', 'Oldest'),
  alphabetical('title:asc', 'A-Z');

  const SearchSortOption(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class TopicComparisonResult {
  final String topicA;
  final String topicB;
  final int publicationsA;
  final int publicationsB;
  final double avgCitationsA;
  final double avgCitationsB;
  final int authorsA;
  final int authorsB;
  final int journalsA;
  final int journalsB;
  final String topCountryA;
  final String topCountryB;
  final String topJournalNameA;
  final String topJournalNameB;
  final int peakYearA;
  final int peakYearB;

  const TopicComparisonResult({
    required this.topicA,
    required this.topicB,
    required this.publicationsA,
    required this.publicationsB,
    required this.avgCitationsA,
    required this.avgCitationsB,
    required this.authorsA,
    required this.authorsB,
    required this.journalsA,
    required this.journalsB,
    this.topCountryA = '',
    this.topCountryB = '',
    this.topJournalNameA = '',
    this.topJournalNameB = '',
    this.peakYearA = 0,
    this.peakYearB = 0,
  });
}

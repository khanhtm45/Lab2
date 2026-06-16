/// Bộ lọc tìm kiếm publication theo spec SCREEN.md
class SearchFilters {
  final int? publicationYear;
  final int? minCitations;
  final bool? openAccessOnly;
  final String? publicationType;

  const SearchFilters({
    this.publicationYear,
    this.minCitations,
    this.openAccessOnly,
    this.publicationType,
  });

  bool get isActive =>
      publicationYear != null ||
      minCitations != null ||
      openAccessOnly == true ||
      (publicationType != null && publicationType!.isNotEmpty);
}

enum SearchSortOption {
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
  });
}

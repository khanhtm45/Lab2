import 'openalex_ranked_entity.dart';

/// Author ranking row enriched with citations and institution from OpenAlex.
class RankedAuthorEntry {
  final OpenAlexRankedEntity entity;
  final int publicationCount;
  final int citationCount;
  final String institution;

  const RankedAuthorEntry({
    required this.entity,
    required this.publicationCount,
    required this.citationCount,
    required this.institution,
  });

  String get id => entity.id;
  String get name => entity.name;
}

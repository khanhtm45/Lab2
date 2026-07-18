import '../models/publication.dart';

class YearActivitySnapshot {
  final int publicationCount;
  final double averageCitations;
  final String topJournal;
  final String topResearchArea;
  final Publication? topPublication;

  const YearActivitySnapshot({
    required this.publicationCount,
    required this.averageCitations,
    required this.topJournal,
    required this.topResearchArea,
    this.topPublication,
  });
}

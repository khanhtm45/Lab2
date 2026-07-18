class AuthorProfile {
  final String name;
  final String institution;
  final String? orcid;
  final String openAlexId;
  final List<String> researchAreas;
  final int publicationCount;
  final int citationCount;
  final double averageCitations;

  const AuthorProfile({
    required this.name,
    required this.institution,
    this.orcid,
    required this.openAlexId,
    required this.researchAreas,
    required this.publicationCount,
    required this.citationCount,
    required this.averageCitations,
  });

  static AuthorProfile fallback({
    required String name,
    required String openAlexId,
    int publicationCount = 0,
  }) {
    return AuthorProfile(
      name: name,
      institution: 'N/A',
      openAlexId: openAlexId,
      researchAreas: const [],
      publicationCount: publicationCount,
      citationCount: 0,
      averageCitations: 0,
    );
  }
}

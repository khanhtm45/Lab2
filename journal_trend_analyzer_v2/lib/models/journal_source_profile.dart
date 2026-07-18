class JournalSourceProfile {
  final String name;
  final String publisher;
  final String sourceType;
  final String issn;

  const JournalSourceProfile({
    required this.name,
    required this.publisher,
    required this.sourceType,
    required this.issn,
  });

  static const empty = JournalSourceProfile(
    name: '',
    publisher: 'N/A',
    sourceType: 'Journal',
    issn: 'N/A',
  );
}

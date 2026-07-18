class JournalVolume {
  final String id;
  final String volumeNumber;
  final String issueNumber;
  final String year;
  final String title;
  final DateTime publishedDate;
  final int articleCount;
  final List<VolumeArticle> articles;
  
  const JournalVolume({
    required this.id,
    required this.volumeNumber,
    required this.issueNumber,
    required this.year,
    required this.title,
    required this.publishedDate,
    required this.articleCount,
    required this.articles,
  });
  
  factory JournalVolume.fromJson(Map<String, dynamic> json) {
    return JournalVolume(
      id: json['id'] ?? '',
      volumeNumber: json['volume_number']?.toString() ?? '',
      issueNumber: json['issue_number']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      title: json['title'] ?? '',
      publishedDate: DateTime.tryParse(json['published_date'] ?? '') ?? DateTime.now(),
      articleCount: json['article_count'] ?? 0,
      articles: (json['articles'] as List<dynamic>?)
          ?.map((article) => VolumeArticle.fromJson(article))
          .toList() ?? [],
    );
  }
  
  // Mock data cho testing
  static List<JournalVolume> getMockVolumes(String journalName) {
    return [
      JournalVolume(
        id: '1',
        volumeNumber: '45',
        issueNumber: '12',
        year: '2024',
        title: '$journalName - Volume 45, Issue 12',
        publishedDate: DateTime(2024, 12, 1),
        articleCount: 15,
        articles: VolumeArticle.getMockArticles(),
      ),
      JournalVolume(
        id: '2',
        volumeNumber: '45',
        issueNumber: '11',
        year: '2024',
        title: '$journalName - Volume 45, Issue 11',
        publishedDate: DateTime(2024, 11, 1),
        articleCount: 18,
        articles: VolumeArticle.getMockArticles(),
      ),
      JournalVolume(
        id: '3',
        volumeNumber: '45',
        issueNumber: '10',
        year: '2024',
        title: '$journalName - Volume 45, Issue 10',
        publishedDate: DateTime(2024, 10, 1),
        articleCount: 12,
        articles: VolumeArticle.getMockArticles(),
      ),
    ];
  }
}

class VolumeArticle {
  final String id;
  final String title;
  final List<String> authors;
  final String abstractText;
  final DateTime publishedDate;
  final int citationCount;
  final String doi;
  final List<String> keywords;
  
  const VolumeArticle({
    required this.id,
    required this.title,
    required this.authors,
    required this.abstractText,
    required this.publishedDate,
    required this.citationCount,
    required this.doi,
    required this.keywords,
  });
  
  factory VolumeArticle.fromJson(Map<String, dynamic> json) {
    return VolumeArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      abstractText: json['abstract'] ?? '',
      publishedDate: DateTime.tryParse(json['published_date'] ?? '') ?? DateTime.now(),
      citationCount: json['citation_count'] ?? 0,
      doi: json['doi'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }
  
  // Mock data cho testing
  static List<VolumeArticle> getMockArticles() {
    return [
      VolumeArticle(
        id: '1',
        title: 'Advanced Machine Learning Algorithms for Predictive Analytics',
        authors: ['Dr. John Smith', 'Prof. Jane Doe', 'Dr. Mike Johnson'],
        abstractText: 'This paper presents novel machine learning algorithms that significantly improve predictive accuracy in large-scale data analytics applications...',
        publishedDate: DateTime(2024, 12, 15),
        citationCount: 45,
        doi: '10.1234/journal.2024.001',
        keywords: ['Machine Learning', 'Predictive Analytics', 'Big Data'],
      ),
      VolumeArticle(
        id: '2',
        title: 'Cybersecurity Framework for IoT Devices in Smart Cities',
        authors: ['Dr. Alice Brown', 'Prof. Bob Wilson'],
        abstractText: 'A comprehensive cybersecurity framework designed specifically for Internet of Things devices deployed in smart city infrastructure...',
        publishedDate: DateTime(2024, 12, 10),
        citationCount: 23,
        doi: '10.1234/journal.2024.002',
        keywords: ['Cybersecurity', 'IoT', 'Smart Cities'],
      ),
      VolumeArticle(
        id: '3',
        title: 'Blockchain-Based Data Integrity in Distributed Systems',
        authors: ['Dr. Carol Davis', 'Dr. David Lee', 'Prof. Eve Miller'],
        abstractText: 'This research explores the application of blockchain technology to ensure data integrity in large-scale distributed computing systems...',
        publishedDate: DateTime(2024, 12, 5),
        citationCount: 67,
        doi: '10.1234/journal.2024.003',
        keywords: ['Blockchain', 'Data Integrity', 'Distributed Systems'],
      ),
      VolumeArticle(
        id: '4',
        title: 'Natural Language Processing for Automated Code Review',
        authors: ['Dr. Frank Chen', 'Prof. Grace Wang'],
        abstractText: 'An innovative approach using natural language processing techniques to automate code review processes in software development...',
        publishedDate: DateTime(2024, 11, 28),
        citationCount: 34,
        doi: '10.1234/journal.2024.004',
        keywords: ['NLP', 'Code Review', 'Software Engineering'],
      ),
      VolumeArticle(
        id: '5',
        title: 'Edge Computing Optimization for Real-Time Applications',
        authors: ['Dr. Henry Kim', 'Dr. Ivy Zhang', 'Prof. Jack Liu'],
        abstractText: 'This paper presents optimization strategies for edge computing architectures to support real-time application requirements...',
        publishedDate: DateTime(2024, 11, 20),
        citationCount: 56,
        doi: '10.1234/journal.2024.005',
        keywords: ['Edge Computing', 'Real-Time', 'Optimization'],
      ),
    ];
  }
}
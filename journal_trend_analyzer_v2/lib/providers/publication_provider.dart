import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/author_profile.dart';
import '../models/journal_source_profile.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/openalex_works_result.dart';
import '../models/publication.dart';
import '../models/ranked_author_entry.dart';
import '../models/recent_search_entry.dart';
import '../models/search_filters.dart';
import '../models/year_activity_snapshot.dart';
import '../models/research_insight.dart';
import '../services/app_preferences.dart';
import '../services/openalex_config.dart';
import '../services/openalex_exception.dart';
import '../services/openalex_service.dart';
import '../services/recent_searches_service.dart';
import '../services/bookmarked_topics_service.dart';
import '../utils/count_format.dart';
import '../utils/research_insights.dart';

enum AnalysisScope { global, topic }

class PublicationProvider extends ChangeNotifier {
  PublicationProvider({
    required OpenAlexConfig config,
    AppPreferences? preferences,
  })  : _config = config,
        _preferences = preferences,
        _openAlexService = OpenAlexService(config, preferences: preferences),
        _recentSearchesService = RecentSearchesService(),
        _bookmarkedTopicsService = BookmarkedTopicsService() {
    if (preferences != null) {
      preferences.addListener(notifyListeners);
      applyAppPreferences(preferences);
    }
  }

  final OpenAlexConfig _config;
  final AppPreferences? _preferences;
  final OpenAlexService _openAlexService;
  final RecentSearchesService _recentSearchesService;
  final BookmarkedTopicsService _bookmarkedTopicsService;

  static const globalTopicLabel = 'Global Research Overview';

  AnalysisScope scope = AnalysisScope.global;
  String currentTopic = globalTopicLabel;
  List<Publication> publications = [];
  List<Publication> topPapersOpenAlex = [];
  Map<int, int> yearlyTrendFromOpenAlex = {};
  Map<int, int> citationsByYearOpenAlex = {};
  Map<int, int> avgCitationsByYearOpenAlex = {};
  List<OpenAlexRankedEntity> topAuthorsOpenAlex = [];
  List<OpenAlexRankedEntity> topJournalsOpenAlex = [];
  List<OpenAlexRankedEntity> topResearchAreasOpenAlex = [];
  List<OpenAlexRankedEntity> topKeywordsOpenAlex = [];
  List<OpenAlexRankedEntity> topInstitutionsOpenAlex = [];
  List<OpenAlexRankedEntity> topCountriesOpenAlex = [];
  Map<String, int> typeDistribution = {};
  Map<String, int> oaDistribution = {};
  Map<String, int> languageDistribution = {};
  List<TopicGrowthInsight> growingTopicsOpenAlex = [];
  List<RecentSearchEntry> recentSearches = [];
  List<String> bookmarkedTopics = [];
  SearchFilters searchFilters = const SearchFilters();
  SearchSortOption searchSort = SearchSortOption.mostCited;
  double averageCitationOpenAlex = 0;
  int totalOnOpenAlex = 0;
  bool isDashboardLoading = false;
  bool isSearchLoading = false;
  bool isTrendLoading = false;
  bool isLoadingMorePublications = false;
  bool searchHasMore = false;
  int searchListPage = 0;
  String? errorMessage;
  int? errorStatusCode;

  int _searchGeneration = 0;

  bool get isLoading =>
      isDashboardLoading || isSearchLoading || isTrendLoading;
  bool get hasData =>
      totalOnOpenAlex > 0 ||
      yearlyTrendFromOpenAlex.isNotEmpty ||
      topPapersOpenAlex.isNotEmpty;
  bool get isGlobalScope => scope == AnalysisScope.global;
  bool get hasRealTrend => yearlyTrendFromOpenAlex.isNotEmpty;

  List<OpenAlexRankedEntity> get rankedAuthors => topAuthorsOpenAlex;
  List<OpenAlexRankedEntity> get rankedJournals => topJournalsOpenAlex;
  List<OpenAlexRankedEntity> get trendingAreas => topResearchAreasOpenAlex;

  String get formattedTotalOnOpenAlex => formatOpenAlexCount(totalOnOpenAlex);

  AppStrings get _strings =>
      AppStrings(_preferences?.language ?? AppLanguage.english);

  TrendInsight get trendInsight => ResearchInsights.analyzeTrend(
        strings: _strings,
        volumeByYear: yearlyTrendFromOpenAlex,
        citationsByYear: citationsByYearOpenAlex,
        topicLabel: isGlobalScope ? _strings.globalResearch : currentTopic,
      );

  LandscapePulse get landscapePulse => ResearchInsights.buildLandscapePulse(
        strings: _strings,
        totalPublications: totalOnOpenAlex,
        volumeByYear: yearlyTrendFromOpenAlex,
        averageCitations: averageCitationOpenAlex,
      );

  TopicSnapshot? get topicSnapshot {
    if (isGlobalScope) return null;
    return ResearchInsights.buildTopicSnapshot(
      strings: _strings,
      topic: currentTopic,
      totalPublications: totalOnOpenAlex,
      volumeByYear: yearlyTrendFromOpenAlex,
      citationsByYear: citationsByYearOpenAlex,
      topJournal: topJournalsOpenAlex.isEmpty ? null : topJournalsOpenAlex.first,
    );
  }

  String get influentialPapersInsight =>
      ResearchInsights.influentialPapersInsight(_strings, topPapersOpenAlex);

  String get researchLeadersInsight =>
      ResearchInsights.researchLeadersInsight(_strings, topAuthorsOpenAlex);

  String get journalPowerInsight =>
      ResearchInsights.journalPowerInsight(_strings, topJournalsOpenAlex);

  String get topJournalLabel =>
      topJournalsOpenAlex.isEmpty ? _strings.na : topJournalsOpenAlex.first.name;

  String get topAuthorLabel =>
      topAuthorsOpenAlex.isEmpty ? _strings.na : topAuthorsOpenAlex.first.name;

  String get topPaperLabel => topPapersOpenAlex.isEmpty
      ? _strings.na
      : topPapersOpenAlex.first.title;

  String get topTopicLabel => topResearchAreasOpenAlex.isEmpty
      ? _strings.na
      : topResearchAreasOpenAlex.first.name;

  void updateSearchFilters(SearchFilters filters) {
    searchFilters = filters;
    notifyListeners();
  }

  void updateSearchSort(SearchSortOption sort) {
    searchSort = sort;
    notifyListeners();
  }

  Map<int, int> yearlyTrendForRange(int? yearsBack) {
    if (yearsBack == null) return yearlyTrendFromOpenAlex;
    final cutoff = DateTime.now().year - yearsBack + 1;
    return Map.fromEntries(
      yearlyTrendFromOpenAlex.entries.where((e) => e.key >= cutoff),
    );
  }

  Map<int, int> citationsForRange(int? yearsBack) {
    if (yearsBack == null) return citationsByYearOpenAlex;
    final cutoff = DateTime.now().year - yearsBack + 1;
    return Map.fromEntries(
      citationsByYearOpenAlex.entries.where((e) => e.key >= cutoff),
    );
  }

  String get mostActiveYearLabel {
    if (yearlyTrendFromOpenAlex.isEmpty) return _strings.na;
    final peak = yearlyTrendFromOpenAlex.entries
        .reduce((a, b) => a.value >= b.value ? a : b);
    return '${peak.key} (${formatOpenAlexCount(peak.value)})';
  }

  OpenAlexRankedEntity? rankedAuthorByName(String name) {
    for (final author in topAuthorsOpenAlex) {
      if (author.name == name) return author;
    }
    return null;
  }

  OpenAlexRankedEntity? rankedJournalByName(String name) {
    for (final journal in topJournalsOpenAlex) {
      if (journal.name == name) return journal;
    }
    return null;
  }

  Future<void> loadDefaultDashboard() async {
    isDashboardLoading = true;
    isTrendLoading = true;
    _clearError();
    publications = [];
    notifyListeners();

    try {
      scope = AnalysisScope.global;
      currentTopic = globalTopicLabel;

      totalOnOpenAlex = await _openAlexService.fetchWorksTotalCount(
        globalInfluential: true,
      );
      isDashboardLoading = false;
      notifyListeners();

      await _loadAllOpenAlexMetrics(globalInfluential: true);
    } catch (e) {
      _clearAllData();
      _captureError(e);
    } finally {
      isDashboardLoading = false;
      isTrendLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPublications(String topic) async {
    final generation = ++_searchGeneration;
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return;

    if (_preferences?.saveRecentSearches ?? true) {
      recentSearches = await _recentSearchesService.add(trimmed);
    }

    isSearchLoading = true;
    scope = AnalysisScope.topic;
    currentTopic = trimmed;
    _clearError();
    searchListPage = 0;
    searchHasMore = false;
    publications = [];
    _clearTopicMetrics();
    notifyListeners();

    try {
      final works = await _openAlexService.fetchSearchPage(
        trimmed,
        page: 1,
        filters: searchFilters,
        sort: searchSort,
      );
      if (generation != _searchGeneration) return;

      publications = works.publications;
      totalOnOpenAlex = works.totalOnOpenAlex;
      searchListPage = 1;
      searchHasMore = works.hasMore(publications.length);
    } catch (e) {
      if (generation != _searchGeneration) return;

      _clearAllData();
      _captureError(e);
    } finally {
      if (generation == _searchGeneration) {
        isSearchLoading = false;
        notifyListeners();
      }
    }

    if (generation != _searchGeneration) return;
    _loadSearchMetricsInBackground(trimmed, generation);
  }

  Future<void> loadRecentSearches() async {
    recentSearches = await _recentSearchesService.load();
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    recentSearches = await _recentSearchesService.clear();
    notifyListeners();
  }

  Future<void> removeRecentSearch(String topic) async {
    recentSearches = await _recentSearchesService.remove(topic);
    notifyListeners();
  }

  Future<void> loadBookmarkedTopics() async {
    bookmarkedTopics = await _bookmarkedTopicsService.load();
    notifyListeners();
  }

  bool isTopicBookmarked(String topic) =>
      _bookmarkedTopicsService.isBookmarked(bookmarkedTopics, topic);

  Future<void> toggleBookmarkTopic(String topic) async {
    bookmarkedTopics = await _bookmarkedTopicsService.toggle(topic);
    notifyListeners();
  }

  Future<void> removeBookmarkedTopic(String topic) async {
    bookmarkedTopics = await _bookmarkedTopicsService.remove(topic);
    notifyListeners();
  }

  Future<void> clearBookmarkedTopics() async {
    bookmarkedTopics = await _bookmarkedTopicsService.clear();
    notifyListeners();
  }

  void applyAppPreferences(AppPreferences prefs) {
    searchSort = prefs.defaultSort;
    notifyListeners();
  }

  Future<void> clearLocalCache() async {
    publications = [];
    _clearTopicMetrics();
    _clearError();
    notifyListeners();

    if (isGlobalScope) {
      await loadDefaultDashboard();
    } else if (currentTopic != globalTopicLabel) {
      await searchPublications(currentTopic);
    }
  }

  OpenAlexConfig get openAlexConfig => _config;

  OpenAlexService get openAlexService => _openAlexService;

  Future<void> saveOpenAlexApiKey(String key) async {
    await _config.saveKey(key);
    notifyListeners();
  }

  Future<void> clearOpenAlexApiKey() async {
    await _config.clearSavedKey();
    notifyListeners();
  }

  Future<bool> testOpenAlexConnection() {
    return _openAlexService.testConnection();
  }

  void _loadSearchMetricsInBackground(String topic, int generation) {
    isTrendLoading = true;
    notifyListeners();

    _loadAllOpenAlexMetrics(search: topic).then((_) {
      if (generation != _searchGeneration) return;
      isTrendLoading = false;
      notifyListeners();
    }).catchError((_) {
      if (generation != _searchGeneration) return;
      isTrendLoading = false;
      notifyListeners();
    });
  }

  bool get isTopicInsightsReady => !isGlobalScope && !isTrendLoading;

  Future<void> loadMoreSearchPublications() async {
    if (!searchHasMore || isLoadingMorePublications || isGlobalScope) return;

    final generation = _searchGeneration;
    isLoadingMorePublications = true;
    notifyListeners();

    try {
      final nextPage = searchListPage + 1;
      final works = await _openAlexService.fetchSearchPage(
        currentTopic,
        page: nextPage,
        filters: searchFilters,
        sort: searchSort,
      );
      if (generation != _searchGeneration) return;

      publications = [...publications, ...works.publications];
      searchListPage = nextPage;
      searchHasMore = works.hasMore(publications.length);
    } catch (e) {
      if (generation != _searchGeneration) return;
      _captureError(e);
    } finally {
      if (generation == _searchGeneration) {
        isLoadingMorePublications = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshCurrentAnalysis() async {
    if (isGlobalScope) {
      await loadDefaultDashboard();
    } else {
      await searchPublications(currentTopic);
    }
  }

  Future<List<Publication>> loadPublicationsForYear(int year) {
    if (isGlobalScope) {
      return _openAlexService.fetchPublicationsForYear(
        year: year,
        globalInfluential: true,
      );
    }
    return _openAlexService.fetchPublicationsForYear(
      year: year,
      search: currentTopic,
    );
  }

  Future<OpenAlexWorksResult> loadPublicationsForYearPage(
    int year,
    int page,
  ) {
    if (isGlobalScope) {
      return _openAlexService.fetchPublicationsForYearPage(
        year: year,
        page: page,
        globalInfluential: true,
      );
    }
    return _openAlexService.fetchPublicationsForYearPage(
      year: year,
      page: page,
      search: currentTopic,
    );
  }

  Future<List<OpenAlexRankedEntity>> loadConceptsForYear(int year) {
    if (isGlobalScope) {
      return _openAlexService.fetchConceptsForYear(
        year: year,
        globalInfluential: true,
      );
    }
    return _openAlexService.fetchConceptsForYear(
      year: year,
      search: currentTopic,
    );
  }

  Future<List<OpenAlexRankedEntity>> loadJournalsForYear(int year) {
    if (isGlobalScope) {
      return _openAlexService.fetchJournalsForYear(
        year: year,
        globalInfluential: true,
      );
    }
    return _openAlexService.fetchJournalsForYear(
      year: year,
      search: currentTopic,
    );
  }

  Future<YearActivitySnapshot> loadYearActivitySnapshot(int year) async {
    final trendCount = yearlyTrendFromOpenAlex[year] ?? 0;
    final cachedAvg = avgCitationsByYearOpenAlex[year];

    final results = await Future.wait([
      loadPublicationsForYearPage(year, 1),
      loadConceptsForYear(year),
      loadJournalsForYear(year),
    ]);

    final papers = results[0] as OpenAlexWorksResult;
    final concepts = results[1] as List<OpenAlexRankedEntity>;
    final journals = results[2] as List<OpenAlexRankedEntity>;

    final topPaper =
        papers.publications.isEmpty ? null : papers.publications.first;

    var average = cachedAvg?.toDouble() ?? 0;
    if (average <= 0 && papers.publications.isNotEmpty) {
      final sum = papers.publications.fold<int>(
        0,
        (total, paper) => total + paper.citations,
      );
      average = sum / papers.publications.length;
    }

    return YearActivitySnapshot(
      publicationCount:
          papers.totalOnOpenAlex > 0 ? papers.totalOnOpenAlex : trendCount,
      averageCitations: average,
      topJournal: journals.isEmpty ? 'N/A' : journals.first.name,
      topResearchArea: concepts.isEmpty ? 'N/A' : concepts.first.name,
      topPublication: topPaper,
    );
  }

  Future<List<Publication>> loadWorksByAuthor(OpenAlexRankedEntity author) {
    return _openAlexService.fetchWorksByAuthorId(
      authorId: author.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<OpenAlexWorksResult> loadWorksByAuthorPage(
    OpenAlexRankedEntity author,
    int page,
  ) {
    return _openAlexService.fetchWorksByAuthorIdPage(
      authorId: author.id,
      page: page,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<OpenAlexRankedEntity> resolveAuthor(OpenAlexRankedEntity author) async {
    final ranked = rankedAuthorByName(author.name);
    if (ranked != null &&
        OpenAlexService.shortOpenAlexId(ranked.id).isNotEmpty) {
      return ranked;
    }
    return _openAlexService.resolveAuthor(author);
  }

  Future<List<Publication>> loadRelatedWorks(Publication publication) {
    return _openAlexService.fetchRelatedWorks(
      relatedWorkIds: publication.relatedWorkIds,
      excludeWorkId: publication.id,
    );
  }

  Future<Map<int, int>> loadConceptTrend(OpenAlexRankedEntity concept) {
    return _openAlexService.fetchConceptYearlyTrend(
      conceptId: concept.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<List<OpenAlexRankedEntity>> loadConceptTopAuthors(
    OpenAlexRankedEntity concept,
  ) {
    return _openAlexService.fetchConceptTopAuthors(
      conceptId: concept.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<List<OpenAlexRankedEntity>> loadConceptTopJournals(
    OpenAlexRankedEntity concept,
  ) {
    return _openAlexService.fetchConceptTopJournals(
      conceptId: concept.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<OpenAlexWorksResult> loadConceptWorksPage(
    OpenAlexRankedEntity concept,
    int page,
  ) {
    return _openAlexService.fetchConceptWorksPage(
      conceptId: concept.id,
      page: page,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<Map<int, int>> loadAuthorTrend(OpenAlexRankedEntity author) {
    return _openAlexService.fetchAuthorYearlyTrend(
      authorId: author.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<List<OpenAlexRankedEntity>> loadAuthorTopJournals(
    OpenAlexRankedEntity author,
  ) {
    return _openAlexService.fetchAuthorTopJournals(
      authorId: author.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<Map<int, int>> loadJournalTrend(OpenAlexRankedEntity journal) {
    return _openAlexService.fetchSourceYearlyTrend(
      sourceId: journal.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<List<OpenAlexRankedEntity>> loadJournalTopAuthors(
    OpenAlexRankedEntity journal,
  ) {
    return _openAlexService.fetchSourceTopAuthors(
      sourceId: journal.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<JournalSourceProfile> loadJournalSourceProfile(
    OpenAlexRankedEntity journal,
  ) async {
    final profile = await _openAlexService.fetchSourceProfile(journal.id);
    return profile ??
        JournalSourceProfile(
          name: journal.name,
          publisher: 'N/A',
          sourceType: 'Journal',
          issn: 'N/A',
        );
  }

  Future<double> loadJournalAverageCitations(OpenAlexRankedEntity journal) {
    return _openAlexService.fetchSourceAverageCitation(
      sourceId: journal.id,
      search: isGlobalScope ? null : currentTopic,
    );
  }

  Future<double?> loadJournalOpenAccessPercent(OpenAlexRankedEntity journal) {
    return _openAlexService.fetchSourceOpenAccessPercent(
      sourceId: journal.id,
      search: isGlobalScope ? null : currentTopic,
    );
  }

  Future<List<RankedAuthorEntry>> loadRankedAuthors({
    List<OpenAlexRankedEntity>? authors,
    int limit = 20,
  }) async {
    final source = authors ?? topAuthorsOpenAlex;
    final slice = source.take(limit).toList();
    return _openAlexService.enrichAuthorRanks(slice);
  }

  Future<AuthorProfile> loadAuthorProfile(OpenAlexRankedEntity author) async {
    final profile = await _openAlexService.fetchAuthorDetailProfile(author.id);
    return profile ??
        AuthorProfile.fallback(
          name: author.name,
          openAlexId: author.id,
          publicationCount: author.count,
        );
  }

  Future<List<OpenAlexRankedEntity>> loadTopKeywords({int limit = 10}) async {
    final keywords = await _openAlexService.fetchTopKeywords(
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
      limit: limit,
    );
    topKeywordsOpenAlex = keywords;
    return keywords;
  }

  OpenAlexRankedEntity? rankedConceptById(String id) {
    for (final area in topResearchAreasOpenAlex) {
      if (area.id == id) return area;
    }
    for (final topic in growingTopicsOpenAlex) {
      if (topic.id == id) {
        return OpenAlexRankedEntity(id: topic.id, name: topic.name, count: 0);
      }
    }
    return null;
  }

  Future<List<Publication>> loadWorksByJournal(
    OpenAlexRankedEntity journal,
  ) {
    return _openAlexService.fetchWorksBySourceId(
      sourceId: journal.id,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  Future<OpenAlexWorksResult> loadWorksByJournalPage(
    OpenAlexRankedEntity journal,
    int page,
  ) {
    return _openAlexService.fetchWorksBySourceIdPage(
      sourceId: journal.id,
      page: page,
      search: isGlobalScope ? null : currentTopic,
      globalInfluential: false,
    );
  }

  int openAlexCountForYear(int year) {
    return yearlyTrendFromOpenAlex[year] ?? 0;
  }

  void _clearTopicMetrics() {
    topPapersOpenAlex = [];
    yearlyTrendFromOpenAlex = {};
    citationsByYearOpenAlex = {};
    avgCitationsByYearOpenAlex = {};
    topAuthorsOpenAlex = [];
    topJournalsOpenAlex = [];
    topResearchAreasOpenAlex = [];
    topKeywordsOpenAlex = [];
    topInstitutionsOpenAlex = [];
    topCountriesOpenAlex = [];
    typeDistribution = {};
    oaDistribution = {};
    languageDistribution = {};
    growingTopicsOpenAlex = [];
    averageCitationOpenAlex = 0;
    totalOnOpenAlex = 0;
  }

  void _clearAllData() {
    publications = [];
    _clearTopicMetrics();
    searchHasMore = false;
    searchListPage = 0;
  }

  void _clearError() {
    errorMessage = null;
    errorStatusCode = null;
  }

  void _captureError(Object e) {
    if (e is OpenAlexException) {
      errorMessage = e.message;
      errorStatusCode = e.statusCode;
    } else {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      errorStatusCode = null;
    }
  }

  Future<void> _loadAllOpenAlexMetrics({
    String? search,
    bool globalInfluential = false,
  }) async {
    isTrendLoading = true;
    notifyListeners();

    yearlyTrendFromOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchPublicationTrendByYear(
        search: search,
        globalInfluential: globalInfluential,
      ),
      {},
    );

    topAuthorsOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchWorksGroupedCounts(
        groupBy: OpenAlexService.groupByAuthor,
        search: search,
        globalInfluential: globalInfluential,
        limit: 20,
      ),
      [],
    );

    topJournalsOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchWorksGroupedCounts(
        groupBy: OpenAlexService.groupByJournal,
        search: search,
        globalInfluential: globalInfluential,
        limit: 20,
      ),
      [],
    );

    topInstitutionsOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchWorksGroupedCounts(
        groupBy: OpenAlexService.groupByInstitution,
        search: search,
        globalInfluential: globalInfluential,
        limit: 20,
      ),
      [],
    );

    topCountriesOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchWorksGroupedCounts(
        groupBy: OpenAlexService.groupByCountry,
        search: search,
        globalInfluential: globalInfluential,
        limit: 20,
      ),
      [],
    );

    typeDistribution = await _tryAggregate(
      () => _openAlexService.fetchDistribution(
        groupBy: OpenAlexService.groupByType,
        search: search,
        globalInfluential: globalInfluential,
      ),
      {},
    );

    oaDistribution = await _tryAggregate(
      () => _openAlexService.fetchDistribution(
        groupBy: OpenAlexService.groupByOpenAccess,
        search: search,
        globalInfluential: globalInfluential,
        limit: 4,
      ),
      {},
    );

    languageDistribution = await _tryAggregate(
      () => _openAlexService.fetchDistribution(
        groupBy: OpenAlexService.groupByLanguage,
        search: search,
        globalInfluential: globalInfluential,
      ),
      {},
    );

    topResearchAreasOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchWorksGroupedCounts(
        groupBy: OpenAlexService.groupByConcept,
        search: search,
        globalInfluential: globalInfluential,
        limit: 8,
      ),
      [],
    );

    growingTopicsOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchTopicGrowthInsights(
        concepts: topResearchAreasOpenAlex,
        search: search,
        globalInfluential: globalInfluential,
        limit: 5,
      ),
      [],
    );

    topPapersOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchTopPapers(
        search: search,
        globalInfluential: globalInfluential,
        limit: 20,
      ),
      [],
    );

    averageCitationOpenAlex = await _tryAggregate(
      () => _openAlexService.fetchAverageCitation(
        search: search,
        globalInfluential: globalInfluential,
      ),
      0.0,
    );

    final citationMetrics = await _tryAggregate(
      () => _openAlexService.fetchCitationMetricsByYear(
        search: search,
        globalInfluential: globalInfluential,
      ),
      (totals: <int, int>{}, averages: <int, int>{}),
    );
    citationsByYearOpenAlex = citationMetrics.totals;
    avgCitationsByYearOpenAlex = citationMetrics.averages;

    isTrendLoading = false;
    notifyListeners();
  }

  Future<T> _tryAggregate<T>(Future<T> Function() load, T fallback) async {
    try {
      return await load();
    } catch (_) {
      return fallback;
    }
  }
}

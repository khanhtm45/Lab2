import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/openalex_works_result.dart';
import '../models/publication.dart';
import '../models/research_insight.dart';
import '../models/search_filters.dart';
import '../utils/research_insights.dart';
import 'openalex_config.dart';
import 'openalex_exception.dart';

/// Service chịu trách nhiệm giao tiếp với OpenAlex API
class OpenAlexService {
  OpenAlexService([OpenAlexConfig? config])
      : _config = config ?? OpenAlexConfig();

  final OpenAlexConfig _config;

  String get _apiKey => _config.apiKey;

  static const int _maxRetries = 4;
  static const Duration _requestTimeout = Duration(seconds: 45);
  static const Set<int> _retryStatusCodes = {429, 502, 503, 504};

  static const int _perPage = 100;
  static const int listPageSize = 20;

  static const String _apiHost = 'api.openalex.org';
  static const String _worksPath = '/works';
  static const String _perPageKey = 'per-page';
  static const String _mailto = 'prm393.lab2@example.com';
  static const String _sortCitedByDesc = 'cited_by_count:desc';
  static const String _quartileQ1Top = 'Q1 (top)';
  static const String _quartileQ4Low = 'Q4 (low)';

  static const String groupByAuthor = 'authorships.author.id';
  static const String groupByJournal = 'primary_location.source.id';
  static const String groupByConcept = 'concepts.id';
  static const String groupByInstitution = 'authorships.institutions.id';
  static const String groupByCountry = 'authorships.institutions.country_code';
  static const String groupByType = 'type';
  static const String groupByLanguage = 'language';
  static const String groupByKeyword = 'keywords.id';
  static const String groupByOpenAccess = 'open_access.is_oa';

  static const String _selectFields =
      'id,title,publication_year,cited_by_count,type,authorships,'
      'primary_location,best_oa_location,open_access,abstract_inverted_index,'
      'doi,concepts,related_works';

  String get _trendYearFilter {
    final endYear = DateTime.now().year;
    return 'publication_year:2016-$endYear';
  }

  List<int> get _trendYears {
    final endYear = DateTime.now().year;
    return [for (var year = 2016; year <= endYear; year++) year];
  }

  Uri _openAlexUri(String path, [Map<String, String>? query]) =>
      Uri.https(_apiHost, path, query);

  Future<OpenAlexWorksResult> searchPublications(String topic) {
    return fetchSearchPage(topic, page: 1);
  }

  /// Author scatter: X = works in topic scope, Y = total cited_by_count from /authors
  Future<List<ScatterPoint>> fetchAuthorScatterPoints({
    String? search,
    bool globalInfluential = false,
    int limit = 12,
  }) async {
    final authors = await fetchWorksGroupedCounts(
      groupBy: groupByAuthor,
      search: search,
      globalInfluential: globalInfluential,
      limit: limit,
    );

    final points = <ScatterPoint>[];
    for (final author in authors) {
      try {
        final id = author.id.contains('/') ? author.id.split('/').last : author.id;
        final data = await _getJson(_openAlexUri( '/authors/$id', _authParams()));
        points.add(
          ScatterPoint(
            label: author.name,
            x: author.count.toDouble(),
            y: (data['cited_by_count'] as num?)?.toDouble() ?? 0,
          ),
        );
      } catch (_) {
        points.add(ScatterPoint(label: author.name, x: author.count.toDouble(), y: 0));
      }
    }
    return points;
  }

  Future<List<ScatterPoint>> fetchJournalScatterPoints({
    String? search,
    bool globalInfluential = false,
    int limit = 10,
  }) async {
    final journals = await fetchWorksGroupedCounts(
      groupBy: groupByJournal,
      search: search,
      globalInfluential: globalInfluential,
      limit: limit,
    );
    final papers = await fetchTopPapers(
      search: search,
      globalInfluential: globalInfluential,
      limit: 100,
    );

    final citationByJournal = <String, int>{};
    for (final paper in papers) {
      citationByJournal[paper.journal] =
          (citationByJournal[paper.journal] ?? 0) + paper.citations;
    }

    return journals
        .map(
          (j) => ScatterPoint(
            label: j.name,
            x: j.count.toDouble(),
            y: (citationByJournal[j.name] ?? 0).toDouble(),
          ),
        )
        .toList();
  }

  Future<List<OpenAlexRankedEntity>> fetchTopKeywords({
    String? search,
    bool globalInfluential = false,
    int limit = 10,
  }) async {
    try {
      return await fetchWorksGroupedCounts(
        groupBy: groupByKeyword,
        search: search,
        globalInfluential: globalInfluential,
        limit: limit,
      );
    } catch (_) {
      return fetchWorksGroupedCounts(
        groupBy: groupByConcept,
        search: search,
        globalInfluential: globalInfluential,
        limit: limit,
      );
    }
  }

  Map<int, int> computeCitationVelocity(Map<int, int> citationsByYear) {
    final years = citationsByYear.keys.toList()..sort();
    final velocity = <int, int>{};
    for (var i = 1; i < years.length; i++) {
      final prev = citationsByYear[years[i - 1]] ?? 0;
      final curr = citationsByYear[years[i]] ?? 0;
      velocity[years[i]] = curr - prev;
    }
    return velocity;
  }

  static const String _analyticsSelect =
      'id,title,publication_year,cited_by_count,authorships,concepts,keywords,'
      'related_works,primary_location';

  Future<AdvancedAnalyticsData> fetchAdvancedAnalyticsBundle({
    String? search,
    bool globalInfluential = false,
  }) async {
    final works = await _fetchRawWorks(
      search: search,
      globalInfluential: globalInfluential,
      perPage: 80,
    );
    if (works.isEmpty) return AdvancedAnalyticsData.empty;

    final institutions = await fetchWorksGroupedCounts(
      groupBy: groupByInstitution,
      search: search,
      globalInfluential: globalInfluential,
      limit: 8,
    );

    final institutionBubbles = await _fetchInstitutionBubbles(institutions);
    final countryByCitations = _aggregateCountryCitations(works);
    final citationQuartiles = _computeCitationQuartiles(works);
    final citationNetwork = _buildCitationNetwork(works);
    final authorCollaboration = _buildAuthorCollaboration(works);
    final institutionCollaboration = _buildInstitutionCollaboration(works);
    final countryCollaboration = _buildCountryCollaboration(works);
    final keywordCooccurrence = _buildKeywordCooccurrence(works);
    final topicCooccurrence = _buildTopicCooccurrence(works);
    final journalTopicMatrix = _buildCrossMatrix(
      works,
      rowExtractor: _journalFromWork,
      colExtractor: _topicsFromWork,
      rowLimit: 5,
      colLimit: 5,
    );
    final authorTopicMatrix = _buildCrossMatrix(
      works,
      rowExtractor: _authorsFromWork,
      colExtractor: _topicsFromWork,
      rowLimit: 5,
      colLimit: 5,
    );
    final institutionTopicMatrix = _buildCrossMatrix(
      works,
      rowExtractor: _institutionsFromWork,
      colExtractor: _topicsFromWork,
      rowLimit: 5,
      colLimit: 5,
    );
    final countryTopicMatrix = _buildCrossMatrix(
      works,
      rowExtractor: _countriesFromWork,
      colExtractor: _topicsFromWork,
      rowLimit: 5,
      colLimit: 5,
    );
    final journalMigrationFlows = _buildJournalMigrationFlows(works);

    return AdvancedAnalyticsData(
      institutionBubbles: institutionBubbles,
      countryByCitations: countryByCitations,
      citationQuartiles: citationQuartiles,
      citationNetwork: citationNetwork,
      authorCollaboration: authorCollaboration,
      institutionCollaboration: institutionCollaboration,
      countryCollaboration: countryCollaboration,
      keywordCooccurrence: keywordCooccurrence,
      topicCooccurrence: topicCooccurrence,
      journalTopicMatrix: journalTopicMatrix,
      authorTopicMatrix: authorTopicMatrix,
      institutionTopicMatrix: institutionTopicMatrix,
      countryTopicMatrix: countryTopicMatrix,
      journalMigrationFlows: journalMigrationFlows,
    );
  }

  Future<({List<String> rows, List<String> cols, List<List<double>> matrix})>
      fetchJournalTopicMatrix({
    String? search,
    bool globalInfluential = false,
  }) async {
    final bundle = await fetchAdvancedAnalyticsBundle(
      search: search,
      globalInfluential: globalInfluential,
    );
    final m = bundle.journalTopicMatrix;
    return (rows: m.rowLabels, cols: m.colLabels, matrix: m.values);
  }

  Future<List<Map<String, dynamic>>> _fetchRawWorks({
    String? search,
    bool globalInfluential = false,
    int perPage = 80,
  }) async {
    final params = {
      ..._listBaseParams(
        search: search,
        globalInfluential: globalInfluential,
      ),
      'select': _analyticsSelect,
      _perPageKey: '${perPage.clamp(1, _perPage)}',
      'page': '1',
      'mailto': _mailto,
    };
    if (_apiKey.isNotEmpty) params['api_key'] = _apiKey;

    final data = await _getJson(_openAlexUri(_worksPath, params));
    final results = data['results'] as List? ?? [];
    return results
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<List<BubblePoint>> _fetchInstitutionBubbles(
    List<OpenAlexRankedEntity> institutions,
  ) async {
    final futures = institutions.take(8).map((inst) async {
      try {
        final id = inst.id.contains('/') ? inst.id.split('/').last : inst.id;
        final data = await _getJson(
          _openAlexUri( '/institutions/$id', _authParams()),
        );
        final cited = (data['cited_by_count'] as num?)?.toDouble() ?? 0;
        final works = (data['works_count'] as num?)?.toDouble() ?? inst.count.toDouble();
        return BubblePoint(
          label: inst.name,
          x: works,
          y: cited,
          size: math.sqrt(cited + works),
        );
      } catch (_) {
        return BubblePoint(
          label: inst.name,
          x: inst.count.toDouble(),
          y: inst.count.toDouble(),
          size: inst.count.toDouble(),
        );
      }
    });
    return Future.wait(futures);
  }

  List<OpenAlexRankedEntity> _aggregateCountryCitations(
    List<Map<String, dynamic>> works,
  ) {
    final totals = <String, int>{};
    for (final work in works) {
      final citations = (work['cited_by_count'] as num?)?.toInt() ?? 0;
      final countries = _countriesFromWork(work);
      if (countries.isEmpty) continue;
      final share = citations ~/ countries.length;
      for (final code in countries) {
        totals[code] = (totals[code] ?? 0) + share;
      }
    }
    final ranked = totals.entries
        .map((e) => OpenAlexRankedEntity(id: e.key, name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return ranked.take(10).toList();
  }

  Map<String, int> _computeCitationQuartiles(List<Map<String, dynamic>> works) {
    final citations = works
        .map((w) => (w['cited_by_count'] as num?)?.toInt() ?? 0)
        .toList()
      ..sort();
    if (citations.isEmpty) return {};

    int q(int percentile) {
      if (citations.length == 1) return citations.first;
      final idx = ((percentile / 100) * (citations.length - 1)).round();
      return citations[idx.clamp(0, citations.length - 1)];
    }

    final q1Cut = q(75);
    final q2Cut = q(50);
    final q3Cut = q(25);
    final buckets = {_quartileQ1Top: 0, 'Q2': 0, 'Q3': 0, _quartileQ4Low: 0};

    for (final c in citations) {
      if (c >= q1Cut) {
        buckets[_quartileQ1Top] = buckets[_quartileQ1Top]! + 1;
      } else if (c >= q2Cut) {
        buckets['Q2'] = buckets['Q2']! + 1;
      } else if (c >= q3Cut) {
        buckets['Q3'] = buckets['Q3']! + 1;
      } else {
        buckets[_quartileQ4Low] = buckets[_quartileQ4Low]! + 1;
      }
    }
    return buckets;
  }

  NetworkGraphData _buildCitationNetwork(List<Map<String, dynamic>> works) {
    final sorted = [...works]
      ..sort(
        (a, b) => ((b['cited_by_count'] as num?) ?? 0)
            .compareTo((a['cited_by_count'] as num?) ?? 0),
      );
    final top = sorted.take(10).toList();
    final idToLabel = <String, String>{};
    for (final w in top) {
      final id = w['id']?.toString() ?? '';
      final title = w['title']?.toString() ?? 'Paper';
      idToLabel[id] = _shortLabel(title, 18);
    }

    final edgeWeights = <String, double>{};
    for (final w in top) {
      final fromId = w['id']?.toString() ?? '';
      final from = idToLabel[fromId];
      if (from == null) continue;
      for (final related in w['related_works'] as List? ?? []) {
        final rid = related.toString();
        final to = idToLabel[rid];
        if (to == null || to == from) continue;
        final key = from.compareTo(to) < 0 ? '$from|$to' : '$to|$from';
        edgeWeights[key] = (edgeWeights[key] ?? 0) + 1;
      }
    }

    return _networkFromEdges(edgeWeights, maxNodes: 10);
  }

  NetworkGraphData _buildAuthorCollaboration(List<Map<String, dynamic>> works) {
    final edgeWeights = <String, double>{};
    for (final work in works) {
      final names = _authorsFromWork(work).map((n) => _shortLabel(n, 14)).toList();
      _addPairEdges(edgeWeights, names);
    }
    return _networkFromEdges(edgeWeights, maxNodes: 12);
  }

  NetworkGraphData _buildInstitutionCollaboration(
    List<Map<String, dynamic>> works,
  ) {
    final edgeWeights = <String, double>{};
    for (final work in works) {
      final names = _institutionsFromWork(work).map((n) => _shortLabel(n, 16)).toList();
      _addPairEdges(edgeWeights, names);
    }
    return _networkFromEdges(edgeWeights, maxNodes: 10);
  }

  NetworkGraphData _buildCountryCollaboration(List<Map<String, dynamic>> works) {
    final edgeWeights = <String, double>{};
    for (final work in works) {
      final codes = _countriesFromWork(work);
      _addPairEdges(edgeWeights, codes);
    }
    return _networkFromEdges(edgeWeights, maxNodes: 10);
  }

  NetworkGraphData _buildKeywordCooccurrence(List<Map<String, dynamic>> works) {
    final edgeWeights = <String, double>{};
    for (final work in works) {
      final keywords = _keywordsFromWork(work);
      _addPairEdges(edgeWeights, keywords);
    }
    return _networkFromEdges(edgeWeights, maxNodes: 12);
  }

  NetworkGraphData _buildTopicCooccurrence(List<Map<String, dynamic>> works) {
    final edgeWeights = <String, double>{};
    for (final work in works) {
      final topics = _topicsFromWork(work).map((t) => _shortLabel(t, 16)).toList();
      _addPairEdges(edgeWeights, topics);
    }
    return _networkFromEdges(edgeWeights, maxNodes: 12);
  }

  HeatmapData _buildCrossMatrix(
    List<Map<String, dynamic>> works, {
    required List<String> Function(Map<String, dynamic>) rowExtractor,
    required List<String> Function(Map<String, dynamic>) colExtractor,
    int rowLimit = 5,
    int colLimit = 5,
  }) {
    final rowCounts = <String, int>{};
    final colCounts = <String, int>{};
    final cross = <String, Map<String, int>>{};

    for (final work in works) {
      final rows = rowExtractor(work);
      final cols = colExtractor(work);
      for (final r in rows) {
        rowCounts[r] = (rowCounts[r] ?? 0) + 1;
      }
      for (final c in cols) {
        colCounts[c] = (colCounts[c] ?? 0) + 1;
      }
      for (final r in rows) {
        cross.putIfAbsent(r, () => {});
        for (final c in cols) {
          cross[r]![c] = (cross[r]![c] ?? 0) + 1;
        }
      }
    }

    final rowLabels = _topKeys(rowCounts, rowLimit);
    final colLabels = _topKeys(colCounts, colLimit);
    if (rowLabels.isEmpty || colLabels.isEmpty) {
      return const HeatmapData();
    }

    final values = [
      for (final r in rowLabels)
        [
          for (final c in colLabels)
            (cross[r]?[c] ?? 0).toDouble(),
        ],
    ];

    return HeatmapData(
      rowLabels: rowLabels.map((l) => _shortLabel(l, 22)).toList(),
      colLabels: colLabels.map((l) => _shortLabel(l, 22)).toList(),
      values: values,
    );
  }

  List<SankeyFlow> _buildJournalMigrationFlows(List<Map<String, dynamic>> works) {
    final currentYear = DateTime.now().year;
    final minYear = currentYear - 4;
    final counts = <String, Map<String, int>>{};

    for (final work in works) {
      final year = (work['publication_year'] as num?)?.toInt() ?? 0;
      if (year < minYear || year > currentYear) continue;
      final journals = _journalFromWork(work);
      final journal = journals.isNotEmpty ? journals.first : 'Unknown';
      final yearKey = '$year';
      counts.putIfAbsent(yearKey, () => {});
      counts[yearKey]![journal] = (counts[yearKey]![journal] ?? 0) + 1;
    }

    final flows = <SankeyFlow>[];
    for (final entry in counts.entries) {
      for (final journalEntry in entry.value.entries) {
        flows.add(
          SankeyFlow(
            source: entry.key,
            target: _shortLabel(journalEntry.key, 20),
            value: journalEntry.value.toDouble(),
          ),
        );
      }
    }
    flows.sort((a, b) => b.value.compareTo(a.value));
    return flows.take(24).toList();
  }

  NetworkGraphData _networkFromEdges(
    Map<String, double> edgeWeights, {
    int maxNodes = 12,
  }) {
    if (edgeWeights.isEmpty) return const NetworkGraphData();

    final nodeScores = <String, double>{};
    for (final entry in edgeWeights.entries) {
      final parts = entry.key.split('|');
      if (parts.length != 2) continue;
      nodeScores[parts[0]] = (nodeScores[parts[0]] ?? 0) + entry.value;
      nodeScores[parts[1]] = (nodeScores[parts[1]] ?? 0) + entry.value;
    }

    final nodes = nodeScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final selected = nodes.take(maxNodes).map((e) => e.key).toSet();

    final edges = <NetworkEdge>[];
    for (final entry in edgeWeights.entries) {
      final parts = entry.key.split('|');
      if (parts.length != 2) continue;
      if (!selected.contains(parts[0]) || !selected.contains(parts[1])) continue;
      edges.add(NetworkEdge(from: parts[0], to: parts[1], weight: entry.value));
    }

    return NetworkGraphData(
      nodes: selected.toList(),
      edges: edges,
    );
  }

  void _addPairEdges(Map<String, double> edgeWeights, List<String> labels) {
    final unique = labels.toSet().toList();
    for (var i = 0; i < unique.length; i++) {
      for (var j = i + 1; j < unique.length; j++) {
        final a = unique[i];
        final b = unique[j];
        final key = a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';
        edgeWeights[key] = (edgeWeights[key] ?? 0) + 1;
      }
    }
  }

  List<String> _topKeys(Map<String, int> counts, int limit) {
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  String _shortLabel(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen - 1)}…';
  }

  List<String> _authorsFromWork(Map<String, dynamic> work) {
    final names = <String>[];
    for (final item in work['authorships'] as List? ?? []) {
      if (item is! Map) continue;
      final author = item['author'] as Map?;
      final name = author?['display_name']?.toString();
      if (name != null && name.isNotEmpty) names.add(name);
    }
    return names;
  }

  List<String> _institutionsFromWork(Map<String, dynamic> work) {
    final names = <String>{};
    for (final item in work['authorships'] as List? ?? []) {
      if (item is! Map) continue;
      for (final inst in item['institutions'] as List? ?? []) {
        if (inst is! Map) continue;
        final name = inst['display_name']?.toString();
        if (name != null && name.isNotEmpty) names.add(name);
      }
    }
    return names.toList();
  }

  List<String> _countriesFromWork(Map<String, dynamic> work) {
    final codes = <String>{};
    for (final item in work['authorships'] as List? ?? []) {
      if (item is! Map) continue;
      for (final inst in item['institutions'] as List? ?? []) {
        if (inst is! Map) continue;
        final code = inst['country_code']?.toString();
        if (code != null && code.isNotEmpty) codes.add(code.toUpperCase());
      }
    }
    return codes.toList();
  }

  List<String> _journalFromWork(Map<String, dynamic> work) {
    final journal = work['primary_location']?['source']?['display_name']?.toString();
    if (journal == null || journal.isEmpty) return ['Unknown Journal'];
    return [journal];
  }

  List<String> _topicsFromWork(Map<String, dynamic> work) {
    final topics = <String>[];
    for (final item in work['concepts'] as List? ?? []) {
      if (item is! Map) continue;
      final name = item['display_name']?.toString();
      final score = (item['score'] as num?)?.toDouble() ?? 0;
      if (name != null && name.isNotEmpty && score >= 0.35) {
        topics.add(name);
      }
    }
    if (topics.isEmpty) {
      topics.addAll(_keywordsFromWork(work));
    }
    return topics.take(3).toList();
  }

  List<String> _keywordsFromWork(Map<String, dynamic> work) {
    final keywords = <String>[];
    for (final item in work['keywords'] as List? ?? []) {
      if (item is! Map) continue;
      final name = item['display_name']?.toString() ?? item['keyword']?.toString();
      if (name != null && name.isNotEmpty) keywords.add(name);
    }
    if (keywords.isNotEmpty) return keywords.take(4).toList();

    for (final item in work['concepts'] as List? ?? []) {
      if (item is! Map) continue;
      final name = item['display_name']?.toString();
      if (name != null && name.isNotEmpty) keywords.add(name);
    }
    return keywords.take(4).toList();
  }

  Map<String, String> _authParams() {
    final p = <String, String>{'mailto': _mailto};
    if (_apiKey.isNotEmpty) p['api_key'] = _apiKey;
    return p;
  }

  Future<OpenAlexWorksResult> fetchSearchPage(
    String topic, {
    required int page,
    int perPage = listPageSize,
    SearchFilters? filters,
    SearchSortOption sort = SearchSortOption.mostCited,
  }) {
    return _fetchWorksResultPage(
      _searchParams(search: topic, filters: filters, sort: sort),
      page: page,
      perPage: perPage,
    );
  }

  Future<Map<String, int>> fetchDistribution({
    required String groupBy,
    String? search,
    bool globalInfluential = false,
    int limit = 8,
  }) async {
    final data = await _fetchWorksGroupBy(
      groupBy: groupBy,
      search: search,
      globalInfluential: globalInfluential,
    );
    return parseGroupByKeyCounts(data, limit: limit);
  }

  Future<TopicComparisonResult> compareTopics(
    String topicA,
    String topicB,
  ) async {
    final results = await Future.wait([
      fetchWorksTotalCount(search: topicA),
      fetchWorksTotalCount(search: topicB),
      fetchAverageCitation(search: topicA),
      fetchAverageCitation(search: topicB),
      fetchWorksGroupedCounts(groupBy: groupByAuthor, search: topicA, limit: 20),
      fetchWorksGroupedCounts(groupBy: groupByAuthor, search: topicB, limit: 20),
      fetchWorksGroupedCounts(groupBy: groupByJournal, search: topicA, limit: 20),
      fetchWorksGroupedCounts(groupBy: groupByJournal, search: topicB, limit: 20),
    ]);

    return TopicComparisonResult(
      topicA: topicA,
      topicB: topicB,
      publicationsA: results[0] as int,
      publicationsB: results[1] as int,
      avgCitationsA: results[2] as double,
      avgCitationsB: results[3] as double,
      authorsA: (results[4] as List).length,
      authorsB: (results[5] as List).length,
      journalsA: (results[6] as List).length,
      journalsB: (results[7] as List).length,
    );
  }

  Future<int> fetchWorksTotalCount({
    String? search,
    bool globalInfluential = false,
  }) async {
    final page = await _fetchWorksPage(
      _listBaseParams(
        search: search,
        globalInfluential: globalInfluential,
      ),
      page: 1,
      perPage: 1,
    );
    return page.totalOnOpenAlex;
  }

  Future<List<Publication>> fetchTopPapers({
    String? search,
    bool globalInfluential = false,
    int limit = 10,
  }) async {
    final page = await _fetchWorksPage(
      _listBaseParams(
        search: search,
        globalInfluential: globalInfluential,
      ),
      page: 1,
      perPage: limit.clamp(1, _perPage),
    );
    return page.publications;
  }

  Future<double> fetchAverageCitation({
    String? search,
    bool globalInfluential = false,
  }) async {
    final page = await _fetchWorksPage(
      {
        ..._listBaseParams(
          search: search,
          globalInfluential: globalInfluential,
        ),
        'select': 'cited_by_count',
      },
      page: 1,
      perPage: _perPage,
    );

    if (page.publications.isEmpty) return 0;

    final total = page.publications.fold<int>(
      0,
      (sum, paper) => sum + paper.citations,
    );
    return total / page.publications.length;
  }

  Future<Map<int, int>> fetchPublicationTrendByYear({
    String? search,
    bool globalInfluential = false,
  }) async {
    final data = await _fetchWorksGroupBy(
      groupBy: 'publication_year',
      search: search,
      globalInfluential: globalInfluential,
    );
    return parseGroupByYear(data);
  }

  Future<({Map<int, int> totals, Map<int, int> averages})>
      fetchCitationMetricsByYear({
    String? search,
    bool globalInfluential = false,
  }) async {
    final totals = <int, int>{};
    final averages = <int, int>{};

    for (final year in _trendYears) {
      final page = await _fetchWorksPage(
        {
          ..._yearListParams(
            year: year,
            search: search,
            globalInfluential: globalInfluential,
          ),
          'select': 'cited_by_count',
        },
        page: 1,
        perPage: _perPage,
      );

      if (page.publications.isEmpty) continue;

      final sum = page.publications.fold<int>(
        0,
        (total, paper) => total + paper.citations,
      );
      totals[year] = sum;
      averages[year] = (sum / page.publications.length).round();
    }

    return (totals: totals, averages: averages);
  }

  Future<List<OpenAlexRankedEntity>> fetchWorksGroupedCounts({
    required String groupBy,
    String? search,
    bool globalInfluential = false,
    int limit = 10,
    String? filterOverride,
  }) async {
    final data = await _fetchWorksGroupBy(
      groupBy: groupBy,
      search: search,
      globalInfluential: globalInfluential,
      filterOverride: filterOverride,
    );
    return parseGroupByNamedCounts(data, limit: limit);
  }

  Future<List<OpenAlexRankedEntity>> fetchConceptsForYear({
    required int year,
    String? search,
    bool globalInfluential = false,
    int limit = 5,
  }) async {
    return fetchWorksGroupedCounts(
      groupBy: groupByConcept,
      search: search,
      globalInfluential: globalInfluential,
      limit: limit,
      filterOverride: _yearFilter(
        year: year,
        search: search,
        globalInfluential: globalInfluential,
      ),
    );
  }

  Future<OpenAlexWorksResult> fetchPublicationsForYearPage({
    required int year,
    required int page,
    String? search,
    bool globalInfluential = false,
    int perPage = listPageSize,
  }) {
    return _fetchWorksResultPage(
      _yearListParams(
        year: year,
        search: search,
        globalInfluential: globalInfluential,
      ),
      page: page,
      perPage: perPage,
    );
  }

  Future<List<Publication>> fetchPublicationsForYear({
    required int year,
    String? search,
    bool globalInfluential = false,
  }) async {
    final result = await fetchPublicationsForYearPage(
      year: year,
      page: 1,
      search: search,
      globalInfluential: globalInfluential,
    );
    return result.publications;
  }

  Future<OpenAlexWorksResult> fetchWorksByAuthorIdPage({
    required String authorId,
    required int page,
    String? search,
    bool globalInfluential = false,
    int perPage = listPageSize,
  }) {
    return _fetchFilteredWorksPage(
      filter: _authorFilter(
        authorId: authorId,
        search: search,
        globalInfluential: false,
      ),
      page: page,
      search: search,
      globalInfluential: false,
      perPage: perPage,
    );
  }

  Future<List<Publication>> fetchWorksByAuthorId({
    required String authorId,
    String? search,
    bool globalInfluential = false,
    int maxPages = 1,
  }) async {
    final result = await fetchWorksByAuthorIdPage(
      authorId: authorId,
      page: 1,
      search: search,
      globalInfluential: globalInfluential,
    );
    return result.publications;
  }

  Future<OpenAlexWorksResult> fetchWorksBySourceIdPage({
    required String sourceId,
    required int page,
    String? search,
    bool globalInfluential = false,
    int perPage = listPageSize,
  }) {
    return _fetchFilteredWorksPage(
      filter: _sourceFilter(
        sourceId: sourceId,
        search: search,
        globalInfluential: false,
      ),
      page: page,
      search: search,
      globalInfluential: false,
      perPage: perPage,
    );
  }

  Future<OpenAlexRankedEntity?> fetchAuthorProfile(String authorId) async {
    final id = shortOpenAlexId(authorId);
    if (id.isEmpty) return null;

    final data = await _getJson(
      _openAlexUri( '/authors/$id', _authParams()),
    );

    return OpenAlexRankedEntity(
      id: data['id']?.toString() ?? 'https://openalex.org/$id',
      name: data['display_name']?.toString() ?? 'Unknown Author',
      count: (data['works_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<OpenAlexRankedEntity?> findAuthorByName(String name) async {
    final query = name.trim();
    if (query.isEmpty) return null;

    final data = await _getJson(
      _openAlexUri(
        '/authors',
        {
          'search': query,
          _perPageKey: '1',
          ..._authParams(),
        },
      ),
    );

    final results = data['results'] as List? ?? [];
    if (results.isEmpty) return null;

    final item = Map<String, dynamic>.from(results.first as Map);
    return OpenAlexRankedEntity(
      id: item['id']?.toString() ?? '',
      name: item['display_name']?.toString() ?? query,
      count: (item['works_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<OpenAlexRankedEntity> resolveAuthor(OpenAlexRankedEntity author) async {
    final shortId = shortOpenAlexId(author.id);
    if (shortId.isNotEmpty) {
      try {
        final profile = await fetchAuthorProfile(shortId);
        if (profile != null) return profile;
      } catch (_) {}
      return OpenAlexRankedEntity(
        id: author.id.contains('/') ? author.id : 'https://openalex.org/$shortId',
        name: author.name,
        count: author.count,
      );
    }

    try {
      final found = await findAuthorByName(author.name);
      if (found != null) return found;
    } catch (_) {}

    return author;
  }

  Future<List<Publication>> fetchWorksBySourceId({
    required String sourceId,
    String? search,
    bool globalInfluential = false,
    int maxPages = 1,
  }) async {
    final result = await fetchWorksBySourceIdPage(
      sourceId: sourceId,
      page: 1,
      search: search,
      globalInfluential: globalInfluential,
    );
    return result.publications;
  }

  /// Lấy các bài liên quan từ danh sách OpenAlex work id (`related_works`)
  Future<List<Publication>> fetchRelatedWorks({
    required List<String> relatedWorkIds,
    String? excludeWorkId,
    int limit = 5,
  }) async {
    final shortIds = relatedWorkIds
        .where((id) => id.isNotEmpty && id != excludeWorkId)
        .map(shortOpenAlexId)
        .where((id) => id.isNotEmpty)
        .take(limit)
        .toList();

    if (shortIds.isEmpty) return [];

    final page = await _fetchWorksPage(
      {
        'filter': 'ids.openalex:${shortIds.join('|')}',
        'sort': _sortCitedByDesc,
      },
      page: 1,
      perPage: limit.clamp(1, _perPage),
    );

    return page.publications
        .where((paper) => paper.id != excludeWorkId)
        .toList();
  }

  Future<NetworkGraphData> fetchKeywordCooccurrenceNetwork({
    String? search,
    bool globalInfluential = false,
  }) async {
    final works = await _fetchRawWorks(
      search: search,
      globalInfluential: globalInfluential,
      perPage: 60,
    );
    return _buildKeywordCooccurrence(works);
  }

  static String shortOpenAlexId(String openAlexId) {
    final trimmed = openAlexId.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('/')) {
      return trimmed.split('/').last;
    }
    return trimmed;
  }

  Future<Map<int, int>> fetchConceptYearlyTrend({
    required String conceptId,
    String? search,
    bool globalInfluential = false,
  }) async {
    final data = await _fetchWorksGroupBy(
      groupBy: 'publication_year',
      search: search,
      globalInfluential: false,
      filterOverride: _conceptFilter(
        conceptId: conceptId,
        search: search,
        globalInfluential: globalInfluential,
        includeTrendYears: true,
      ),
    );
    return parseGroupByYear(data);
  }

  Future<List<OpenAlexRankedEntity>> fetchConceptTopAuthors({
    required String conceptId,
    String? search,
    bool globalInfluential = false,
    int limit = 5,
  }) {
    return fetchWorksGroupedCounts(
      groupBy: groupByAuthor,
      search: search,
      globalInfluential: globalInfluential,
      limit: limit,
      filterOverride: _conceptFilter(
        conceptId: conceptId,
        search: search,
        globalInfluential: globalInfluential,
      ),
    );
  }

  Future<List<OpenAlexRankedEntity>> fetchConceptTopJournals({
    required String conceptId,
    String? search,
    bool globalInfluential = false,
    int limit = 5,
  }) {
    return fetchWorksGroupedCounts(
      groupBy: groupByJournal,
      search: search,
      globalInfluential: globalInfluential,
      limit: limit,
      filterOverride: _conceptFilter(
        conceptId: conceptId,
        search: search,
        globalInfluential: globalInfluential,
      ),
    );
  }

  Future<OpenAlexWorksResult> fetchConceptWorksPage({
    required String conceptId,
    required int page,
    String? search,
    bool globalInfluential = false,
    int perPage = listPageSize,
  }) {
    return _fetchFilteredWorksPage(
      filter: _conceptFilter(
        conceptId: conceptId,
        search: search,
        globalInfluential: false,
      ),
      page: page,
      search: search,
      globalInfluential: false,
      perPage: perPage,
    );
  }

  String _conceptFilter({
    required String conceptId,
    String? search,
    bool globalInfluential = false,
    bool includeTrendYears = false,
  }) {
    return _scopedFilter(
      baseFilter: 'concepts.id:${shortOpenAlexId(conceptId)}',
      search: search,
      globalInfluential: globalInfluential,
      includeTrendYears: includeTrendYears,
    );
  }

  String _authorFilter({
    required String authorId,
    String? search,
    bool globalInfluential = false,
    bool includeTrendYears = false,
  }) {
    return _scopedFilter(
      baseFilter: 'authorships.author.id:${shortOpenAlexId(authorId)}',
      search: search,
      globalInfluential: globalInfluential,
      includeTrendYears: includeTrendYears,
    );
  }

  String _sourceFilter({
    required String sourceId,
    String? search,
    bool globalInfluential = false,
    bool includeTrendYears = false,
  }) {
    return _scopedFilter(
      baseFilter: 'primary_location.source.id:${shortOpenAlexId(sourceId)}',
      search: search,
      globalInfluential: globalInfluential,
      includeTrendYears: includeTrendYears,
    );
  }

  String _scopedFilter({
    required String baseFilter,
    String? search,
    bool globalInfluential = false,
    bool includeTrendYears = false,
  }) {
    var filter = baseFilter;
    if (includeTrendYears) {
      filter = '$filter,$_trendYearFilter';
    }
    if (globalInfluential && (search == null || search.trim().isEmpty)) {
      filter = '$filter,cited_by_count:>100';
    }
    return filter;
  }

  Future<Map<int, int>> fetchAuthorYearlyTrend({
    required String authorId,
    String? search,
    bool globalInfluential = false,
  }) async {
    final data = await _fetchWorksGroupBy(
      groupBy: 'publication_year',
      search: search,
      globalInfluential: false,
      filterOverride: _authorFilter(
        authorId: authorId,
        search: search,
        globalInfluential: false,
        includeTrendYears: true,
      ),
    );
    return parseGroupByYear(data);
  }

  Future<List<OpenAlexRankedEntity>> fetchAuthorTopJournals({
    required String authorId,
    String? search,
    bool globalInfluential = false,
    int limit = 5,
  }) {
    return fetchWorksGroupedCounts(
      groupBy: groupByJournal,
      search: search,
      globalInfluential: false,
      limit: limit,
      filterOverride: _authorFilter(
        authorId: authorId,
        search: search,
        globalInfluential: false,
      ),
    );
  }

  Future<Map<int, int>> fetchSourceYearlyTrend({
    required String sourceId,
    String? search,
    bool globalInfluential = false,
  }) async {
    final data = await _fetchWorksGroupBy(
      groupBy: 'publication_year',
      search: search,
      globalInfluential: false,
      filterOverride: _sourceFilter(
        sourceId: sourceId,
        search: search,
        globalInfluential: false,
        includeTrendYears: true,
      ),
    );
    return parseGroupByYear(data);
  }

  Future<List<OpenAlexRankedEntity>> fetchSourceTopAuthors({
    required String sourceId,
    String? search,
    bool globalInfluential = false,
    int limit = 5,
  }) {
    return fetchWorksGroupedCounts(
      groupBy: groupByAuthor,
      search: search,
      globalInfluential: false,
      limit: limit,
      filterOverride: _sourceFilter(
        sourceId: sourceId,
        search: search,
        globalInfluential: false,
      ),
    );
  }

  Future<List<TopicGrowthInsight>> fetchTopicGrowthInsights({
    required List<OpenAlexRankedEntity> concepts,
    String? search,
    bool globalInfluential = false,
    int limit = 5,
  }) async {
    final results = <TopicGrowthInsight>[];

    for (final concept in concepts.take(8)) {
      try {
        final trend = await fetchConceptYearlyTrend(
          conceptId: concept.id,
          search: search,
          globalInfluential: globalInfluential,
        );
        results.add(
          TopicGrowthInsight(
            id: concept.id,
            name: concept.name,
            growthPercent: ResearchInsights.computeConceptGrowth(trend),
          ),
        );
      } catch (_) {
        continue;
      }
    }

    results.sort((a, b) => b.growthPercent.compareTo(a.growthPercent));
    if (results.length <= limit) return results;
    return results.sublist(0, limit);
  }

  Map<String, String> _searchParams({
    required String search,
    SearchFilters? filters,
    SearchSortOption sort = SearchSortOption.mostCited,
  }) {
    final params = <String, String>{
      'search': search.trim(),
      'sort': sort.apiValue,
    };

    final filterParts = <String>[];
    if (filters?.publicationYear != null) {
      filterParts.add('publication_year:${filters!.publicationYear}');
    }
    if (filters?.minCitations != null) {
      filterParts.add('cited_by_count:>${filters!.minCitations}');
    }
    if (filters?.openAccessOnly == true) {
      filterParts.add('is_oa:true');
    }
    if (filters?.publicationType != null &&
        filters!.publicationType!.isNotEmpty) {
      filterParts.add('type:${filters.publicationType}');
    }
    if (filterParts.isNotEmpty) {
      params['filter'] = filterParts.join(',');
    }

    return params;
  }

  Map<String, String> _listBaseParams({
    String? search,
    bool globalInfluential = false,
  }) {
    if (search != null && search.trim().isNotEmpty) {
      return {
        'search': search.trim(),
        'sort': _sortCitedByDesc,
      };
    }

    var filter = 'publication_year:>2015';
    if (globalInfluential) {
      filter = 'publication_year:>2015,cited_by_count:>100';
    }

    return {
      'sort': _sortCitedByDesc,
      'filter': filter,
    };
  }

  Map<String, String> _yearListParams({
    required int year,
    String? search,
    bool globalInfluential = false,
  }) {
    return {
      'sort': _sortCitedByDesc,
      'filter': _yearFilter(
        year: year,
        search: search,
        globalInfluential: globalInfluential,
      ),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
  }

  String _yearFilter({
    required int year,
    String? search,
    bool globalInfluential = false,
  }) {
    var filter = 'publication_year:$year';
    if (globalInfluential && (search == null || search.trim().isEmpty)) {
      filter = '$filter,cited_by_count:>100';
    }
    return filter;
  }

  Future<OpenAlexWorksResult> _fetchFilteredWorksPage({
    required String filter,
    required int page,
    String? search,
    bool globalInfluential = false,
    int perPage = listPageSize,
  }) {
    final params = <String, String>{
      'sort': _sortCitedByDesc,
      'filter': filter,
    };

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    } else if (globalInfluential) {
      params['filter'] = '$filter,cited_by_count:>100';
    }

    return _fetchWorksResultPage(params, page: page, perPage: perPage);
  }

  Future<OpenAlexWorksResult> _fetchWorksResultPage(
    Map<String, String> baseParams, {
    required int page,
    int perPage = listPageSize,
  }) async {
    final pageResult = await _fetchWorksPage(
      baseParams,
      page: page,
      perPage: perPage,
    );

    return OpenAlexWorksResult(
      publications: pageResult.publications,
      totalOnOpenAlex: pageResult.totalOnOpenAlex,
    );
  }

  Future<Map<String, dynamic>> _fetchWorksGroupBy({
    required String groupBy,
    String? search,
    bool globalInfluential = false,
    String? filterOverride,
  }) async {
    final queryParams = _worksGroupByParams(
      groupBy: groupBy,
      search: search,
      globalInfluential: globalInfluential,
      filterOverride: filterOverride,
    );
    final url = _openAlexUri(_worksPath, queryParams);
    return _getJson(url);
  }

  Map<String, String> _worksGroupByParams({
    required String groupBy,
    String? search,
    bool globalInfluential = false,
    String? filterOverride,
  }) {
    var filter = filterOverride ?? _trendYearFilter;
    if (filterOverride == null &&
        globalInfluential &&
        (search == null || search.trim().isEmpty)) {
      filter = '$_trendYearFilter,cited_by_count:>100';
    }

    final queryParams = <String, String>{
      'group_by': groupBy,
      'filter': filter,
      'mailto': _mailto,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (_apiKey.isNotEmpty) {
      queryParams['api_key'] = _apiKey;
    }

    return queryParams;
  }

  static Map<int, int> parseGroupByYear(Map<String, dynamic> data) {
    final groups = data['group_by'] as List? ?? [];
    final result = <int, int>{};

    for (final group in groups) {
      if (group is! Map) continue;
      final key = group['key']?.toString();
      if (key == null || key == 'null') continue;

      final year = int.tryParse(key);
      if (year == null) continue;

      result[year] = (group['count'] as num?)?.toInt() ?? 0;
    }

    return result;
  }

  static Map<String, int> parseGroupByKeyCounts(
    Map<String, dynamic> data, {
    int limit = 8,
  }) {
    final groups = data['group_by'] as List? ?? [];
    final parsed = <MapEntry<String, int>>[];

    for (final group in groups) {
      if (group is! Map) continue;

      final key = group['key']?.toString();
      if (key == null || key == 'null') continue;

      final label = group['key_display_name']?.toString().trim();
      parsed.add(
        MapEntry(
          (label != null && label.isNotEmpty) ? label : key,
          (group['count'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    parsed.sort((a, b) => b.value.compareTo(a.value));
    final slice = parsed.length <= limit ? parsed : parsed.sublist(0, limit);
    return Map.fromEntries(slice);
  }

  static List<OpenAlexRankedEntity> parseGroupByNamedCounts(
    Map<String, dynamic> data, {
    int limit = 10,
  }) {
    final groups = data['group_by'] as List? ?? [];
    final parsed = <OpenAlexRankedEntity>[];

    for (final group in groups) {
      if (group is! Map) continue;

      final key = group['key']?.toString();
      if (key == null || key == 'null') continue;

      final name = group['key_display_name']?.toString().trim();
      if (name == null || name.isEmpty) continue;

      parsed.add(
        OpenAlexRankedEntity(
          id: key,
          name: name,
          count: (group['count'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    parsed.sort((a, b) => b.count.compareTo(a.count));
    if (parsed.length <= limit) return parsed;
    return parsed.sublist(0, limit);
  }

  Future<OpenAlexWorksResult> _fetchWorksPage(
    Map<String, String> baseParams, {
    required int page,
    int perPage = _perPage,
  }) async {
    final queryParams = <String, String>{
      ...baseParams,
      _perPageKey: '$perPage',
      'page': '$page',
      'select': baseParams['select'] ?? _selectFields,
      'mailto': _mailto,
    };

    if (_apiKey.isNotEmpty) {
      queryParams['api_key'] = _apiKey;
    }

    final url = _openAlexUri(_worksPath, queryParams);
    final data = await _getJson(url);

    final List results = data['results'] ?? [];
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    final total = (meta['count'] as num?)?.toInt() ?? results.length;

    final publications = results
        .map(
          (item) => Publication.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    return OpenAlexWorksResult(
      publications: publications,
      totalOnOpenAlex: total,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri url) async {
    http.Response? lastResponse;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        lastResponse = await _performGet(url);
        if (lastResponse.statusCode == 200) {
          return jsonDecode(lastResponse.body) as Map<String, dynamic>;
        }

        if (_retryStatusCodes.contains(lastResponse.statusCode) &&
            attempt < _maxRetries - 1) {
          await _backoff(attempt);
          continue;
        }

        break;
      } on TimeoutException {
        if (attempt >= _maxRetries - 1) {
          throw OpenAlexException(
            'OpenAlex không phản hồi (timeout). Server có thể đang quá tải — '
            'thử đổi Wi‑Fi/4G hoặc bấm Retry.',
          );
        }
        await _backoff(attempt);
      } on SocketException {
        if (attempt >= _maxRetries - 1) {
          throw OpenAlexException(
            'Không kết nối được OpenAlex. Kiểm tra internet trên thiết bị.',
          );
        }
        await _backoff(attempt);
      } on http.ClientException catch (e) {
        if (attempt >= _maxRetries - 1) {
          throw OpenAlexException(
            'Lỗi mạng khi gọi OpenAlex: ${e.message}',
          );
        }
        await _backoff(attempt);
      }
    }

    if (lastResponse != null) {
      throw _mapHttpError(lastResponse);
    }

    throw OpenAlexException(
      'Không tải được dữ liệu từ OpenAlex. Thử lại sau vài phút.',
    );
  }

  Future<http.Response> _performGet(Uri url) {
    return http
        .get(
          url,
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'JournalTrendAnalyzer/1.0 (PRM393 Lab2)',
          },
        )
        .timeout(_requestTimeout);
  }

  Future<void> _backoff(int attempt) async {
    await Future<void>.delayed(
      Duration(milliseconds: 1500 * (attempt + 1)),
    );
  }

  OpenAlexException _mapHttpError(http.Response response) {
    final code = response.statusCode;

    switch (code) {
      case 429:
        return OpenAlexException(
          'OpenAlex giới hạn request (429). Đợi 30 giây rồi bấm Retry.',
          statusCode: code,
        );
      case 502:
      case 503:
      case 504:
        return OpenAlexException(
          'Máy chủ OpenAlex tạm bận (HTTP $code). '
          'App đã thử $_maxRetries lần — thử lại sau.',
          statusCode: code,
        );
      case 401:
      case 403:
        return OpenAlexException(
          'API key không hợp lệ (HTTP $code). '
          'Chạy app bằng .\\scripts\\run.ps1',
          statusCode: code,
        );
      default:
        return OpenAlexException(
          'Không tải được dữ liệu (HTTP $code). Kiểm tra mạng và thử lại.',
          statusCode: code,
        );
    }
  }
}

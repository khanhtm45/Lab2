import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/analytics_extra_bundle.dart';
import '../models/openalex_ranked_entity.dart';
import '../providers/publication_provider.dart';
import '../services/analytics_cache_service.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/analytics_charts.dart';
import '../widgets/analytics_fallbacks.dart';
import '../widgets/analytics_section_skeleton.dart';
import '../widgets/app_logo.dart';
import '../screens/analytics_catalog_screen.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/trend_chart.dart';

enum _ExtraLoadState { idle, loading, ready, error }

/// 30 BI analytics — powered by OpenAlex API.
class AdvancedAnalyticsScreen extends StatefulWidget {
  final int? scrollToItemNo;

  const AdvancedAnalyticsScreen({super.key, this.scrollToItemNo});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> {
  int _loadGeneration = 0;

  List<OpenAlexRankedEntity> _keywords = [];
  List<ScatterPoint> _authorScatter = [];
  List<ScatterPoint> _journalScatter = [];
  Map<String, Map<int, int>> _emergingTrends = {};
  Map<String, Map<int, int>> _topicEvolution = {};
  AdvancedAnalyticsData _advanced = AdvancedAnalyticsData.empty;
  _ExtraLoadState _extraState = _ExtraLoadState.idle;
  String? _cacheKey;

  final Map<int, GlobalKey> _sectionKeys = {
    for (final item in analyticsCatalog) item.no: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadExtra(forceRefresh: false);
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    final provider = context.read<PublicationProvider>();
    if (_cacheKey != null) {
      AnalyticsCacheService.instance.invalidate(_cacheKey!);
    }
    await provider.refreshCurrentAnalysis();
    if (!mounted) return;
    setState(() {});
    await _loadExtra(forceRefresh: true);
  }

  void _applyBundle(AnalyticsExtraBundle bundle) {
    _keywords = bundle.keywords;
    _authorScatter = bundle.authorScatter;
    _journalScatter = bundle.journalScatter;
    _emergingTrends = bundle.emergingTrends;
    _topicEvolution = bundle.topicEvolution;
    _advanced = bundle.advanced;
    _cacheKey = bundle.cacheKey;
    _extraState = _ExtraLoadState.ready;
  }

  Future<void> _loadExtra({required bool forceRefresh}) async {
    if (!mounted) return;

    final generation = ++_loadGeneration;
    final provider = context.read<PublicationProvider>();
    final service = provider.openAlexService;
    final search = provider.isGlobalScope ? null : provider.currentTopic;
    final global = provider.isGlobalScope;
    final cacheKey = AnalyticsCacheService.instance.keyFor(search: search, global: global);

    if (!forceRefresh) {
      final cached = AnalyticsCacheService.instance.get(cacheKey);
      if (cached != null) {
        setState(() => _applyBundle(cached));
        _scrollToTarget();
        return;
      }
    }

    setState(() {
      _extraState = _ExtraLoadState.loading;
      _cacheKey = cacheKey;
    });

    try {
      final results = await Future.wait([
        service.fetchTopKeywords(search: search, globalInfluential: global, limit: 12),
        service.fetchAuthorScatterPoints(search: search, globalInfluential: global),
        service.fetchJournalScatterPoints(search: search, globalInfluential: global),
        service.fetchAdvancedAnalyticsBundle(search: search, globalInfluential: global),
      ]);
      if (!mounted || generation != _loadGeneration) return;

      final conceptSource = provider.topResearchAreasOpenAlex.isNotEmpty
          ? provider.topResearchAreasOpenAlex
          : results[0] as List<OpenAlexRankedEntity>;

      final emerging = await service.fetchEmergingTopicTrendSeries(
        concepts: conceptSource,
        search: search,
        globalInfluential: global,
        limit: 5,
      );
      final evolution = await service.fetchEmergingTopicTrendSeries(
        concepts: provider.topResearchAreasOpenAlex.isNotEmpty
            ? provider.topResearchAreasOpenAlex
            : conceptSource,
        search: search,
        globalInfluential: global,
        limit: 5,
      );

      if (!mounted || generation != _loadGeneration) return;

      final bundle = AnalyticsExtraBundle(
        keywords: results[0] as List<OpenAlexRankedEntity>,
        authorScatter: results[1] as List<ScatterPoint>,
        journalScatter: results[2] as List<ScatterPoint>,
        emergingTrends: emerging,
        topicEvolution: evolution,
        advanced: results[3] as AdvancedAnalyticsData,
        cacheKey: cacheKey,
        loadedAt: DateTime.now(),
      );
      AnalyticsCacheService.instance.put(bundle);

      setState(() => _applyBundle(bundle));
      _scrollToTarget();
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _extraState = _ExtraLoadState.error);
    }
  }

  void _scrollToTarget() {
    final target = widget.scrollToItemNo;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _sectionKeys[target]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  Widget _wrapExtraChild(AnalyticsCatalogItem item, Widget Function() builder) {
    if (!analyticsItemNeedsExtraData(item.no)) return builder();
    switch (_extraState) {
      case _ExtraLoadState.loading:
      case _ExtraLoadState.idle:
        return const AnalyticsChartSkeleton();
      case _ExtraLoadState.error:
        return AnalyticsSectionError(onRetry: () => _loadExtra(forceRefresh: true));
      case _ExtraLoadState.ready:
        return builder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicationProvider>();
    final palette = context.palette;
    final s = context.strings;
    final velocity = provider.openAlexService
        .computeCitationVelocity(provider.citationsByYearOpenAlex);
    final frontierBubbles = frontierBubblePoints(
      _keywords,
      provider.growingTopicsOpenAlex,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(s.advancedAnalytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list_rounded),
            tooltip: s.biAnalyticsCatalog,
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsCatalogScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _extraState == _ExtraLoadState.loading ? null : _onRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              s.thirtyBiVisualizations,
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
            if (_extraState == _ExtraLoadState.loading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.loadingExtendedMetrics,
                      style: TextStyle(fontSize: 12, color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            if (_extraState == _ExtraLoadState.error)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AnalyticsSectionError(
                  message: s.analyticsLoadFailed,
                  onRetry: () => _loadExtra(forceRefresh: true),
                ),
              ),
            const SizedBox(height: 8),
            const _CatalogSummary(),
            const SizedBox(height: 20),
            ...analyticsCatalog.map(
              (item) => _AnalyticsSection(
                key: _sectionKeys[item.no],
                item: item,
                child: _wrapExtraChild(
                  item,
                  () => _buildChart(item, provider, velocity, frontierBubbles, s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    AnalyticsCatalogItem item,
    PublicationProvider provider,
    Map<int, int> velocity,
    List<BubblePoint> frontierBubbles,
    AppStrings s,
  ) {
    switch (item.no) {
      case 1:
        return TrendChart(yearlyData: provider.yearlyTrendFromOpenAlex);
      case 2:
        return TrendChart(yearlyData: provider.citationsByYearOpenAlex);
      case 3:
        return HorizontalRankChart(title: item.localizedName(s), items: _keywords);
      case 4:
        if (_emergingTrends.isNotEmpty) {
          return MultiSeriesTrendChart(series: _emergingTrends);
        }
        return MultiSeriesTrendChart(
          series: {
            for (final k in _keywords.take(4)) k.name: provider.yearlyTrendFromOpenAlex,
          },
        );
      case 5:
        if (_topicEvolution.isNotEmpty) {
          return MultiSeriesTrendChart(series: _topicEvolution, filled: true);
        }
        return AreaTrendChart(yearlyData: provider.yearlyTrendFromOpenAlex);
      case 6:
        return SimpleTreemap(
          items: provider.topResearchAreasOpenAlex.isNotEmpty
              ? provider.topResearchAreasOpenAlex
              : _keywords,
        );
      case 7:
        return HorizontalRankChart(title: item.localizedName(s), items: provider.topAuthorsOpenAlex);
      case 8:
        return ScatterAnalyticsChart(
          points: topCitedAuthorPoints(_authorScatter),
          xLabel: s.publicationsLabel,
          yLabel: s.totalCitations,
        );
      case 9:
        return ScatterAnalyticsChart(
          points: _authorScatter,
          xLabel: s.productivityWorks,
          yLabel: s.impactCitations,
        );
      case 10:
        return HorizontalRankChart(
          title: item.localizedName(s),
          items: provider.topInstitutionsOpenAlex,
        );
      case 11:
        return BubbleAnalyticsChart(
          points: _advanced.institutionBubbles.isNotEmpty
              ? _advanced.institutionBubbles
              : provider.topInstitutionsOpenAlex
                  .take(8)
                  .map(
                    (e) => BubblePoint(
                      label: e.name,
                      x: e.count.toDouble(),
                      y: e.count * 1.5,
                      size: e.count.toDouble(),
                    ),
                  )
                  .toList(),
        );
      case 12:
        return WorldCountryMapChart(items: provider.topCountriesOpenAlex);
      case 13:
        return WorldCountryMapChart(
          items: _advanced.countryByCitations.isNotEmpty
              ? _advanced.countryByCitations
              : provider.topCountriesOpenAlex,
          citationMode: true,
        );
      case 14:
        return HorizontalRankChart(title: item.localizedName(s), items: provider.topJournalsOpenAlex);
      case 15:
        return ScatterAnalyticsChart(
          points: _journalScatter,
          xLabel: s.publicationsLabel,
          yLabel: s.citations,
        );
      case 16:
        return DistributionChart(
          data: _advanced.citationQuartiles.isNotEmpty
              ? _advanced.citationQuartiles
              : provider.oaDistribution,
          donut: true,
        );
      case 17:
        return NetworkGraphView(
          graph: resolveNetwork(
            _advanced.citationNetwork,
            provider.topPapersOpenAlex
                .map((p) => OpenAlexRankedEntity(id: p.id, name: p.title, count: p.citations))
                .toList(),
          ),
        );
      case 18:
        return NetworkGraphView(
          graph: resolveNetwork(_advanced.authorCollaboration, provider.topAuthorsOpenAlex),
        );
      case 19:
        return NetworkGraphView(
          graph: resolveNetwork(
            _advanced.institutionCollaboration,
            provider.topInstitutionsOpenAlex,
            mesh: true,
          ),
        );
      case 20:
        final countryScatter = countryCollaborationScatter(
          graph: _advanced.countryCollaboration,
          countries: provider.topCountriesOpenAlex,
        );
        if (countryScatter.isEmpty) {
          return ScatterAnalyticsChart(
            points: provider.topCountriesOpenAlex
                .map((c) => ScatterPoint(label: c.name, x: c.count.toDouble(), y: c.count * 0.6))
                .toList(),
            xLabel: s.publicationsLabel,
            yLabel: s.collaborationIndex,
          );
        }
        return ScatterAnalyticsChart(
          points: countryScatter,
          xLabel: s.publicationsLabel,
          yLabel: s.collaborationLinks,
        );
      case 21:
        return NetworkGraphView(
          graph: resolveNetwork(_advanced.keywordCooccurrence, _keywords),
        );
      case 22:
        return NetworkGraphView(
          graph: resolveNetwork(
            _advanced.topicCooccurrence,
            provider.topResearchAreasOpenAlex,
          ),
        );
      case 23:
        return _buildHeatmap(
          resolveHeatmap(
            _advanced.journalTopicMatrix,
            rows: provider.topJournalsOpenAlex,
            cols: provider.topResearchAreasOpenAlex,
          ),
        );
      case 24:
        return _buildHeatmap(
          resolveHeatmap(
            _advanced.authorTopicMatrix,
            rows: provider.topAuthorsOpenAlex,
            cols: provider.topResearchAreasOpenAlex,
          ),
        );
      case 25:
        return _buildHeatmap(
          resolveHeatmap(
            _advanced.institutionTopicMatrix,
            rows: provider.topInstitutionsOpenAlex,
            cols: provider.topResearchAreasOpenAlex,
          ),
        );
      case 26:
        return _buildHeatmap(
          resolveHeatmap(
            _advanced.countryTopicMatrix,
            rows: provider.topCountriesOpenAlex,
            cols: provider.topResearchAreasOpenAlex,
          ),
        );
      case 27:
        return BubbleAnalyticsChart(points: frontierBubbles);
      case 28:
        return TrendChart(
          yearlyData: velocity.isNotEmpty ? velocity : provider.citationsByYearOpenAlex,
        );
      case 29:
        return SimpleSankeyView(flows: _advanced.journalMigrationFlows);
      case 30:
        return _EcosystemOverview(
          provider: provider,
          keywords: _keywords,
          advanced: _advanced,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeatmap(HeatmapData data) {
    return SimpleHeatmapMatrix(
      rowLabels: data.rowLabels,
      colLabels: data.colLabels,
      values: data.values,
    );
  }
}

class _CatalogSummary extends StatelessWidget {
  const _CatalogSummary();

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    final live = analyticsCatalog.where((e) => e.status == AnalyticsStatus.implemented).length;

    return MockupCard(
      child: Row(
        children: [
          _StatChip(s.catalogComplete(live), palette.primary),
          const SizedBox(width: 8),
          _StatChip(s.openAlexLive, palette.accent),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  final AnalyticsCatalogItem item;
  final Widget child;

  const _AnalyticsSection({
    super.key,
    required this.item,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: MockupCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.no}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: palette.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.localizedName(s),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        '${item.localizedFactTable(s)} × ${item.localizedDimensionTable(s)}',
                        style: TextStyle(fontSize: 10, color: palette.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.displayType.icon, size: 11, color: palette.secondary),
                      const SizedBox(width: 4),
                      Text(
                        item.displayType.labelFor(s),
                        style: TextStyle(
                          fontSize: 9,
                          color: palette.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.localizedDescription(s),
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _EcosystemOverview extends StatelessWidget {
  final PublicationProvider provider;
  final List<OpenAlexRankedEntity> keywords;
  final AdvancedAnalyticsData advanced;

  const _EcosystemOverview({
    required this.provider,
    required this.keywords,
    required this.advanced,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.topicLabel(provider.currentTopic),
          style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MiniKpi(s.papers, formatOpenAlexCount(provider.totalOnOpenAlex))),
            Expanded(child: _MiniKpi(s.authors, '${provider.topAuthorsOpenAlex.length}')),
            Expanded(child: _MiniKpi(s.journals, '${provider.topJournalsOpenAlex.length}')),
            Expanded(child: _MiniKpi(s.countries, '${provider.topCountriesOpenAlex.length}')),
          ],
        ),
        const SizedBox(height: 16),
        Text(s.publicationTrend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textPrimary)),
        const SizedBox(height: 8),
        SizedBox(height: 130, child: TrendChart(yearlyData: provider.yearlyTrendFromOpenAlex)),
        const SizedBox(height: 16),
        Text(s.topJournalsChart, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textPrimary)),
        const SizedBox(height: 8),
        HorizontalRankChart(
          title: s.journals,
          items: provider.topJournalsOpenAlex,
          maxItems: 5,
        ),
        const SizedBox(height: 16),
        Text(s.openAccessMix, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textPrimary)),
        const SizedBox(height: 8),
        DistributionChart(data: provider.oaDistribution, donut: true),
        const SizedBox(height: 16),
        Text(s.keywordNetwork, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textPrimary)),
        const SizedBox(height: 8),
        KeywordHubNetworkView(
          centerLabel: provider.currentTopic,
          keywords: keywords.map((k) => k.name).toList(),
          cooccurrence: advanced.keywordCooccurrence,
          height: 200,
        ),
        const SizedBox(height: 16),
        Text(s.countryOutput, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.textPrimary)),
        const SizedBox(height: 8),
        WorldCountryMapChart(items: provider.topCountriesOpenAlex.take(8).toList()),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;
  const _MiniKpi(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: palette.primary,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: palette.textSecondary)),
      ],
    );
  }
}

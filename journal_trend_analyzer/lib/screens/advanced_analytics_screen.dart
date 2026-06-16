import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/openalex_ranked_entity.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/analytics_charts.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/citation_bar_chart.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/trend_chart.dart';

/// 30 BI analytics — powered by [OpenAlex API](https://developers.openalex.org/api-reference/introduction)
class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> {
  int _loadGeneration = 0;

  List<OpenAlexRankedEntity> _keywords = [];
  List<ScatterPoint> _authorScatter = [];
  List<ScatterPoint> _journalScatter = [];
  AdvancedAnalyticsData _advanced = AdvancedAnalyticsData.empty;
  bool _loadingExtra = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadExtra();
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    await context.read<PublicationProvider>().refreshCurrentAnalysis();
    if (!mounted) return;
    setState(() {});
    await _loadExtra();
  }

  Future<void> _loadExtra() async {
    if (!mounted) return;

    final generation = ++_loadGeneration;
    final provider = context.read<PublicationProvider>();
    final service = provider.openAlexService;
    final search = provider.isGlobalScope ? null : provider.currentTopic;
    final global = provider.isGlobalScope;

    setState(() => _loadingExtra = true);
    try {
      final results = await Future.wait([
        service.fetchTopKeywords(search: search, globalInfluential: global, limit: 10),
        service.fetchAuthorScatterPoints(search: search, globalInfluential: global),
        service.fetchJournalScatterPoints(search: search, globalInfluential: global),
        service.fetchAdvancedAnalyticsBundle(search: search, globalInfluential: global),
      ]);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _keywords = results[0] as List<OpenAlexRankedEntity>;
        _authorScatter = results[1] as List<ScatterPoint>;
        _journalScatter = results[2] as List<ScatterPoint>;
        _advanced = results[3] as AdvancedAnalyticsData;
        _loadingExtra = false;
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _loadingExtra = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PublicationProvider>();
    final velocity = provider.openAlexService
        .computeCitationVelocity(provider.citationsByYearOpenAlex);
    final frontierBubbles = provider.growingTopicsOpenAlex
        .map(
          (t) => BubblePoint(
            label: t.name,
            x: t.growthPercent,
            y: t.growthPercent,
            size: t.growthPercent.abs(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingExtra ? null : _onRefresh,
          ),
        ],
      ),
      body: _loadingExtra
          ? const AppLoadingView(
              fillScreen: false,
              expand: true,
              size: 180,
              message: 'Fetching advanced metrics...',
            )
          : RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const Text(
              '30 BI Visualizations · OpenAlex',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const _CatalogSummary(),
            const SizedBox(height: 20),
            ...analyticsCatalog.map(
              (item) => _AnalyticsSection(
                item: item,
                child: _buildChart(item, provider, velocity, frontierBubbles),
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
  ) {
    if (item.status == AnalyticsStatus.planned) {
      return const _PlannedNote();
    }

    switch (item.no) {
      case 1:
        return TrendChart(yearlyData: provider.yearlyTrendFromOpenAlex);
      case 2:
        return CitationBarChart(yearlyData: provider.citationsByYearOpenAlex);
      case 3:
        return HorizontalRankChart(title: item.name, items: _keywords);
      case 4:
        if (provider.growingTopicsOpenAlex.isEmpty) {
          return const Text(
            'No emerging keyword data yet.',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: provider.growingTopicsOpenAlex.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(t.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    t.formattedGrowth,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      case 5:
        return AreaTrendChart(yearlyData: provider.yearlyTrendFromOpenAlex);
      case 6:
        return SimpleTreemap(items: provider.topResearchAreasOpenAlex);
      case 7:
        return HorizontalRankChart(title: item.name, items: provider.topAuthorsOpenAlex);
      case 8:
      case 9:
        return ScatterAnalyticsChart(points: _authorScatter);
      case 10:
        return HorizontalRankChart(title: item.name, items: provider.topInstitutionsOpenAlex);
      case 11:
        return BubbleAnalyticsChart(
          points: _advanced.institutionBubbles.isNotEmpty
              ? _advanced.institutionBubbles
              : provider.topInstitutionsOpenAlex
                  .take(6)
                  .map(
                    (e) => BubblePoint(
                      label: e.name,
                      x: e.count.toDouble(),
                      y: e.count.toDouble(),
                      size: e.count.toDouble(),
                    ),
                  )
                  .toList(),
        );
      case 12:
        return CountryIntensityChart(items: provider.topCountriesOpenAlex);
      case 13:
        return CountryIntensityChart(
          items: _advanced.countryByCitations.isNotEmpty
              ? _advanced.countryByCitations
              : provider.topCountriesOpenAlex,
          citationMode: true,
        );
      case 14:
        return HorizontalRankChart(title: item.name, items: provider.topJournalsOpenAlex);
      case 15:
        return ScatterAnalyticsChart(
          points: _journalScatter,
          xLabel: 'Publications',
          yLabel: 'Citations (sample)',
        );
      case 16:
        if (_advanced.citationQuartiles.isNotEmpty) {
          return DistributionChart(data: _advanced.citationQuartiles, donut: true);
        }
        return DistributionChart(data: provider.oaDistribution, donut: true);
      case 17:
        return NetworkGraphView(graph: _advanced.citationNetwork);
      case 18:
        return NetworkGraphView(graph: _advanced.authorCollaboration);
      case 19:
        return NetworkGraphView(graph: _advanced.institutionCollaboration);
      case 20:
        return NetworkGraphView(graph: _advanced.countryCollaboration);
      case 21:
        return NetworkGraphView(graph: _advanced.keywordCooccurrence);
      case 22:
        return NetworkGraphView(graph: _advanced.topicCooccurrence);
      case 23:
        return _buildHeatmap(_advanced.journalTopicMatrix);
      case 24:
        return _buildHeatmap(_advanced.authorTopicMatrix);
      case 25:
        return _buildHeatmap(_advanced.institutionTopicMatrix);
      case 26:
        return _buildHeatmap(_advanced.countryTopicMatrix);
      case 27:
        return BubbleAnalyticsChart(points: frontierBubbles);
      case 28:
        if (velocity.isEmpty) {
          return const Text(
            'Not enough years for citation velocity.',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }
        return TrendChart(yearlyData: velocity);
      case 29:
        return SimpleSankeyView(flows: _advanced.journalMigrationFlows);
      case 30:
        return _EcosystemOverview(provider: provider);
      default:
        return const _PartialNote();
    }
  }

  Widget _buildHeatmap(HeatmapData data) {
    if (data.isEmpty) {
      return const Text(
        'Not enough co-occurrence data from OpenAlex sample.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      );
    }
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
    final live = analyticsCatalog.where((e) => e.status == AnalyticsStatus.implemented).length;
    final partial = analyticsCatalog.where((e) => e.status == AnalyticsStatus.partial).length;
    final planned = analyticsCatalog.where((e) => e.status == AnalyticsStatus.planned).length;

    return MockupCard(
      child: Row(
        children: [
          _StatChip('$live Live', AppColors.primary),
          const SizedBox(width: 8),
          _StatChip('$partial Partial', AppColors.secondary),
          const SizedBox(width: 8),
          _StatChip('$planned Planned', AppColors.textTertiary),
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
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  final AnalyticsCatalogItem item;
  final Widget child;

  const _AnalyticsSection({required this.item, required this.child});

  @override
  Widget build(BuildContext context) {
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
                    color: statusColor(item.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${item.no}', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor(item.status), fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(
                        '${item.factTable} × ${item.dimensionTable}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor(item.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusLabel(item.status), style: TextStyle(fontSize: 10, color: statusColor(item.status), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
  const _EcosystemOverview({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Topic: ${provider.currentTopic}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MiniKpi('Papers', formatOpenAlexCount(provider.totalOnOpenAlex))),
            Expanded(child: _MiniKpi('Authors', '${provider.topAuthorsOpenAlex.length}+')),
            Expanded(child: _MiniKpi('Journals', '${provider.topJournalsOpenAlex.length}+')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: TrendChart(yearlyData: provider.yearlyTrendFromOpenAlex),
        ),
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
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _PartialNote extends StatelessWidget {
  const _PartialNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Phiên bản mobile dùng proxy/simplified chart. Map, Sankey và full network cần web dashboard hoặc data warehouse.',
      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
    );
  }
}

class _PlannedNote extends StatelessWidget {
  const _PlannedNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Cần thêm dữ liệu collaboration/matrix từ ETL — sẽ bổ sung trong phiên bản sau.',
      style: TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.4),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/search_filters.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/analytics_charts.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/topic_comparison_result_card.dart';
import 'advanced_analytics_screen.dart';
import 'analytics_catalog_screen.dart';
import 'keywords_topics_screen.dart';
import 'research_domains_screen.dart';
import 'topic_comparison_screen.dart';

/// Explore — trending topics, domains, keyword network, topic comparison
class ExploreScreen extends StatefulWidget {
  final bool embedded;

  const ExploreScreen({super.key, this.embedded = false});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _trendingTopics = [
    'Generative AI',
    'Large Language Models',
    'AI Agents',
    'Edge AI',
    'IoT Security',
  ];

  static const _aiTopic = 'Artificial Intelligence';

  static const _comparisonPairs = [
    (_aiTopic, 'Blockchain'),
    (_aiTopic, 'Internet of Things'),
    (_aiTopic, 'Cybersecurity'),
  ];

  TopicComparisonResult? _comparison;
  bool _comparing = false;
  String? _compareError;

  NetworkGraphData? _keywordGraph;
  bool _loadingKeywordGraph = false;
  String? _keywordGraphScopeKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<PublicationProvider>();
    final scopeKey = provider.isGlobalScope
        ? 'global'
        : provider.currentTopic.trim().toLowerCase();
    if (_keywordGraphScopeKey == scopeKey) return;
    _keywordGraphScopeKey = scopeKey;
    _loadKeywordGraph(provider);
  }

  Future<void> _loadKeywordGraph(PublicationProvider provider) async {
    setState(() => _loadingKeywordGraph = true);
    try {
      final graph = await context
          .read<PublicationProvider>()
          .openAlexService
          .fetchKeywordCooccurrenceNetwork(
        search: provider.isGlobalScope ? null : provider.currentTopic,
        globalInfluential: false,
      );
      if (!mounted) return;
      setState(() => _keywordGraph = graph);
    } catch (_) {
      if (!mounted) return;
      setState(() => _keywordGraph = null);
    } finally {
      if (mounted) setState(() => _loadingKeywordGraph = false);
    }
  }

  Future<void> _compare(String a, String b) async {
    setState(() {
      _comparing = true;
      _compareError = null;
      _comparison = null;
    });

    try {
      final result = await context
          .read<PublicationProvider>()
          .openAlexService
          .compareTopics(a, b);
      if (!mounted) return;
      setState(() => _comparison = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _compareError = e.toString());
    } finally {
      if (mounted) setState(() => _comparing = false);
    }
  }

  void _exploreTopic(String topic) {
    context.read<AppNavigationProvider>().goToTab(1);
    context.read<PublicationProvider>().searchPublications(topic);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final s = context.strings;
    final palette = context.palette;
    final keywords = provider.topResearchAreasOpenAlex.take(6).toList();
    final networkCenter =
        provider.isGlobalScope ? 'Research' : provider.currentTopic;

    final content = ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimens.pagePadding,
          widget.embedded ? 4 : 12,
          AppDimens.pagePadding,
          24,
        ),
        children: [
          if (!widget.embedded) ...[
            Text(
              s.explore,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 22,
                    color: palette.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              s.exploreSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 8),
          _SectionTitle(s.advancedBiAnalytics),
          const SizedBox(height: 10),
          MockupCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.thirtyVisualizations,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.biAnalyticsDesc,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnalyticsCatalogScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.table_chart_outlined, size: 18),
                  label: Text(s.biCatalog),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdvancedAnalyticsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: Text(s.openAllCharts),
                ),
                const SizedBox(height: 16),
                Text(
                  s.featuredCharts,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ...analyticsCatalog.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdvancedAnalyticsScreen(
                              scrollToItemNo: item.no,
                            ),
                          ),
                        ),
                        icon: Icon(item.displayType.icon, size: 16),
                        label: Text('${item.no}. ${item.localizedName(s)}'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(s.trendingTopics),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingTopics
                .map(
                  (topic) => ActionChip(
                    label: Text(topic),
                    backgroundColor: AppColors.surfaceMuted,
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    side: const BorderSide(color: AppColors.accent),
                    onPressed: () => _exploreTopic(topic),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          _SectionTitle(s.researchDomains),
          const SizedBox(height: 10),
          MockupCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.domainHierarchy,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.domainBrowseDesc,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResearchDomainsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.account_tree_outlined, size: 18),
                  label: Text(s.openResearchDomains),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SectionTitle(s.keywordNetwork),
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KeywordsTopicsScreen(),
                  ),
                ),
                icon: const Icon(Icons.cloud_outlined, size: 18),
                label: Text(s.keywordsAndTopics),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MockupCard(
            child: _loadingKeywordGraph && keywords.isEmpty
                ? AppLoadingView(
                    fillScreen: false,
                    size: 100,
                    message: s.loadingKeywordNetwork,
                  )
                : KeywordHubNetworkView(
                    centerLabel: networkCenter,
                    keywords: keywords.map((k) => k.name).toList(),
                    cooccurrence: _keywordGraph,
                    height: 240,
                  ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(s.topicComparison),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TopicComparisonScreen(),
              ),
            ),
            icon: const Icon(Icons.compare_arrows_rounded, size: 18),
            label: Text(s.compareCustomTopics),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _comparisonPairs
                .map(
                  (pair) => OutlinedButton(
                    onPressed: _comparing ? null : () => _compare(pair.$1, pair.$2),
                    child: Text('${pair.$1.split(' ').first} vs ${pair.$2.split(' ').first}'),
                  ),
                )
                .toList(),
          ),
          if (_comparing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppLoadingView(
                fillScreen: false,
                size: 140,
                message: s.comparingTopics,
              ),
            ),
          if (_compareError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _compareError!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          if (_comparison != null) ...[
            const SizedBox(height: 16),
            MockupCard(
              padding: const EdgeInsets.all(16),
              child: TopicComparisonResultCard(result: _comparison!),
            ),
          ],
        ],
      );

    return widget.embedded ? content : SafeArea(child: content);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
    );
  }
}


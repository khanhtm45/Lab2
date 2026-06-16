import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/advanced_analytics_data.dart';
import '../models/search_filters.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/analytics_charts.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import 'advanced_analytics_screen.dart';
import 'research_domains_screen.dart';

/// Explore — trending topics, domains, keyword network, topic comparison
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

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
    final keywords = provider.topResearchAreasOpenAlex.take(6).toList();
    final networkCenter =
        provider.isGlobalScope ? 'Research' : provider.currentTopic;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Text(
            'Explore',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Discover research ecosystems · OpenAlex',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Advanced BI Analytics'),
          const SizedBox(height: 10),
          MockupCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '30 visualizations',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Publication trend, scatter, treemap, heatmap, network… từ OpenAlex API.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdvancedAnalyticsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Open Advanced Analytics'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Trending Topics'),
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
          const _SectionTitle('Research Domains'),
          const SizedBox(height: 10),
          MockupCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Domain → Field → Subfield',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Browse OpenAlex concept hierarchy and field distribution.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
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
                  label: const Text('Open Research Domains'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Keyword Network'),
          const SizedBox(height: 10),
          MockupCard(
            child: _loadingKeywordGraph && keywords.isEmpty
                ? const AppLoadingView(
                    fillScreen: false,
                    size: 100,
                    message: 'Loading keyword network...',
                  )
                : KeywordHubNetworkView(
                    centerLabel: networkCenter,
                    keywords: keywords.map((k) => k.name).toList(),
                    cooccurrence: _keywordGraph,
                    height: 240,
                  ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Topic Comparison'),
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
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: AppLoadingView(
                fillScreen: false,
                size: 140,
                message: 'Comparing topics...',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_comparison!.topicA} vs ${_comparison!.topicB}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _CompareRow(
                    label: 'Publications',
                    a: formatOpenAlexCount(_comparison!.publicationsA),
                    b: formatOpenAlexCount(_comparison!.publicationsB),
                  ),
                  _CompareRow(
                    label: 'Avg. Citations',
                    a: _comparison!.avgCitationsA.toStringAsFixed(1),
                    b: _comparison!.avgCitationsB.toStringAsFixed(1),
                  ),
                  _CompareRow(
                    label: 'Top Authors',
                    a: '${_comparison!.authorsA}',
                    b: '${_comparison!.authorsB}',
                  ),
                  _CompareRow(
                    label: 'Top Journals',
                    a: '${_comparison!.journalsA}',
                    b: '${_comparison!.journalsB}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String a;
  final String b;

  const _CompareRow({required this.label, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              a,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              b,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


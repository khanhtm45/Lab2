import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/openalex_ranked_entity.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/citation_bar_chart.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/research_landscape_grid.dart';
import '../widgets/trend_chart.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/error_banner.dart';
import 'author_detail_screen.dart';
import 'citation_leaders_screen.dart';
import 'detail_screen.dart';
import 'domain_detail_screen.dart';
import 'growth_screen.dart';
import 'journal_detail_screen.dart';
import 'journals_analysis_screen.dart';
import 'research_domains_screen.dart';

/// Overview / Dashboard — màn chính theo mockup JournalAI
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();

    return SafeArea(
      child: Column(
        children: [
          const JournalAiAppBar(showRefresh: true, showBell: false),
          Expanded(child: _OverviewMainArea(provider: provider)),
        ],
      ),
    );
  }
}

class _OverviewMainArea extends StatelessWidget {
  final PublicationProvider provider;

  const _OverviewMainArea({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isDashboardLoading && !provider.hasData) {
      return const AppLoadingView(
        fillScreen: false,
        expand: true,
        message: 'Loading research data...',
      );
    }

    if (provider.errorMessage != null && !provider.hasData) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: ErrorBanner(
          message: provider.errorMessage!,
          onRetry: () => provider.loadDefaultDashboard(),
        ),
      );
    }

    if (!provider.hasData) {
      return const AppLoadingView(
        fillScreen: false,
        expand: true,
        message: 'Loading research data...',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshCurrentAnalysis(),
      child: _OverviewDashboardList(provider: provider),
    );
  }
}

class _OverviewDashboardList extends StatelessWidget {
  final PublicationProvider provider;

  const _OverviewDashboardList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    if (provider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ErrorBanner(
                          message: provider.errorMessage!,
                          onRetry: () => provider.refreshCurrentAnalysis(),
                        ),
                      ),
                    const Text(
                      'Research Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Topic: ${provider.currentTopic}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.15,
                      children: [
                        DashboardCard(
                          title: 'Total Publications',
                          value: formatOpenAlexCount(provider.totalOnOpenAlex),
                          icon: Icons.article_outlined,
                        ),
                        DashboardCard(
                          title: 'Average Citations',
                          value: provider.averageCitationOpenAlex.toStringAsFixed(1),
                          icon: Icons.format_quote_outlined,
                        ),
                        DashboardCard(
                          title: 'Most Active Year',
                          value: provider.mostActiveYearLabel,
                          icon: Icons.calendar_today_outlined,
                        ),
                        DashboardCard(
                          title: 'Top Journal',
                          value: provider.topJournalLabel,
                          icon: Icons.menu_book_outlined,
                          onTap: provider.topJournalsOpenAlex.isEmpty
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JournalDetailScreen(
                                        journal: provider.topJournalsOpenAlex.first,
                                        provider: provider,
                                      ),
                                    ),
                                  ),
                        ),
                        DashboardCard(
                          title: 'Top Author',
                          value: provider.topAuthorLabel,
                          icon: Icons.person_outline,
                          onTap: provider.topAuthorsOpenAlex.isEmpty
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AuthorDetailScreen(
                                        author: provider.topAuthorsOpenAlex.first,
                                        provider: provider,
                                      ),
                                    ),
                                  ),
                        ),
                        DashboardCard(
                          title: 'Most Influential Paper',
                          value: provider.topPaperLabel,
                          icon: Icons.emoji_events_outlined,
                          onTap: provider.topPapersOpenAlex.isEmpty
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailScreen(
                                        publication: provider.topPapersOpenAlex.first,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Publication Growth',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MockupCard(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                      child: TrendChart(
                        yearlyData: provider.yearlyTrendFromOpenAlex,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Citation Growth',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MockupCard(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                      child: CitationBarChart(
                        yearlyData: provider.citationsByYearOpenAlex,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Quick Insights',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MockupCard(
                      child: Column(
                        children: [
                          _QuickInsightRow(
                            label: 'Top Journal',
                            value: provider.topJournalLabel,
                            onTap: provider.topJournalsOpenAlex.isEmpty
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const JournalsAnalysisScreen(),
                                      ),
                                    ),
                          ),
                          const Divider(height: 1),
                          _QuickInsightRow(
                            label: 'Top Author',
                            value: provider.topAuthorLabel,
                            onTap: provider.topAuthorsOpenAlex.isEmpty
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CitationLeadersScreen(),
                                      ),
                                    ),
                          ),
                          const Divider(height: 1),
                          _QuickInsightRow(
                            label: 'Top Paper',
                            value: provider.topPaperLabel,
                            onTap: provider.topPapersOpenAlex.isEmpty
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailScreen(
                                          publication: provider.topPapersOpenAlex.first,
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    MockupCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatOpenAlexCount(
                                        provider.totalOnOpenAlex,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        height: 1.1,
                                      ),
                                    ),
                                    const Text(
                                      'Publications',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Influential works since 2015 · OpenAlex',
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GrowthBadge(
                                percent: provider.landscapePulse.yoyGrowthPercent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              StatColumn(
                                label: 'Average Citations',
                                value: provider.averageCitationOpenAlex
                                    .toStringAsFixed(1),
                                hint: 'top 100 avg',
                              ),
                              StatColumn(
                                label: 'Peak Year',
                                value: provider.landscapePulse.peakYear > 0
                                    ? '${provider.landscapePulse.peakYear}'
                                    : 'N/A',
                                hint: 'most papers',
                              ),
                              StatColumn(
                                label: 'Coverage',
                                value: '2015–${DateTime.now().year}',
                                hint: 'years',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Research Domains Map',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap a domain to explore its research profile',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MockupCard(
                      child: ResearchLandscapeGrid(
                        domains: provider.trendingAreas,
                        onDomainTap: (domain) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DomainDetailScreen(domain: domain),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Research Landscape',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LandscapeTile(
                      icon: Icons.trending_up_outlined,
                      title: 'Research Growth',
                      subtitle: 'Publication trends over time',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GrowthScreen(),
                        ),
                      ),
                    ),
                    LandscapeTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Citation Leaders',
                      subtitle: 'Most cited papers and authors',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CitationLeadersScreen(),
                        ),
                      ),
                    ),
                    LandscapeTile(
                      icon: Icons.menu_book_outlined,
                      title: 'Publication Sources',
                      subtitle: 'Top journals and venues',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JournalsAnalysisScreen(),
                        ),
                      ),
                    ),
                    LandscapeTile(
                      icon: Icons.hub_outlined,
                      title: 'Research Domains',
                      subtitle: 'Field distribution and hot topics',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResearchDomainsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (provider.growingTopicsOpenAlex.isNotEmpty) ...[
                      const Text(
                        'Emerging Topics',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Concept growth · tap to explore domain',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      MockupCard(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Column(
                          children: provider.growingTopicsOpenAlex
                              .take(5)
                              .map(
                                (topic) => InkWell(
                                  onTap: () {
                                    final domain = provider.rankedConceptById(
                                          topic.id,
                                        ) ??
                                        OpenAlexRankedEntity(
                                          id: topic.id,
                                          name: topic.name,
                                          count: 0,
                                        );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DomainDetailScreen(
                                          domain: domain,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        const Text(
                                          '🔥',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                topic.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Text(
                                                'growth vs early period',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              topic.formattedGrowth,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const Text(
                                              'growth',
                                              style: TextStyle(
                                                color: AppColors.textTertiary,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: AppColors.textTertiary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
    );
  }
}

class _QuickInsightRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _QuickInsightRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

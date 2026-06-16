import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publication.dart';
import '../models/openalex_ranked_entity.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/error_banner.dart';
import '../widgets/ranked_list_widgets.dart';
import 'author_detail_screen.dart';
import 'detail_screen.dart';
import 'journal_detail_screen.dart';

/// Insights — Top 20 papers, authors, journals, institutions, countries
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();

    if (provider.isDashboardLoading && !provider.hasData) {
      return const SafeArea(
        child: AppLoadingView(
          fillScreen: false,
          expand: true,
          message: 'Loading insights...',
        ),
      );
    }

    if (!provider.hasData) {
      return const SafeArea(
        child: Center(child: Text('Load dashboard data first')),
      );
    }

    return DefaultTabController(
      length: 5,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.refreshCurrentAnalysis(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                provider.isGlobalScope
                    ? 'Global research · OpenAlex'
                    : provider.currentTopic,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: ErrorBanner(
                  message: provider.errorMessage!,
                  onRetry: () => provider.refreshCurrentAnalysis(),
                ),
              ),
            TabBar(
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Papers'),
                Tab(text: 'Authors'),
                Tab(text: 'Journals'),
                Tab(text: 'Institutions'),
                Tab(text: 'Countries'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PapersTab(papers: provider.topPapersOpenAlex),
                  _RankedTab(
                    items: provider.topAuthorsOpenAlex,
                    onTap: (item) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AuthorDetailScreen(
                          author: item,
                          provider: provider,
                        ),
                      ),
                    ),
                  ),
                  _RankedTab(
                    items: provider.topJournalsOpenAlex,
                    onTap: (item) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalDetailScreen(
                          journal: item,
                          provider: provider,
                        ),
                      ),
                    ),
                  ),
                  _RankedTab(items: provider.topInstitutionsOpenAlex),
                  _RankedTab(items: provider.topCountriesOpenAlex),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PapersTab extends StatelessWidget {
  final List<Publication> papers;

  const _PapersTab({required this.papers});

  @override
  Widget build(BuildContext context) {
    if (papers.isEmpty) {
      return const Center(child: Text('No papers found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return RankedMetricTile(
          rank: index + 1,
          title: paper.title,
          subtitle: '${paper.year} · ${formatOpenAlexCount(paper.citations)} citations',
          metricValue: formatOpenAlexCount(paper.citations),
          metricLabel: 'citations',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(publication: paper),
            ),
          ),
        );
      },
    );
  }
}

class _RankedTab extends StatelessWidget {
  final List<OpenAlexRankedEntity> items;
  final ValueChanged<OpenAlexRankedEntity>? onTap;

  const _RankedTab({required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return RankedMetricTile(
          rank: index + 1,
          title: item.name,
          subtitle: '${formatOpenAlexCount(item.count)} publications',
          metricValue: formatOpenAlexCount(item.count),
          metricLabel: 'papers',
          onTap: onTap != null ? () => onTap!(item) : null,
        );
      },
    );
  }
}

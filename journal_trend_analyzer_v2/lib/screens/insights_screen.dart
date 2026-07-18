import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
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
import 'top_journals_screen.dart';
import 'top_papers_screen.dart';
import 'top_authors_screen.dart';

/// Insights — Top 20 papers, authors, journals, institutions, countries
class InsightsScreen extends StatelessWidget {
  final bool embedded;

  const InsightsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();

    if (provider.isDashboardLoading && !provider.hasData) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingInsights,
      );
    }

    if (!provider.hasData) {
      return Center(child: Text(s.loadDashboardFirst));
    }

    final body = DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.insights,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 22,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.refreshCurrentAnalysis(),
                  ),
                ],
              ),
            ),
          if (!embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                provider.isGlobalScope
                    ? s.globalResearchOpenAlex
                    : provider.currentTopic,
                style: Theme.of(context).textTheme.bodySmall,
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
            Theme(
              data: Theme.of(context).copyWith(
                tabBarTheme: const TabBarThemeData(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                ),
              ),
              child: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: s.papers),
                  Tab(text: s.authors),
                  Tab(text: s.journals),
                  Tab(text: s.institutions),
                  Tab(text: s.countries),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PapersTab(papers: provider.topPapersOpenAlex),
                  _AuthorsTab(
                    authors: provider.topAuthorsOpenAlex,
                    provider: provider,
                  ),
                  _JournalsTab(
                    journals: provider.topJournalsOpenAlex,
                    provider: provider,
                  ),
                  _RankedTab(items: provider.topInstitutionsOpenAlex),
                  _RankedTab(items: provider.topCountriesOpenAlex),
                ],
              ),
            ),
          ],
        ),
      );

    return embedded ? body : SafeArea(child: body);
  }
}

class _PapersTab extends StatelessWidget {
  final List<Publication> papers;

  const _PapersTab({required this.papers});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (papers.isEmpty) {
      return Center(child: Text(s.noPapersFound));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: papers.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TopPapersScreen(),
                  ),
                ),
                icon: const Icon(Icons.emoji_events_outlined, size: 18),
                label: Text(s.fullRankingView),
              ),
            ),
          );
        }
        final paper = papers[index - 1];
        return RankedMetricTile(
          rank: index,
          title: paper.title,
          subtitle:
              '${paper.year} · ${s.citationCountLabel(formatOpenAlexCount(paper.citations))}',
          metricValue: formatOpenAlexCount(paper.citations),
          metricLabel: s.citations.toLowerCase(),
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

class _AuthorsTab extends StatelessWidget {
  final List<OpenAlexRankedEntity> authors;
  final PublicationProvider provider;

  const _AuthorsTab({
    required this.authors,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (authors.isEmpty) {
      return Center(child: Text(s.noAuthorsFound));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: authors.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TopAuthorsScreen(),
                  ),
                ),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: Text(s.fullRankingView),
              ),
            ),
          );
        }
        final author = authors[index - 1];
        return RankedMetricTile(
          rank: index,
          title: author.name,
          subtitle:
              '${formatOpenAlexCount(author.count)} ${s.metricPublications}',
          metricValue: formatOpenAlexCount(author.count),
          metricLabel: s.metricPublications,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AuthorDetailScreen(
                author: author,
                provider: provider,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JournalsTab extends StatelessWidget {
  final List<OpenAlexRankedEntity> journals;
  final PublicationProvider provider;

  const _JournalsTab({
    required this.journals,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (journals.isEmpty) {
      return Center(child: Text(s.noJournalsFound));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: journals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TopJournalsScreen(),
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(s.fullRankingView),
              ),
            ),
          );
        }
        final journal = journals[index - 1];
        return RankedMetricTile(
          rank: index,
          title: journal.name,
          subtitle:
              '${formatOpenAlexCount(journal.count)} ${s.metricPublications}',
          metricValue: formatOpenAlexCount(journal.count),
          metricLabel: s.metricPublications,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalDetailScreen(
                journal: journal,
                provider: provider,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RankedTab extends StatelessWidget {
  final List<OpenAlexRankedEntity> items;
  final Function(OpenAlexRankedEntity)? onTap;

  const _RankedTab({required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (items.isEmpty) {
      return Center(child: Text(s.noDataAvailable));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return RankedMetricTile(
          rank: index + 1,
          title: item.name,
          subtitle:
              '${formatOpenAlexCount(item.count)} ${s.metricPublications}',
          metricValue: formatOpenAlexCount(item.count),
          metricLabel: s.papers.toLowerCase(),
          onTap: onTap != null ? () => onTap!(item) : null,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../utils/count_format.dart';
import '../widgets/ranked_list_widgets.dart';
import 'author_detail_screen.dart';
import 'detail_screen.dart';
import 'journal_detail_screen.dart';

class CitationLeadersScreen extends StatelessWidget {
  const CitationLeadersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(s.citationLeaders),
          bottom: TabBar(
            tabs: [
              Tab(text: s.papers),
              Tab(text: s.authors),
              Tab(text: s.journals),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PapersTab(),
            _AuthorsTab(),
            _JournalsTab(),
          ],
        ),
      ),
    );
  }
}

class _PapersTab extends StatelessWidget {
  const _PapersTab();

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final papers = context.watch<PublicationProvider>().topPapersOpenAlex;

    if (papers.isEmpty) {
      return Center(child: Text(s.noPapersFromOpenAlex));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        RankedListHeader(metricColumnLabel: s.citations),
        ...papers.asMap().entries.map((entry) {
          final paper = entry.value;
          final authors = paper.authors.take(2).join(', ');
          return RankedMetricTile(
            rank: entry.key + 1,
            title: paper.title,
            subtitle: '$authors · ${paper.year} · ${paper.journal}',
            metricValue: formatOpenAlexCount(paper.citations),
            metricLabel: s.citations.toLowerCase(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(publication: paper),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AuthorsTab extends StatelessWidget {
  const _AuthorsTab();

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final authors = provider.rankedAuthors;

    if (authors.isEmpty) {
      return Center(child: Text(s.noAuthorsFromOpenAlex));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        RankedListHeader(metricColumnLabel: s.publicationsLabel),
        ...authors.asMap().entries.map(
              (entry) => RankedMetricTile(
                rank: entry.key + 1,
                title: entry.value.name,
                metricValue: formatOpenAlexCount(entry.value.count),
                metricLabel: s.metricPublications,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthorDetailScreen(
                      author: entry.value,
                      provider: provider,
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _JournalsTab extends StatelessWidget {
  const _JournalsTab();

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final journals = provider.rankedJournals;

    if (journals.isEmpty) {
      return Center(child: Text(s.noJournalsFromOpenAlex));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        RankedListHeader(metricColumnLabel: s.publicationsLabel),
        ...journals.asMap().entries.map(
              (entry) => RankedMetricTile(
                rank: entry.key + 1,
                title: entry.value.name,
                subtitle: s.openAlexSource,
                metricValue: formatOpenAlexCount(entry.value.count),
                metricLabel: s.metricPublications,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalDetailScreen(
                      journal: entry.value,
                      provider: provider,
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

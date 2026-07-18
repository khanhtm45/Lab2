import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/top_research_journals_widgets.dart';
import 'journal_detail_screen.dart';

/// Top research journals ranked by publication volume.
class TopJournalsScreen extends StatefulWidget {
  const TopJournalsScreen({super.key});

  @override
  State<TopJournalsScreen> createState() => _TopJournalsScreenState();
}

class _TopJournalsScreenState extends State<TopJournalsScreen> {
  JournalSortOption _sort = JournalSortOption.mostPublications;

  String _topicLabel(PublicationProvider provider) {
    if (!provider.isGlobalScope) return provider.currentTopic;
    return 'Artificial Intelligence';
  }

  List<OpenAlexRankedEntity> _sortedJournals(List<OpenAlexRankedEntity> journals) {
    final copy = List<OpenAlexRankedEntity>.from(journals);
    switch (_sort) {
      case JournalSortOption.mostPublications:
        copy.sort((a, b) => b.count.compareTo(a.count));
      case JournalSortOption.alphabetical:
        copy.sort((a, b) => a.name.compareTo(b.name));
    }
    return copy;
  }

  void _openJournal(OpenAlexRankedEntity journal) {
    final provider = context.read<PublicationProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalDetailScreen(
          journal: journal,
          provider: provider,
        ),
      ),
    );
  }

  Future<void> _pickSort() async {
    final picked = await showJournalSortSheet(context, _sort);
    if (picked != null) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final journals = _sortedJournals(provider.rankedJournals);
    final topic = _topicLabel(provider);

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.topResearchJournals,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            color: AppColors.secondary,
            onPressed: _pickSort,
          ),
        ],
      ),
      body: provider.isLoading && journals.isEmpty
          ? AppLoadingView(
              fillScreen: false,
              expand: true,
              message: s.loadingJournalRankings,
            )
          : journals.isEmpty
              ? Center(
                  child: Text(
                    s.noJournalRankings,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  children: [
                    Text(
                      s.journalsMostPublications,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.topicLabel(topic),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    PremiumCard(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                      child: JournalsHorizontalBarChart(journals: journals),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      s.rankedJournals,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...journals.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final journal = entry.value;
                      return RankedJournalCard(
                        rank: rank,
                        journal: journal,
                        onViewPublications: () => _openJournal(journal),
                      );
                    }),
                  ],
                ),
    );
  }
}

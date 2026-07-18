import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/search_filter_sheets.dart';
import '../widgets/top_influential_papers_widgets.dart';
import 'detail_screen.dart';

/// Top influential papers ranked by citation count.
class TopPapersScreen extends StatelessWidget {
  const TopPapersScreen({super.key});

  String _topicLabel(PublicationProvider provider) {
    if (!provider.isGlobalScope) return provider.currentTopic;
    return 'Artificial Intelligence';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final papers = provider.topPapersOpenAlex;
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
          s.topInfluentialPapers,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: provider.searchFilters.isActive
                  ? AppColors.secondary
                  : AppColors.textSecondary,
            ),
            onPressed: () => showSearchFilterSheet(context),
          ),
        ],
      ),
      body: provider.isLoading && papers.isEmpty
          ? AppLoadingView(
              fillScreen: false,
              expand: true,
              message: s.loadingInfluentialPapers,
            )
          : papers.isEmpty
              ? Center(
                  child: Text(
                    s.noInfluentialPapers,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  children: [
                    Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.rankedByCitations,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    PodiumTopThree(
                      papers: papers,
                      onPaperTap: (paper) => _openDetail(context, paper),
                    ),
                    if (papers.length > 3) ...[
                      const SizedBox(height: 24),
                      Text(
                        s.moreRankedPapers,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...papers.skip(3).toList().asMap().entries.map((entry) {
                        final rank = entry.key + 4;
                        final paper = entry.value;
                        return InfluentialPaperRankCard(
                          rank: rank,
                          paper: paper,
                          onTap: () => _openDetail(context, paper),
                        );
                      }),
                    ],
                  ],
                ),
    );
  }

  void _openDetail(BuildContext context, paper) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(publication: paper),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/home_widgets.dart';
import '../widgets/search_filter_sheets.dart';
import '../widgets/search_results_view.dart';
import 'search_suggestions_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PublicationProvider>().loadRecentSearches();
    });
  }

  Future<void> _openSearch() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const SearchSuggestionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final s = context.strings;
    final inTopicScope = !provider.isGlobalScope;
    final loadingPapers = provider.isSearchLoading;

    if (inTopicScope) {
      return SafeArea(
        child: SearchResultsView(
          provider: provider,
          loadingPapers: loadingPapers,
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              s.journal,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              s.searchBrowseSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HomeSearchBar(
              filtersActive: provider.searchFilters.isActive,
              onTap: _openSearch,
              onFilterTap: () => showSearchFilterSheet(context),
            ),
          ),
          if (provider.recentSearches.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: s.recentSearches,
                trailing: TextButton(
                  onPressed: provider.clearRecentSearches,
                  child: Text(s.clear),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: provider.recentSearches.length,
                itemBuilder: (context, index) {
                  final entry = provider.recentSearches[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RecentSearchCard(
                      topic: entry.topic,
                      timeLabel: entry.relativeTimeLabelFor(s),
                      onTap: () =>
                          provider.searchPublications(entry.topic),
                      onDelete: () =>
                          provider.removeRecentSearch(entry.topic),
                    ),
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.searchResearchTopic,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.searchFromHomeHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

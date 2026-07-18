import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../providers/app_navigation_provider.dart';
import '../models/search_filters.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/publication_list_skeleton.dart';
import '../widgets/search_empty_state.dart';
import '../widgets/search_error_state.dart';
import '../widgets/error_banner.dart';
import '../widgets/publication_card.dart';
import '../widgets/search_filter_sheets.dart';

/// Publication search results — Journal tab after a topic search.
class SearchResultsView extends StatelessWidget {
  final PublicationProvider provider;
  final bool loadingPapers;

  const SearchResultsView({
    super.key,
    required this.provider,
    required this.loadingPapers,
  });

  static const _sortTabs = [
    SearchSortOption.relevance,
    SearchSortOption.newest,
    SearchSortOption.mostCited,
  ];

  Future<void> _changeSort(BuildContext context, SearchSortOption sort) async {
    if (provider.searchSort == sort) return;
    provider.updateSearchSort(sort);
    await provider.searchPublications(provider.currentTopic);
  }

  Future<void> _refresh(BuildContext context) async {
    await provider.searchPublications(provider.currentTopic);
  }

  void _goBack(BuildContext context) {
    context.read<PublicationProvider>().loadDefaultDashboard();
  }

  Future<void> _clearFilters(BuildContext context) async {
    final provider = context.read<PublicationProvider>();
    provider.updateSearchFilters(const SearchFilters());
    await provider.searchPublications(provider.currentTopic);
  }

  Future<void> _searchTopic(BuildContext context, String topic) async {
    await context.read<PublicationProvider>().searchPublications(topic);
  }

  void _goHome(BuildContext context) {
    context.read<AppNavigationProvider>().goToTab(0);
    context.read<PublicationProvider>().loadDefaultDashboard();
  }

  List<String> _activeFilterLabels(AppStrings s) {
    final filters = provider.searchFilters;
    final labels = <String>[];

    if (filters.yearFrom != null || filters.yearTo != null) {
      final from = filters.yearFrom ?? 2019;
      final to = filters.yearTo ?? DateTime.now().year;
      labels.add('$from–$to');
    }
    labels.add(provider.searchSort.labelFor(s));
    if (filters.openAccessOnly == true) {
      labels.add(s.openAccess);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final topic = provider.currentTopic;
    final total = provider.totalOnOpenAlex;
    final filterLabels = _activeFilterLabels(s);

    if (loadingPapers &&
        provider.publications.isEmpty &&
        provider.errorMessage == null) {
      return const SafeArea(
        child: PublicationListLoadingView(),
      );
    }

    if (!loadingPapers &&
        provider.publications.isEmpty &&
        provider.errorMessage == null) {
      return SafeArea(
        child: SearchResultsEmptyView(
          onBack: () => _goBack(context),
          onClearFilters: () => _clearFilters(context),
          onBackToSearch: () => _goBack(context),
          onTopicSelected: (topic) => _searchTopic(context, topic),
        ),
      );
    }

    if (!loadingPapers &&
        provider.publications.isEmpty &&
        provider.errorMessage != null) {
      return SafeArea(
        child: SearchResultsErrorView(
          onBack: () => _goBack(context),
          onRetry: () => _refresh(context),
          onBackToHome: () => _goHome(context),
          errorStatusCode: provider.errorStatusCode,
          errorMessage: provider.errorMessage,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _goBack(context),
              ),
              Expanded(
                child: Text(
                  topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: provider.searchFilters.isActive
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                ),
                onPressed: () => showSearchFilterSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.primary,
                onPressed: loadingPapers ? null : () => _refresh(context),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Text(
            total > 0
                ? s.publicationsFound(formatOpenAlexCount(total))
                : loadingPapers
                    ? s.searchingPublications
                    : s.noPublicationsFound,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (filterLabels.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filterLabels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _ActiveFilterChip(label: filterLabels[index]);
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SortTabBar(
            selected: provider.searchSort,
            onSelected: (sort) => _changeSort(context, sort),
          ),
        ),
        const SizedBox(height: 8),
        if (provider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: ErrorBanner(
              message: provider.errorMessage!,
              onRetry: () => _refresh(context),
            ),
          ),
        Expanded(
          child: _ResultsList(
            provider: provider,
            loadingPapers: loadingPapers,
          ),
        ),
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;

  const _ActiveFilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}

class _SortTabBar extends StatelessWidget {
  final SearchSortOption selected;
  final ValueChanged<SearchSortOption> onSelected;

  const _SortTabBar({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: SearchResultsView._sortTabs.map((option) {
          final active = selected == option;
          return Expanded(
            child: Material(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              elevation: active ? 0 : 0,
              shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: active ? AppDimens.cardShadow : null,
                  ),
                  child: Text(
                    option.labelFor(s),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? AppColors.secondary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final PublicationProvider provider;
  final bool loadingPapers;

  const _ResultsList({
    required this.provider,
    required this.loadingPapers,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (loadingPapers && provider.publications.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!loadingPapers && provider.publications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            s.noPublicationsMatch,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: provider.publications.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.publications.length) {
          return _CompactLoadMoreFooter(
            isLoading: provider.isLoadingMorePublications,
            hasMore: provider.searchHasMore,
            onLoadMore: provider.loadMoreSearchPublications,
          );
        }
        return PublicationCard(publication: provider.publications[index]);
      },
    );
  }
}

class _CompactLoadMoreFooter extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _CompactLoadMoreFooter({
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (!hasMore && !isLoading) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            : TextButton(
                onPressed: onLoadMore,
                child: Text(
                  s.loadMorePublications,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
      ),
    );
  }
}

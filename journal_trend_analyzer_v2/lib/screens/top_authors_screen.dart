import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/ranked_author_entry.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/top_contributing_authors_widgets.dart';
import 'author_detail_screen.dart';

/// Top contributing authors ranked by publication volume.
class TopAuthorsScreen extends StatefulWidget {
  const TopAuthorsScreen({super.key});

  @override
  State<TopAuthorsScreen> createState() => _TopAuthorsScreenState();
}

class _TopAuthorsScreenState extends State<TopAuthorsScreen> {
  List<RankedAuthorEntry> _authors = [];
  AuthorSortOption _sort = AuthorSortOption.mostPublications;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = context.read<PublicationProvider>();
      final authors = await provider.loadRankedAuthors();
      if (!mounted) return;
      setState(() {
        _authors = authors;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _topicLabel(PublicationProvider provider) {
    if (!provider.isGlobalScope) return provider.currentTopic;
    return 'Artificial Intelligence';
  }

  List<RankedAuthorEntry> _sortedAuthors(List<RankedAuthorEntry> authors) {
    final copy = List<RankedAuthorEntry>.from(authors);
    switch (_sort) {
      case AuthorSortOption.mostPublications:
        copy.sort((a, b) => b.publicationCount.compareTo(a.publicationCount));
      case AuthorSortOption.mostCitations:
        copy.sort((a, b) => b.citationCount.compareTo(a.citationCount));
      case AuthorSortOption.alphabetical:
        copy.sort((a, b) => a.name.compareTo(b.name));
    }
    return copy;
  }

  void _openAuthor(OpenAlexRankedEntity author) {
    final provider = context.read<PublicationProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthorDetailScreen(
          author: author,
          provider: provider,
        ),
      ),
    );
  }

  Future<void> _pickSort() async {
    final picked = await showAuthorSortSheet(context, _sort);
    if (picked != null) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final authors = _sortedAuthors(_authors);
    final topic = _topicLabel(provider);
    final topThree = authors.take(3).toList();
    final rest = authors.length > 3 ? authors.sublist(3) : <RankedAuthorEntry>[];

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.topAuthors,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            color: AppColors.secondary,
            onPressed: _pickSort,
          ),
        ],
      ),
      body: _buildBody(s, provider, topic, topThree, rest),
    );
  }

  Widget _buildBody(
    AppStrings s,
    PublicationProvider provider,
    String topic,
    List<RankedAuthorEntry> topThree,
    List<RankedAuthorEntry> rest,
  ) {
    if (_loading && _authors.isEmpty) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingAuthorRankings,
      );
    }

    if (_error != null && _authors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadAuthors,
                child: Text(s.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_authors.isEmpty) {
      return Center(
        child: Text(
          s.noAuthorRankings,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAuthors,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            s.mostActiveResearchers,
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
          const SizedBox(height: 4),
          Text(
            s.rankedByPublications,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          if (topThree.isNotEmpty)
            FeaturedTopAuthorsCard(
              authors: topThree,
              onAuthorTap: (author) => _openAuthor(author.entity),
            ),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              s.moreRankedAuthors,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...rest.asMap().entries.map((entry) {
              final rank = entry.key + 4;
              final author = entry.value;
              return AuthorRankListCard(
                rank: rank,
                author: author,
                onTap: () => _openAuthor(author.entity),
              );
            }),
          ],
        ],
      ),
    );
  }
}

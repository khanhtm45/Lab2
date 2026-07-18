import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../models/author_profile.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/openalex_works_result.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/author_detail_widgets.dart';
import '../widgets/entity_detail_widgets.dart';
import '../widgets/load_more_footer.dart';
import '../widgets/publication_card.dart';
import 'detail_screen.dart';

/// Full paginated publication list for an author.
class AuthorPublicationsScreen extends StatefulWidget {
  final OpenAlexRankedEntity author;
  final PublicationProvider provider;

  const AuthorPublicationsScreen({
    super.key,
    required this.author,
    required this.provider,
  });

  @override
  State<AuthorPublicationsScreen> createState() =>
      _AuthorPublicationsScreenState();
}

class _AuthorPublicationsScreenState extends State<AuthorPublicationsScreen> {
  List<Publication> _papers = [];
  int _totalCount = 0;
  int _page = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _papers = [];
      _page = 0;
    });

    try {
      final resolved = await widget.provider.resolveAuthor(widget.author);
      final result = await widget.provider.loadWorksByAuthorPage(resolved, 1);
      if (!mounted) return;
      setState(() {
        _papers = result.publications;
        _totalCount = result.totalOnOpenAlex;
        _page = 1;
        _hasMore = result.hasMore(_papers.length);
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

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;

    setState(() => _loadingMore = true);

    try {
      final resolved = await widget.provider.resolveAuthor(widget.author);
      final result = await widget.provider.loadWorksByAuthorPage(
        resolved,
        _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _papers = [..._papers, ...result.publications];
        _page += 1;
        _hasMore = result.hasMore(_papers.length);
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount =
        _totalCount > 0 ? _totalCount : widget.author.count;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.author.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(totalCount),
    );
  }

  Widget _buildBody(int totalCount) {
    final s = context.strings;
    if (_loading) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingPublications,
      );
    }

    if (_error != null && _papers.isEmpty) {
      return DetailRetryState(message: _error!, onRetry: _loadInitial);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text(
          s.publicationsSortedByCitations(formatOpenAlexCount(totalCount)),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (_papers.isEmpty)
          Text(
            _emptyMessage(s),
            style: const TextStyle(color: AppColors.textSecondary),
          )
        else ...[
          ..._papers.map((paper) => PublicationCard(publication: paper)),
          LoadMoreFooter(
            loadedCount: _papers.length,
            totalCount: totalCount,
            isLoading: _loadingMore,
            hasMore: _hasMore,
            onLoadMore: _loadMore,
          ),
        ],
      ],
    );
  }

  String _emptyMessage(AppStrings s) {
    if (widget.provider.isGlobalScope) {
      return s.noPapersOnOpenAlex;
    }
    return s.noPapersByAuthorInTopic(widget.provider.currentTopic);
  }
}

class AuthorDetailScreen extends StatefulWidget {
  final OpenAlexRankedEntity author;
  final PublicationProvider provider;

  const AuthorDetailScreen({
    super.key,
    required this.author,
    required this.provider,
  });

  @override
  State<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends State<AuthorDetailScreen> {
  List<Publication> _papers = [];
  Map<int, int> _trend = {};
  AuthorProfile? _profile;
  OpenAlexRankedEntity? _author;
  int _totalCount = 0;
  bool _bookmarked = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _papers = [];
    });

    try {
      final resolved = await widget.provider.resolveAuthor(widget.author);
      if (!mounted) return;

      final results = await Future.wait([
        widget.provider.loadWorksByAuthorPage(resolved, 1),
        widget.provider.loadAuthorTrend(resolved),
        widget.provider.loadAuthorProfile(resolved),
      ]);

      if (!mounted) return;

      final papersResult = results[0] as OpenAlexWorksResult;
      final trend = results[1] as Map<int, int>;
      final profile = results[2] as AuthorProfile;

      setState(() {
        _author = resolved;
        _papers = papersResult.publications;
        _totalCount = papersResult.totalOnOpenAlex > 0
            ? papersResult.totalOnOpenAlex
            : resolved.count;
        _trend = trend;
        _profile = profile;
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

  int get _activeYears =>
      _trend.entries.where((entry) => entry.value > 0).length;

  int get _publicationCount {
    if (_totalCount > 0) return _totalCount;
    if (_profile != null && _profile!.publicationCount > 0) {
      return _profile!.publicationCount;
    }
    return (_author ?? widget.author).count;
  }

  int get _citationCount => _profile?.citationCount ?? 0;

  double get _averageCitations {
    final pubs = _publicationCount;
    if (pubs <= 0) return 0;
    return _citationCount / pubs;
  }

  void _openPaper(Publication paper) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(publication: paper)),
    );
  }

  void _openAllPublications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthorPublicationsScreen(
          author: _author ?? widget.author,
          provider: widget.provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final profile = _profile;
    final recentPapers = _papers.take(3).toList();

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.authorProfile,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _bookmarked ? AppColors.secondary : null,
            ),
            onPressed: () {
              setState(() => _bookmarked = !_bookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _bookmarked ? s.savedToBookmarks : s.removedFromBookmarks,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(s, profile, recentPapers)),
          if (!_loading && _error == null)
            AuthorDetailBottomCta(onPressed: _openAllPublications),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppStrings s,
    AuthorProfile? profile,
    List<Publication> recentPapers,
  ) {
    if (_loading) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingAuthorProfile,
      );
    }

    if (_error != null && profile == null) {
      return DetailRetryState(message: _error!, onRetry: _loadInitial);
    }

    if (profile == null) {
      return Center(
        child: Text(
          s.unableToLoadAuthorProfile,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          AuthorProfileHeaderCard(profile: profile),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              AuthorStatTile(
                value: formatOpenAlexCount(_publicationCount),
                label: s.publicationsLabel,
              ),
              AuthorStatTile(
                value: formatOpenAlexCount(_citationCount),
                label: s.citations,
              ),
              AuthorStatTile(
                value: _averageCitations.toStringAsFixed(1),
                label: s.averageCitations,
              ),
              AuthorStatTile(
                value: '$_activeYears',
                label: s.activeYears,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthorDetailSectionHeader(title: s.recentPublications),
          const SizedBox(height: 12),
          if (recentPapers.isEmpty)
            Text(
              _emptyPapersMessage(s),
              style: const TextStyle(color: AppColors.textSecondary),
            )
          else
            ...recentPapers.asMap().entries.map((entry) {
              return AuthorRecentPublicationCard(
                index: entry.key + 1,
                paper: entry.value,
                onTap: () => _openPaper(entry.value),
              );
            }),
        ],
      ),
    );
  }

  String _emptyPapersMessage(AppStrings s) {
    if (widget.provider.isGlobalScope) {
      return s.noPapersOnOpenAlex;
    }
    return s.noPapersByAuthorInTopic(widget.provider.currentTopic);
  }
}

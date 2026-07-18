import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../models/journal_source_profile.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/openalex_works_result.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/compact_trend_chart.dart';
import '../widgets/entity_detail_widgets.dart';
import '../widgets/journal_detail_widgets.dart';
import '../widgets/load_more_footer.dart';
import '../widgets/publication_card.dart';
import 'detail_screen.dart';

/// Full paginated publication list for a journal.
class JournalPublicationsScreen extends StatefulWidget {
  final OpenAlexRankedEntity journal;
  final PublicationProvider provider;

  const JournalPublicationsScreen({
    super.key,
    required this.journal,
    required this.provider,
  });

  @override
  State<JournalPublicationsScreen> createState() =>
      _JournalPublicationsScreenState();
}

class _JournalPublicationsScreenState extends State<JournalPublicationsScreen> {
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
      final result = await widget.provider.loadWorksByJournalPage(
        widget.journal,
        1,
      );
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
      final result = await widget.provider.loadWorksByJournalPage(
        widget.journal,
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
        _totalCount > 0 ? _totalCount : widget.journal.count;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.journal.name,
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
            s.noPapersOnOpenAlex,
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
}

class JournalDetailScreen extends StatefulWidget {
  final OpenAlexRankedEntity journal;
  final PublicationProvider provider;

  const JournalDetailScreen({
    super.key,
    required this.journal,
    required this.provider,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  static const _chartYearFrom = 2019;
  static const _chartYearTo = 2025;

  List<Publication> _papers = [];
  Map<int, int> _trend = {};
  JournalSourceProfile _profile = JournalSourceProfile.empty;
  int _totalCount = 0;
  double _avgCitations = 0;
  double? _oaPercent;
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
    });

    try {
      final results = await Future.wait([
        widget.provider.loadWorksByJournalPage(widget.journal, 1),
        widget.provider.loadJournalTrend(widget.journal),
        widget.provider.loadJournalSourceProfile(widget.journal),
        widget.provider.loadJournalAverageCitations(widget.journal),
        widget.provider.loadJournalOpenAccessPercent(widget.journal),
      ]);

      if (!mounted) return;

      final papersResult = results[0] as OpenAlexWorksResult;
      final trend = results[1] as Map<int, int>;
      final profile = results[2] as JournalSourceProfile;

      setState(() {
        _papers = papersResult.publications;
        _totalCount = papersResult.totalOnOpenAlex;
        _trend = trend;
        _profile = profile.name.isEmpty
            ? JournalSourceProfile(
                name: widget.journal.name,
                publisher: profile.publisher,
                sourceType: profile.sourceType,
                issn: profile.issn,
              )
            : profile;
        _avgCitations = results[3] as double;
        _oaPercent = results[4] as double?;
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

  Map<int, int> get _chartTrend {
    return Map.fromEntries(
      _trend.entries.where(
        (e) => e.key >= _chartYearFrom && e.key <= _chartYearTo,
      ),
    );
  }

  String _peakYearLabel(AppStrings s) {
    final trend = _chartTrend;
    if (trend.isEmpty) return s.na;
    final peak = trend.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '${peak.key}';
  }

  String _oaLabel(AppStrings s) {
    if (_oaPercent == null) return s.na;
    return '${_oaPercent!.round()}%';
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
        builder: (_) => JournalPublicationsScreen(
          journal: widget.journal,
          provider: widget.provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final journalName = _profile.name.isNotEmpty
        ? _profile.name
        : widget.journal.name;
    final totalCount =
        _totalCount > 0 ? _totalCount : widget.journal.count;
    final topPapers = _papers.take(2).toList();

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.journalDetail,
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
          Expanded(child: _buildBody(s, totalCount, topPapers)),
          if (!_loading && _error == null)
            JournalDetailBottomCta(
              journalName: journalName,
              onPressed: _openAllPublications,
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppStrings s,
    int totalCount,
    List<Publication> topPapers,
  ) {
    if (_loading) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingJournalData,
      );
    }

    if (_error != null && _papers.isEmpty) {
      return DetailRetryState(message: _error!, onRetry: _loadInitial);
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          JournalHeaderCard(profile: _profile),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              JournalStatTile(
                value: formatOpenAlexCount(totalCount),
                label: s.publicationsLabel,
              ),
              JournalStatTile(
                value: _avgCitations.toStringAsFixed(1),
                label: s.averageCitations,
              ),
              JournalStatTile(
                value: _peakYearLabel(s),
                label: s.mostActiveYear,
              ),
              JournalStatTile(
                value: _oaLabel(s),
                label: s.openAccess,
              ),
            ],
          ),
          const SizedBox(height: 24),
          JournalDetailSectionHeader(
            title: s.publicationActivity,
            subtitle: '2019–2025',
          ),
          const SizedBox(height: 12),
          PremiumCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
            child: CompactTrendChart(yearlyData: _chartTrend),
          ),
          const SizedBox(height: 24),
          JournalDetailSectionHeader(
            title: s.topPapersFromJournal,
          ),
          const SizedBox(height: 12),
          if (topPapers.isEmpty)
            Text(
              s.noPapersOnOpenAlex,
              style: const TextStyle(color: AppColors.textSecondary),
            )
          else
            ...topPapers.map(
              (paper) => JournalTopPaperCard(
                paper: paper,
                onTap: () => _openPaper(paper),
              ),
            ),
        ],
      ),
    );
  }
}

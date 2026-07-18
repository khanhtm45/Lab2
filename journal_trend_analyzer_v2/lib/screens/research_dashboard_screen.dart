import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../models/publication.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../utils/research_summary_share.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/compact_trend_chart.dart';
import '../widgets/year_activity_sheet.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/error_banner.dart';
import 'growth_screen.dart';
import 'home_screen.dart';
import 'top_journals_screen.dart';
import 'top_papers_screen.dart';
import 'top_authors_screen.dart';
import 'keywords_topics_screen.dart';

/// Research dashboard — analytics overview for a selected topic.
class ResearchDashboardScreen extends StatefulWidget {
  const ResearchDashboardScreen({super.key});

  @override
  State<ResearchDashboardScreen> createState() =>
      _ResearchDashboardScreenState();
}

class _ResearchDashboardScreenState extends State<ResearchDashboardScreen> {
  int _yearFrom = 2019;
  int _yearTo = 2025;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PublicationProvider>();
      if (provider.isGlobalScope) {
        await provider.searchPublications('Artificial Intelligence');
      }
    });
  }

  List<String> _topicOptions(PublicationProvider provider) {
    final topics = <String>{'Artificial Intelligence'};
    if (!provider.isGlobalScope) topics.add(provider.currentTopic);
    topics.addAll(provider.recentSearches.map((e) => e.topic));
    topics.addAll(HomeScreen.popularTopics);
    return topics.toList();
  }

  String _selectedTopic(PublicationProvider provider) {
    if (!provider.isGlobalScope) return provider.currentTopic;
    return 'Artificial Intelligence';
  }

  Map<int, int> _filterTrend(Map<int, int> source) {
    return Map.fromEntries(
      source.entries.where(
        (e) => e.key >= _yearFrom && e.key <= _yearTo,
      ),
    );
  }

  String _peakYearLabel(Map<int, int> trend) {
    if (trend.isEmpty) return 'N/A';
    final peak = trend.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '${peak.key}';
  }

  String _growthLabel(PublicationProvider provider) {
    final percent = provider.landscapePulse.yoyGrowthPercent;
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }

  Future<void> _onTopicChanged(String? topic) async {
    if (topic == null || topic.isEmpty) return;
    await context.read<PublicationProvider>().searchPublications(topic);
  }

  Future<void> _shareSummary(PublicationProvider provider) async {
    final text = buildResearchSummaryText(
      provider: provider,
      strings: context.strings,
      yearFrom: _yearFrom,
      yearTo: _yearTo,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.strings.summaryCopied)),
    );
  }

  Future<void> _pickYearRange() async {
    final s = context.strings;
    final palette = context.palette;
    final years = List.generate(
      DateTime.now().year - 1999,
      (i) => 2000 + i,
    );

    var from = _yearFrom;
    var to = _yearTo;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.yearRange,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: palette.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: from,
                          decoration: InputDecoration(labelText: s.fromYear),
                          items: years
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModal(() => from = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: to,
                          decoration: InputDecoration(labelText: s.toYear),
                          items: years
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModal(() => to = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _yearFrom = from;
                          _yearTo = to;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(s.apply),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final s = context.strings;
    final topics = _topicOptions(provider);
    final selectedTopic = topics.contains(_selectedTopic(provider))
        ? _selectedTopic(provider)
        : topics.first;
    final trend = _filterTrend(provider.yearlyTrendFromOpenAlex);
    final topPaper = provider.topPapersOpenAlex.isEmpty
        ? null
        : provider.topPapersOpenAlex.first;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(
              topics: topics,
              selectedTopic: selectedTopic,
              yearLabel: s.yearRangeLabel(_yearFrom, _yearTo),
              onTopicChanged: _onTopicChanged,
              onYearFilter: _pickYearRange,
              onShare: () => _shareSummary(provider),
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: _buildBody(provider, trend, topPaper),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    PublicationProvider provider,
    Map<int, int> trend,
    Publication? topPaper,
  ) {
    final s = context.strings;
    final palette = context.palette;

    if (provider.isDashboardLoading && !provider.hasData) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingResearchData,
      );
    }

    if (provider.errorMessage != null && !provider.hasData) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: ErrorBanner(
          message: provider.errorMessage!,
          onRetry: () => provider.loadDefaultDashboard(),
        ),
      );
    }

    if (!provider.hasData) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingResearchData,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.isGlobalScope
          ? provider.loadDefaultDashboard()
          : provider.searchPublications(provider.currentTopic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            s.dashboardInsightsSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.12,
            children: [
              DashboardCard(
                title: s.totalPublications,
                value: formatOpenAlexCount(provider.totalOnOpenAlex),
                icon: Icons.article_outlined,
                accentColor: palette.primary,
              ),
              DashboardCard(
                title: s.averageCitations,
                value: provider.averageCitationOpenAlex.toStringAsFixed(1),
                icon: Icons.emoji_events_outlined,
                accentColor: palette.citation,
              ),
              DashboardCard(
                title: s.mostActiveYear,
                value: _peakYearLabel(trend),
                icon: Icons.trending_up_rounded,
                accentColor: palette.accent,
              ),
              DashboardCard(
                title: s.growthRate,
                value: _growthLabel(provider),
                icon: Icons.north_east_rounded,
                accentColor: palette.accent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _LeadersCard(
            provider: provider,
            topPaperTitle: topPaper?.title,
            topPaperCitations: topPaper?.citations,
          ),
          const SizedBox(height: 20),
          PremiumCard(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.publicationTrend,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.yearRangeLabel(_yearFrom, _yearTo),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                CompactTrendChart(
                  yearlyData: trend,
                  onYearTapped: (year) => showYearActivitySheet(
                    context,
                    year,
                    publicationCountHint: trend[year],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublicationTrendsScreen(),
                  ),
                );
              },
              child: Text(
                s.viewFullTrendAnalysis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final List<String> topics;
  final String selectedTopic;
  final String yearLabel;
  final ValueChanged<String?> onTopicChanged;
  final VoidCallback onYearFilter;
  final VoidCallback onShare;
  final VoidCallback onBack;

  const _DashboardHeader({
    required this.topics,
    required this.selectedTopic,
    required this.yearLabel,
    required this.onTopicChanged,
    required this.onYearFilter,
    required this.onShare,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  s.researchDashboard,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: palette.primary,
                  ),
                ),
              ),
              IconButton(
                tooltip: s.shareSummary,
                onPressed: onShare,
                icon: Icon(Icons.ios_share_rounded, color: palette.secondary),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                      boxShadow: AppDimens.cardShadow,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTopic,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: palette.secondary,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                        items: topics
                            .map(
                              (topic) => DropdownMenuItem(
                                value: topic,
                                child: Text(
                                  topic,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: onTopicChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onYearFilter,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.border),
                        boxShadow: AppDimens.cardShadow,
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 22,
                        color: palette.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              yearLabel,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadersCard extends StatelessWidget {
  final PublicationProvider provider;
  final String? topPaperTitle;
  final int? topPaperCitations;

  const _LeadersCard({
    required this.provider,
    this.topPaperTitle,
    this.topPaperCitations,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.keyResearchLeaders,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
          const SizedBox(height: 16),
          _LeaderRow(
            icon: Icons.menu_book_rounded,
            iconColor: palette.primary,
            label: s.topJournal,
            value: provider.topJournalLabel,
            onTap: provider.topJournalsOpenAlex.isEmpty
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TopJournalsScreen(),
                      ),
                    ),
          ),
          const SizedBox(height: 14),
          _LeaderRow(
            icon: Icons.person_rounded,
            iconColor: palette.secondary,
            label: s.topAuthor,
            value: provider.topAuthorLabel,
            onTap: provider.topAuthorsOpenAlex.isEmpty
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TopAuthorsScreen(),
                      ),
                    ),
          ),
          const SizedBox(height: 14),
          _LeaderRow(
            icon: Icons.emoji_events_outlined,
            iconColor: palette.citation,
            label: s.mostInfluentialPaper,
            value: topPaperTitle ?? provider.topPaperLabel,
            subtitle: topPaperCitations != null
                ? s.citationCountLabel(
                    formatOpenAlexCount(topPaperCitations!),
                  )
                : null,
            onTap: provider.topPapersOpenAlex.isEmpty
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TopPapersScreen(),
                      ),
                    ),
          ),
          const SizedBox(height: 14),
          _LeaderRow(
            icon: Icons.hub_outlined,
            iconColor: palette.accent,
            label: s.keywordsAndTopics,
            value: provider.topTopicLabel,
            onTap: provider.topResearchAreasOpenAlex.isEmpty
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KeywordsTopicsScreen(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;

  const _LeaderRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.citationAmber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/keywords_topics_widgets.dart';
import '../widgets/search_filter_sheets.dart';
import 'domain_detail_screen.dart';

/// Research keywords cloud and ranked topics for the active search scope.
class KeywordsTopicsScreen extends StatefulWidget {
  final String? initialQuery;
  final bool showKeywordAnalysis;
  
  const KeywordsTopicsScreen({
    super.key,
    this.initialQuery,
    this.showKeywordAnalysis = false,
  });

  @override
  State<KeywordsTopicsScreen> createState() => _KeywordsTopicsScreenState();
}

class _KeywordsTopicsScreenState extends State<KeywordsTopicsScreen> {
  List<OpenAlexRankedEntity> _keywords = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = context.read<PublicationProvider>();
      if (!provider.hasData && provider.isGlobalScope) {
        await provider.loadDefaultDashboard();
      } else if (!provider.hasData) {
        await provider.searchPublications(provider.currentTopic);
      }

      final keywords = await provider.loadTopKeywords(limit: 10);
      if (!mounted) return;
      setState(() {
        _keywords = keywords;
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

  List<OpenAlexRankedEntity> _sortedTopics(List<OpenAlexRankedEntity> topics) {
    final copy = List<OpenAlexRankedEntity>.from(topics);
    copy.sort((a, b) => b.count.compareTo(a.count));
    return copy;
  }

  void _openTopic(OpenAlexRankedEntity topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DomainDetailScreen(domain: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final topics = _sortedTopics(provider.topResearchAreasOpenAlex);
    final topicLabel = _topicLabel(provider);
    final maxTopicCount =
        topics.isNotEmpty ? topics.first.count.toDouble() : 1.0;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.keywordsAndTopics,
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
            onPressed: () async {
              await showSearchFilterSheet(context);
              if (mounted) _loadData();
            },
          ),
        ],
      ),
      body: _buildBody(s, provider, topicLabel, topics, maxTopicCount),
    );
  }

  Widget _buildBody(
    AppStrings s,
    PublicationProvider provider,
    String topicLabel,
    List<OpenAlexRankedEntity> topics,
    double maxTopicCount,
  ) {
    if (_loading && _keywords.isEmpty && topics.isEmpty) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingKeywordsTopics,
      );
    }

    if (_error != null && _keywords.isEmpty && topics.isEmpty) {
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
                onPressed: _loadData,
                child: Text(s.retry),
              ),
            ],
          ),
        ),
      );
    }

    final cloudKeywords = _keywords.isNotEmpty
        ? _keywords
        : topics.take(10).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            topicLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.mostFrequentThemes,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            s.keywordCloud,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          KeywordCloudCard(keywords: cloudKeywords),
          const SizedBox(height: 24),
          Text(
            s.topTopics,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (topics.isEmpty)
            Text(
              s.noTopicRankings,
              style: const TextStyle(color: AppColors.textSecondary),
            )
          else
            ...topics.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final topic = entry.value;
              return TopicRankListCard(
                rank: rank,
                topic: topic,
                progress: topic.count / maxTopicCount,
                onTap: () => _openTopic(topic),
              );
            }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../models/search_filters.dart';
import '../providers/publication_provider.dart';
import '../screens/home_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/topic_comparison_result_card.dart';

/// Full-screen topic A vs B comparison with custom topic pickers.
class TopicComparisonScreen extends StatefulWidget {
  final String? initialTopicA;
  final String? initialTopicB;

  const TopicComparisonScreen({
    super.key,
    this.initialTopicA,
    this.initialTopicB,
  });

  @override
  State<TopicComparisonScreen> createState() => _TopicComparisonScreenState();
}

class _TopicComparisonScreenState extends State<TopicComparisonScreen> {
  static const _defaultTopicA = 'Artificial Intelligence';
  static const _defaultTopicB = 'Blockchain';

  late String _topicA;
  late String _topicB;
  TopicComparisonResult? _comparison;
  bool _comparing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _topicA = widget.initialTopicA ?? _defaultTopicA;
    _topicB = widget.initialTopicB ?? _defaultTopicB;
  }

  List<String> _topicOptions(PublicationProvider provider) {
    final topics = <String>{
      _defaultTopicA,
      _defaultTopicB,
      'Cybersecurity',
      'Internet of Things',
      'Data Science',
      'Machine Learning',
      ...HomeScreen.popularTopics,
      ...provider.recentSearches.map((e) => e.topic),
      ...provider.bookmarkedTopics,
    };
    return topics.toList();
  }

  Future<void> _compare() async {
    if (_topicA.trim().toLowerCase() == _topicB.trim().toLowerCase()) {
      setState(() => _error = context.strings.compareSameTopicError);
      return;
    }

    setState(() {
      _comparing = true;
      _error = null;
      _comparison = null;
    });

    try {
      final result = await context
          .read<PublicationProvider>()
          .openAlexService
          .compareTopics(_topicA, _topicB);
      if (!mounted) return;
      setState(() => _comparison = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _comparing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final s = context.strings;
    final palette = context.palette;
    final topics = _topicOptions(provider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(s.topicComparison),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            s.compareTopicsSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          _TopicDropdown(
            label: s.topicA,
            value: topics.contains(_topicA) ? _topicA : topics.first,
            topics: topics,
            accentColor: palette.primary,
            onChanged: (v) {
              if (v != null) setState(() => _topicA = v);
            },
          ),
          const SizedBox(height: 12),
          _TopicDropdown(
            label: s.topicB,
            value: topics.contains(_topicB) ? _topicB : topics.last,
            topics: topics,
            accentColor: palette.secondary,
            onChanged: (v) {
              if (v != null) setState(() => _topicB = v);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _comparing ? null : _compare,
              icon: const Icon(Icons.compare_arrows_rounded, size: 20),
              label: Text(s.compareTopics),
            ),
          ),
          if (_comparing)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: AppLoadingView(
                fillScreen: false,
                size: 120,
                message: s.comparingTopics,
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: TextStyle(color: palette.error, fontSize: 12),
              ),
            ),
          if (_comparison != null) ...[
            const SizedBox(height: 24),
            PremiumCard(
              padding: const EdgeInsets.all(16),
              child: TopicComparisonResultCard(result: _comparison!),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> topics;
  final Color accentColor;
  final ValueChanged<String?> onChanged;

  const _TopicDropdown({
    required this.label,
    required this.value,
    required this.topics,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor),
              items: topics
                  .map(
                    (topic) => DropdownMenuItem(
                      value: topic,
                      child: Text(topic, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

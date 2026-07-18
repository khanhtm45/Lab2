import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';

class SearchSuggestionsScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchSuggestionsScreen({super.key, this.initialQuery});

  @override
  State<SearchSuggestionsScreen> createState() => _SearchSuggestionsScreenState();
}

class _SearchSuggestionsScreenState extends State<SearchSuggestionsScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final TabController _tabController;
  Timer? _debounce;

  static const _catalog = [
    'Artificial Intelligence',
    'Artificial Intelligence Ethics',
    'Artificial Intelligence in Healthcare',
    'Artificial Intelligence and Education',
    'Explainable Artificial Intelligence',
    'Machine Learning',
    'Deep Learning',
    'Neural Networks',
    'Data Science',
    'Cybersecurity',
    'Blockchain Technology',
    'Internet of Things',
    'Software Engineering',
    'Generative AI',
    'Large Language Models',
    'Green Computing',
    'Quantum Computing',
    'Computer Vision',
    'Natural Language Processing',
    'Cloud Computing',
  ];

  static const _trending = [
    'Generative AI',
    'Large Language Models',
    'ChatGPT',
    'Green Computing',
    'Quantum Computing',
    'Cybersecurity',
  ];

  static const _popular = [
    'Machine Learning',
    'Deep Learning',
    'Artificial Intelligence',
    'Data Science',
    'Neural Networks',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  List<String> get _matches {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _catalog
        .where((topic) => topic.toLowerCase().contains(query))
        .take(10)
        .toList();
  }

  Future<void> _submit(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return;
    if (!mounted) return;
    Navigator.pop(context);
    context.read<AppNavigationProvider>().goToTab(1);
    await context.read<PublicationProvider>().searchPublications(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final palette = context.palette;
    final matches = _matches;
    final recentSearches = provider.recentSearches.take(5).toList();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _submit,
            onChanged: _onSearchChanged,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: palette.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search papers, topics, authors...',
              hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.7)),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: palette.textSecondary, size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: palette.textSecondary, size: 20),
                      onPressed: () {
                        _controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: provider.searchFilters.isActive ? palette.secondary : palette.textSecondary,
            ),
            onPressed: () {
              // Filter functionality - show simple dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Filters coming soon!'),
                  backgroundColor: palette.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: palette.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: palette.primary,
              unselectedLabelColor: palette.textSecondary,
              indicatorColor: palette.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              onTap: (index) {
                setState(() {});
              },
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Papers'),
                Tab(text: 'Topics'),
                Tab(text: 'Authors'),
                Tab(text: 'Journals'),
              ],
            ),
          ),
        ),
      ),
      body: _controller.text.isEmpty
          ? _buildEmptyState(context, provider, palette, recentSearches)
          : _buildSearchResults(context, matches, palette),
    );
  }

  Widget _buildEmptyState(BuildContext context, PublicationProvider provider, AppPalette palette, List recentSearches) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Recent Searches
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.history, size: 18, color: palette.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: provider.clearRecentSearches,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentSearches.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _submit(entry.topic),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.history, size: 16, color: palette.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.topic,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.removeRecentSearch(entry.topic),
                        icon: Icon(Icons.close, size: 18, color: palette.textTertiary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        
        // Popular Searches
        Row(
          children: [
            Icon(Icons.whatshot, size: 18, color: palette.warning),
            const SizedBox(width: 8),
            Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popular.map((topic) {
            return InkWell(
              onTap: () => _submit(topic),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 14, color: palette.warning),
                    const SizedBox(width: 6),
                    Text(
                      topic,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Trending Topics
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: palette.secondary),
            const SizedBox(width: 8),
            Text(
              'Trending Research Topics',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._trending.map((topic) {
          final index = _trending.indexOf(topic);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _submit(topic),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            palette.primary.withValues(alpha: 0.2),
                            palette.secondary.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: palette.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: palette.textTertiary),
                  ],
                ),
              ),
            ),
          );
        }),
        
        const SizedBox(height: 32),
        
        // Empty State Illustration
        Center(
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: palette.textSecondary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Start Your Research Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for papers, topics, authors, or journals',
                style: TextStyle(
                  fontSize: 13,
                  color: palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<String> matches, AppPalette palette) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: palette.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                fontSize: 13,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final topic = matches[index];
        final isTrending = _trending.contains(topic);
        
        return InkWell(
          onTap: () => _submit(topic),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isTrending ? palette.warning : palette.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isTrending ? Icons.trending_up : Icons.topic_outlined,
                    size: 18,
                    color: isTrending ? palette.warning : palette.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Research Topic',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: palette.textTertiary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
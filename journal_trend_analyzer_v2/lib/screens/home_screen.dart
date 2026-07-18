import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/recent_search_entry.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/home_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'research_dashboard_screen.dart';
import 'search_suggestions_screen.dart';
import 'bookmark_library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Lĩnh vực nghiên cứu IT/Computer Science
  static const itResearchFields = [
    'Artificial Intelligence',
    'Machine Learning', 
    'Data Science',
    'Cybersecurity',
    'Blockchain Technology',
    'Internet of Things',
    'Software Engineering',
    'Computer Vision',
    'Natural Language Processing',
    'Cloud Computing',
    'Mobile Development',
    'Web Development',
  ];

  // Legacy support cho các screen khác
  static const popularTopics = itResearchFields;

  // Xu hướng nghiên cứu IT hot
  static const trendingItTopics = [
    'ChatGPT và Large Language Models',
    'Edge Computing',
    'Quantum Computing',  
    'DevOps và CI/CD',
    'Microservices Architecture',
    'Docker và Kubernetes',
  ];

  static final _placeholderRecents = [
    RecentSearchEntry(
      topic: 'Artificial Intelligence',
      searchedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentSearchEntry(
      topic: 'Cybersecurity',
      searchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentSearchEntry(
      topic: 'Machine Learning',
      searchedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Future<void> _openSearch(BuildContext context, {String? initialQuery}) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchSuggestionsScreen(initialQuery: initialQuery),
      ),
    );
  }

  Future<void> _searchTopic(BuildContext context, String topic) async {
    context.read<AppNavigationProvider>().goToTab(1);
    await context.read<PublicationProvider>().searchPublications(topic);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final authProvider = context.watch<AuthViewModel>();
    final palette = context.palette;
    final recents = provider.recentSearches.isNotEmpty
        ? provider.recentSearches.take(3).toList()
        : _placeholderRecents;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner with Gradient
          _buildHeroBanner(context, authProvider, palette),
          
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personalized Research Overview
                _buildPersonalizedOverview(context, provider, authProvider, palette),
                const SizedBox(height: 24),
                
                // Today's Research Highlight
                _buildTodayHighlight(context, palette),
                const SizedBox(height: 28),
                
                // Trending Topics (Horizontal Scroll)
                SectionHeader(title: 'Trending Research Topics'),
                const SizedBox(height: 12),
                _buildTrendingTopicsScroll(context, provider, palette),
                const SizedBox(height: 28),
                
                // Latest Publications
                SectionHeader(
                  title: 'Latest Publications',
                  trailing: TextButton(
                    onPressed: () => context.read<AppNavigationProvider>().goToTab(1),
                    child: Text('See all', style: TextStyle(color: palette.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                _buildLatestPublicationsSection(context, provider, palette),
                const SizedBox(height: 28),
                
                // Lightweight Publication Trend Chart
                if (provider.hasData)
                  _buildLightweightTrendChart(context, provider, palette),
                if (provider.hasData) const SizedBox(height: 28),
                
                // Recent Searches - Quick Access
                if (recents.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Recent Searches',
                    trailing: TextButton(
                      onPressed: provider.clearRecentSearches,
                      child: Text('Clear', style: TextStyle(color: palette.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentSearchesGrid(context, recents, provider, palette),
                  const SizedBox(height: 28),
                ],
                
                // Recommended For You
                SectionHeader(title: 'Recommended For You'),
                const SizedBox(height: 12),
                _buildRecommendationsSection(context, provider, palette),
                const SizedBox(height: 28),
                
                // Continue Reading / Saved Papers Shortcut
                _buildQuickActionsSection(context, palette),
                const SizedBox(height: 28),
                
                // CTA to Full Analytics Dashboard
                _buildFullAnalyticsCTA(context, palette),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PREMIUM UI COMPONENTS ==========

  Widget _buildPersonalizedOverview(
    BuildContext context,
    PublicationProvider provider,
    AuthViewModel authProvider,
    AppPalette palette,
  ) {
    // Determine user's research field based on bookmarked topics
    final bookmarkedTopics = provider.bookmarkedTopics;
    final recentSearches = provider.recentSearches;
    
    // Infer primary research field
    String primaryField = 'Computer Science';
    if (bookmarkedTopics.isNotEmpty) {
      final first = bookmarkedTopics.first;
      if (first.toLowerCase().contains('ai') || first.toLowerCase().contains('artificial')) {
        primaryField = 'Artificial Intelligence';
      } else if (first.toLowerCase().contains('machine') || first.toLowerCase().contains('learning')) {
        primaryField = 'Machine Learning';
      } else if (first.toLowerCase().contains('data')) {
        primaryField = 'Data Science';
      } else if (first.toLowerCase().contains('security')) {
        primaryField = 'Cybersecurity';
      }
    }
    
    // Calculate user's research stats (based on searches + bookmarks)
    final totalInterests = bookmarkedTopics.length + recentSearches.length;
    final activeTopics = bookmarkedTopics.length;
    final recentActivity = recentSearches.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.primary.withValues(alpha: 0.1),
            palette.secondary.withValues(alpha: 0.1),
            palette.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Research Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                      ),
                    ),
                    Text(
                      'Personalized insights for you',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Primary Research Field
          Container(
            padding: const EdgeInsets.all(16),
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
                    color: palette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school, color: palette.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Research Field',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        primaryField,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified, color: palette.success, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Research Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  totalInterests.toString(),
                  'Total Interests',
                  Icons.interests,
                  palette.primary,
                  palette,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  activeTopics.toString(),
                  'Saved Topics',
                  Icons.bookmark,
                  palette.secondary,
                  palette,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  recentActivity.toString(),
                  'Recent Searches',
                  Icons.history,
                  palette.accent,
                  palette,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Recent Volumes Section
          if (provider.hasData && provider.publications.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.article, color: palette.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Recent Publications in Your Field',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.library_books, color: palette.warning, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Volume ${provider.publications.first.year} • ${provider.publications.length} papers',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Latest research in $primaryField',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: palette.textTertiary),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AppNavigationProvider>().goToTab(1),
                  icon: Icon(Icons.explore, size: 16, color: palette.primary),
                  label: Text(
                    'Explore More',
                    style: TextStyle(fontSize: 13, color: palette.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResearchDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights, size: 16),
                  label: const Text('View Insights', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    AppPalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, AuthViewModel authProvider, AppPalette palette) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: palette.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.primary,
                palette.secondary,
                palette.accent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: authProvider.userPhotoUrl != null
                            ? NetworkImage(authProvider.userPhotoUrl!)
                            : null,
                        child: authProvider.userPhotoUrl == null
                            ? Icon(Icons.person, color: palette.primary, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.isSignedIn 
                                  ? 'Welcome back,'
                                  : 'Welcome,',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              authProvider.isSignedIn 
                                  ? authProvider.userDisplayName.split(' ').first
                                  : 'Researcher',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.read<AppNavigationProvider>().goToTab(3),
                        icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discover Research & Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Powered by OpenAlex',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHighlight(BuildContext context, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.primary.withValues(alpha: 0.1),
            palette.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⭐ TODAY\'S HIGHLIGHT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Large Language Models: Recent Advances and Applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore the latest breakthroughs in LLMs, from GPT-4 to emerging architectures.',
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricChip('2.4K citations', Icons.format_quote, palette),
              const SizedBox(width: 8),
              _buildMetricChip('Published 2024', Icons.calendar_today, palette),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Read More'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, IconData icon, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: palette.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopicsScroll(BuildContext context, PublicationProvider provider, AppPalette palette) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itResearchFields.length,
        itemBuilder: (context, index) {
          final topic = itResearchFields[index];
          return Padding(
            padding: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 0),
            child: ActionChip(
              label: Text(topic),
              onPressed: () => _searchTopic(context, topic),
              backgroundColor: palette.surface,
              side: BorderSide(color: palette.border),
              labelStyle: TextStyle(
                fontSize: 13,
                color: palette.textPrimary,
              ),
              avatar: Icon(
                Icons.trending_up,
                size: 16,
                color: palette.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestPublicationsSection(BuildContext context, PublicationProvider provider, AppPalette palette) {
    if (!provider.hasData || provider.publications.isEmpty) {
      return _buildPlaceholderPublications(context, palette);
    }
    
    return Column(
      children: provider.publications.take(3).map((pub) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPublicationCard(
            context,
            title: pub.title,
            authors: pub.authors.take(2).join(', '),
            year: pub.year.toString(),
            citations: pub.citations,
            palette: palette,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholderPublications(BuildContext context, AppPalette palette) {
    final placeholders = [
      {
        'title': 'Attention Is All You Need: Transformer Architecture',
        'authors': 'Vaswani et al.',
        'year': '2024',
        'citations': 12500,
      },
      {
        'title': 'Deep Residual Learning for Image Recognition',
        'authors': 'He, Zhang, Ren, Sun',
        'year': '2023',
        'citations': 8900,
      },
      {
        'title': 'BERT: Pre-training of Deep Bidirectional Transformers',
        'authors': 'Devlin et al.',
        'year': '2024',
        'citations': 15200,
      },
    ];
    
    return Column(
      children: placeholders.map((pub) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPublicationCard(
            context,
            title: pub['title'] as String,
            authors: pub['authors'] as String,
            year: pub['year'] as String,
            citations: pub['citations'] as int,
            palette: palette,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPublicationCard(
    BuildContext context, {
    required String title,
    required String authors,
    required String year,
    required int citations,
    required AppPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            authors,
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: palette.textTertiary),
              const SizedBox(width: 4),
              Text(
                year,
                style: TextStyle(fontSize: 12, color: palette.textTertiary),
              ),
              const SizedBox(width: 16),
              Icon(Icons.format_quote, size: 14, color: palette.accent),
              const SizedBox(width: 4),
              Text(
                '$citations citations',
                style: TextStyle(fontSize: 12, color: palette.accent),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.bookmark_border, size: 18, color: palette.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLightweightTrendChart(BuildContext context, PublicationProvider provider, AppPalette palette) {
    final yearCounts = <int, int>{};
    for (final pub in provider.publications) {
      yearCounts[pub.year] = (yearCounts[pub.year] ?? 0) + 1;
    }
    
    final sortedYears = yearCounts.keys.toList()..sort();
    if (sortedYears.isEmpty) return const SizedBox.shrink();
    
    final chartData = sortedYears.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), yearCounts[entry.value]!.toDouble());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: palette.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Publication Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: palette.border, strokeWidth: 0.5);
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedYears.length) {
                          return Text(
                            sortedYears[index].toString(),
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: palette.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: palette.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }  Widget _buildRecentSearchesGrid(BuildContext context, List<RecentSearchEntry> recents, PublicationProvider provider, AppPalette palette) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recents.map((entry) {
        return InkWell(
          onTap: () => _searchTopic(context, entry.topic),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 16, color: palette.textSecondary),
                const SizedBox(width: 8),
                Text(
                  entry.topic,
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
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, PublicationProvider provider, AppPalette palette) {
    return Column(
      children: trendingItTopics.take(3).map((topic) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _searchTopic(context, topic),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.lightbulb_outline, color: palette.secondary),
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
                          'Based on your interests',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: palette.textTertiary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, AppPalette palette) {
    final provider = context.watch<PublicationProvider>();
    
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'My Library',
            Icons.bookmark_outline,
            palette.primary,
            provider.bookmarkedTopics.length.toString(),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarkLibraryScreen()),
            ),
            palette,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'Analytics',
            Icons.analytics_outlined,
            palette.secondary,
            null,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResearchDashboardScreen()),
            ),
            palette,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    String? badge,
    VoidCallback onTap,
    AppPalette palette,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 32),
                if (badge != null && badge != '0')
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: palette.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullAnalyticsCTA(BuildContext context, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.accent.withValues(alpha: 0.2),
            palette.primary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Full Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View detailed charts and insights',
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.read<AppNavigationProvider>().goToTab(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

}

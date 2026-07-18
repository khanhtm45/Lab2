import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';

/// Premium Bookmark Library Screen
/// Displays saved topics, papers, and journals with beautiful categorization
class BookmarkLibraryScreen extends StatefulWidget {
  const BookmarkLibraryScreen({super.key});

  @override
  State<BookmarkLibraryScreen> createState() => _BookmarkLibraryScreenState();
}

class _BookmarkLibraryScreenState extends State<BookmarkLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final palette = context.palette;
    final bookmarkedTopics = provider.bookmarkedTopics;

    return Scaffold(
      backgroundColor: palette.background,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with Gradient
          SliverAppBar(
            expandedHeight: 160,
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
                      palette.secondary,
                      palette.primary,
                      palette.accent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.bookmark,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Library',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Your saved research collection',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: palette.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: palette.primary,
                  unselectedLabelColor: palette.textSecondary,
                  indicatorColor: palette.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.topic, size: 18),
                          const SizedBox(width: 6),
                          Text('Topics (${bookmarkedTopics.length})'),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article, size: 18),
                          SizedBox(width: 6),
                          Text('Papers (0)'),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book, size: 18),
                          SizedBox(width: 6),
                          Text('Journals (0)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopicsTab(context, provider, palette),
                _buildPapersTab(context, palette),
                _buildJournalsTab(context, palette),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab(
      BuildContext context, PublicationProvider provider, AppPalette palette) {
    final topics = provider.bookmarkedTopics;

    if (topics.isEmpty) {
      return _buildEmptyState(
        context,
        palette,
        icon: Icons.topic_outlined,
        title: 'No Saved Topics',
        message: 'Bookmark topics to access them quickly',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palette.primary.withValues(alpha: 0.1),
                palette.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome, color: palette.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${topics.length} Saved Topics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                      ),
                    ),
                    Text(
                      'Keep track of your research interests',
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
        ),
        const SizedBox(height: 20),

        // Clear All Button
        if (topics.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showClearConfirmation(context, provider),
              icon: Icon(Icons.delete_outline, size: 16, color: palette.error),
              label: Text(
                'Clear All',
                style: TextStyle(color: palette.error),
              ),
            ),
          ),
        const SizedBox(height: 12),

        // Topics Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return _buildTopicCard(context, topic, provider, palette);
          },
        ),
      ],
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    String topic,
    PublicationProvider provider,
    AppPalette palette,
  ) {
    final colors = [
      palette.primary,
      palette.secondary,
      palette.accent,
      palette.warning,
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];
    final color = colors[topic.hashCode % colors.length];

    return InkWell(
      onTap: () => _searchTopic(context, topic),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.topic, size: 16, color: color),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => provider.toggleBookmarkTopic(topic),
                  child: Icon(
                    Icons.bookmark,
                    size: 18,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                topic,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.search, size: 12, color: palette.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Tap to search',
                  style: TextStyle(
                    fontSize: 10,
                    color: palette.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPapersTab(BuildContext context, AppPalette palette) {
    return _buildEmptyState(
      context,
      palette,
      icon: Icons.article_outlined,
      title: 'No Saved Papers',
      message: 'Bookmark papers to read them later',
      subtitle: 'Feature coming soon',
    );
  }

  Widget _buildJournalsTab(BuildContext context, AppPalette palette) {
    return _buildEmptyState(
      context,
      palette,
      icon: Icons.book_outlined,
      title: 'No Saved Journals',
      message: 'Bookmark journals to track their publications',
      subtitle: 'Feature coming soon',
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppPalette palette, {
    required IconData icon,
    required String title,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: palette.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _searchTopic(BuildContext context, String topic) async {
    Navigator.pop(context);
    context.read<AppNavigationProvider>().goToTab(1);
    await context.read<PublicationProvider>().searchPublications(topic);
  }

  Future<void> _showClearConfirmation(
      BuildContext context, PublicationProvider provider) async {
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Bookmarks?',
          style: TextStyle(color: palette.textPrimary),
        ),
        content: Text(
          'This will remove all ${provider.bookmarkedTopics.length} saved topics.',
          style: TextStyle(color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: palette.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearBookmarkedTopics();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All bookmarks cleared'),
            backgroundColor: palette.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

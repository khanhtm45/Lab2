import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/journal_volume.dart';
import '../theme/app_theme.dart';

class JournalVolumeScreen extends StatelessWidget {
  final JournalVolume volume;
  final String journalName;
  
  const JournalVolumeScreen({
    super.key,
    required this.volume,
    required this.journalName,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$journalName - Volume ${volume.volumeNumber}'),
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Bookmark volume
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Volume đã được bookmark')),
              );
            },
            icon: const Icon(Icons.bookmark_border),
          ),
        ],
      ),
      backgroundColor: palette.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Volume Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.auto_stories, color: palette.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Volume ${volume.volumeNumber}, Issue ${volume.issueNumber}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                          ),
                          Text(
                            'Năm xuất bản: ${volume.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      'Bài báo',
                      '${volume.articleCount}',
                      Icons.article_outlined,
                      palette.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      context,
                      'Xuất bản',
                      _formatDate(volume.publishedDate),
                      Icons.calendar_today_outlined,
                      palette.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Articles Section
          Row(
            children: [
              Icon(Icons.list_alt, color: palette.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Bài báo trong Volume (${volume.articles.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Articles List
          ...volume.articles.asMap().entries.map((entry) {
            final index = entry.key;
            final article = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildArticleCard(context, article, index + 1, palette),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, IconData icon, Color color) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, VolumeArticle article, int index, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.authors.take(3).join(', ') + 
                      (article.authors.length > 3 ? ' và ${article.authors.length - 3} tác giả khác' : ''),
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Abstract preview
          Text(
            article.abstractText,
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Keywords
          if (article.keywords.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: article.keywords.take(4).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Article stats and actions
          Row(
            children: [
              // Citation count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.format_quote, size: 12, color: palette.accent),
                    const SizedBox(width: 4),
                    Text(
                      '${article.citationCount} trích dẫn',
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Published date
              Text(
                _formatDate(article.publishedDate),
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textTertiary,
                ),
              ),
              
              const Spacer(),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Bookmark article
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bài báo đã được bookmark')),
                      );
                    },
                    icon: Icon(Icons.bookmark_border, size: 18, color: palette.textSecondary),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _openDOI(article.doi),
                    icon: Icon(Icons.open_in_new, size: 18, color: palette.primary),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _openDOI(String doi) async {
    final url = 'https://doi.org/$doi';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/journal_volume.dart';
import '../providers/publication_provider.dart';
import '../services/openalex_service.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_logo.dart';
import '../widgets/publication_list_skeleton.dart';
import '../widgets/empty_state_view.dart';
import 'journal_detail_screen.dart';
import 'journal_volume_screen.dart';

/// IT/CS journal seeds shown as quick chips  
const _popularJournals = [
  'IEEE Transactions on Software Engineering',
  'ACM Computing Surveys',
  'Nature Machine Intelligence', 
  'IEEE Computer',
  'Communications of the ACM',
  'Journal of Machine Learning Research',
  'IEEE Transactions on Cybernetics',
  'Artificial Intelligence',
  'Computer Networks',
  'IEEE Access',
];

// ─── Main Journal Tab Screen ──────────────────────────────────────────────────

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();

  List<OpenAlexRankedEntity> _results = [];
  final List<String> _recentSearches   = [];
  bool _loading  = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();

    if (!_recentSearches.contains(query)) {
      setState(() => _recentSearches.insert(0, query));
    }

    setState(() {
      _loading  = true;
      _searched = true;
      _error    = null;
      _results  = [];
    });

    try {
      final provider = context.read<PublicationProvider>();
      // Fetch journals by grouping works by source for the search term
      final results = await provider.openAlexService.fetchWorksGroupedCounts(
        groupBy: OpenAlexService.groupByJournal,
        search:  query,
        limit:   20,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _openDetail(OpenAlexRankedEntity journal) {
    final provider = context.read<PublicationProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalDetailScreen(
          journal:  journal,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s       = context.strings;
    final palette = context.palette;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.searchJournals,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        'Powered by OpenAlex',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _GradientBadge(label: s.live),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _JournalSearchBar(
              controller: _controller,
              focusNode:  _focusNode,
              onSubmit:   _search,
            ),
          ),
          const SizedBox(height: 12),

          // ── Recent chips ───────────────────────────────────────────────────
          if (_recentSearches.isNotEmpty)
            _RecentChipsRow(
              label:   s.recentJournalSearches,
              items:   _recentSearches.take(5).toList(),
              onTap:   (q) {
                _controller.text = q;
                _search(q);
              },
              onClear: () => setState(() => _recentSearches.clear()),
            ),

          // ── Popular journal chips ──────────────────────────────────────────
          if (!_searched)
            _PopularRow(
              label:  s.popularJournals,
              items:  _popularJournals,
              onTap:  (q) {
                _controller.text = q;
                _search(q);
              },
            ),

          const SizedBox(height: 8),

          // ── Body ───────────────────────────────────────────────────────────
          Expanded(child: _buildBody(s, palette)),
        ],
      ),
    );
  }

  Widget _buildBody(dynamic s, AppPalette palette) {
    if (_loading) {
      return SkeletonShimmer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(5, (_) => const _JournalCardSkeleton()),
        ),
      );
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: () => _search(_controller.text));
    }

    if (!_searched) {
      return _EmptyIdle();
    }

    if (_results.isEmpty) {
      return EmptyStateView(
        icon:     Icons.menu_book_outlined,
        title:    s.noJournalsFound,
        subtitle: s.noJournalResultsSubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: _results.length,
      itemBuilder: (_, i) => _JournalCard(
        journal: _results[i],
        onTap:   () => _openDetail(_results[i]),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _JournalSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmit;

  const _JournalSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final s       = context.strings;
    final palette = context.palette;
    return Material(
      color:        palette.surface,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      elevation:    0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          border:       Border.all(color: palette.border),
          boxShadow:    palette.cardShadow,
        ),
        child: TextField(
          controller:    controller,
          focusNode:     focusNode,
          onSubmitted:   onSubmit,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 14, color: palette.textPrimary),
          decoration: InputDecoration(
            hintText: s.searchJournalHint,
            hintStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: palette.primary, size: 22),
            suffixIcon: IconButton(
              icon:    Icon(Icons.arrow_forward_rounded, color: palette.primary),
              onPressed: () => onSubmit(controller.text),
            ),
            border:        InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: false,
          ),
        ),
      ),
    );
  }
}

class _GradientBadge extends StatelessWidget {
  final String label;
  const _GradientBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RecentChipsRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  const _RecentChipsRow({
    required this.label,
    required this.items,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClear,
                  child: Text(
                    'Clear',
                    style: TextStyle(fontSize: 11, color: palette.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _chip(context, items[i], palette),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, AppPalette palette) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        palette.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 13, color: palette.textSecondary),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: palette.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onTap;

  const _PopularRow({
    required this.label,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final colors = [
                AppColors.primary, AppColors.secondary, AppColors.accent,
                AppColors.warning, AppColors.success,
              ];
              final c = colors[i % colors.length];
              return GestureDetector(
                onTap: () => onTap(items[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color:        c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: c.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    items[i],
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: c,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Journal Card ─────────────────────────────────────────────────────────────

class _JournalCard extends StatefulWidget {
  final OpenAlexRankedEntity journal;
  final VoidCallback onTap;

  const _JournalCard({required this.journal, required this.onTap});

  @override
  State<_JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends State<_JournalCard> {
  bool _favorite = false;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.primary, AppColors.secondary, AppColors.accent,
      AppColors.warning, AppColors.success,
    ];
    return colors[name.length % colors.length];
  }

  void _showVolumes(BuildContext context, OpenAlexRankedEntity journal) {
    // Hiển thị bottom sheet với danh sách volumes
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final palette = context.palette;
          final volumes = JournalVolume.getMockVolumes(journal.name);
          
          return Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volumes gần đây',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                            ),
                            Text(
                              journal.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: palette.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Volumes list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: volumes.length,
                    itemBuilder: (context, index) {
                      final volume = volumes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.border),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JournalVolumeScreen(
                                  volume: volume,
                                  journalName: journal.name,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: palette.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.auto_stories,
                                  color: palette.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Volume ${volume.volumeNumber}, Issue ${volume.issueNumber}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: palette.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${volume.articleCount} bài báo • ${volume.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: palette.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: palette.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s       = context.strings;
    final palette = context.palette;
    final j       = widget.journal;
    final color   = _avatarColor(j.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color:        palette.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        child: InkWell(
          onTap:        widget.onTap,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.cardRadius),
              border:       Border.all(color: palette.border.withValues(alpha: 0.8)),
              boxShadow:    palette.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _initials(j.name),
                      style: const TextStyle(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              j.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize:   14,
                                height:     1.3,
                                color:      palette.textPrimary,
                              ),
                            ),
                          ),
                          // Favorite button
                          GestureDetector(
                            onTap: () {
                              setState(() => _favorite = !_favorite);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(_favorite
                                    ? s.addedToFavorites
                                    : s.removedFromFavorites),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                _favorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _favorite ? AppColors.error : palette.textTertiary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Stats row
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _StatPill(
                            icon:  Icons.article_outlined,
                            label: formatOpenAlexCount(j.count),
                            color: palette.primary,
                          ),
                          _StatPill(
                            icon:  Icons.format_quote_rounded,
                            label: 'OpenAlex',
                            color: palette.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Action buttons row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showVolumes(context, j),
                              icon: Icon(
                                Icons.auto_stories_outlined, 
                                size: 16,
                                color: palette.primary,
                              ),
                              label: Text(
                                'Xem Volumes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 32),
                                side: BorderSide(color: palette.primary, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onTap,
                              icon: Icon(
                                Icons.info_outline, 
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Chi tiết',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 32),
                                backgroundColor: palette.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;

  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ─── Skeleton card ────────────────────────────────────────────────────────────
class _JournalCardSkeleton extends StatelessWidget {
  const _JournalCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            SkeletonBox(width: 52, height: 52, borderRadius: 14),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, borderRadius: 7),
                  SizedBox(height: 8),
                  SkeletonBox(width: 180, height: 12, borderRadius: 6),
                  SizedBox(height: 10),
                  Row(children: [
                    SkeletonBox(width: 60, height: 20, borderRadius: 8),
                    SizedBox(width: 8),
                    SkeletonBox(width: 70, height: 20, borderRadius: 8),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────
class _EmptyIdle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s       = context.strings;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.secondary.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                s.noJournalResultsYet,
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              s.noJournalResultsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

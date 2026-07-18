import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/publication.dart';
import '../models/publication_author.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/related_paper_tile.dart';
import 'author_detail_screen.dart';

class DetailScreen extends StatefulWidget {
  final Publication publication;

  const DetailScreen({
    super.key,
    required this.publication,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const _authorPreviewCount = 3;
  static const _abstractPreviewLines = 5;

  bool _expandedAbstract = false;
  bool _expandedAuthors = false;
  bool _bookmarked = false;
  List<Publication> _relatedWorks = [];
  bool _loadingRelated = false;

  final _scrollController = ScrollController();
  final _relatedSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadRelatedWorks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRelatedWorks() async {
    final publication = widget.publication;
    if (publication.relatedWorkIds.isEmpty) return;

    setState(() => _loadingRelated = true);

    try {
      final provider = context.read<PublicationProvider>();
      final related = await provider.loadRelatedWorks(publication);
      if (!mounted) return;
      setState(() {
        _relatedWorks = related;
        _loadingRelated = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRelated = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      final s = context.stringsOf;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.couldNotOpenLink)),
      );
    }
  }

  Future<void> _sharePublication(Publication publication) async {
    final buffer = StringBuffer(publication.title);
    if (publication.hasDoi) {
      buffer.writeln('\n\nDOI: ${publication.displayDoi}');
    } else if (publication.readUrl != null) {
      buffer.writeln('\n\n${publication.readUrl}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    final s = context.stringsOf;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.publicationDetailsCopied)),
    );
  }

  void _openAuthor(PublicationAuthor author) {
    if (!author.hasOpenAlexId && author.name.isEmpty) return;

    final provider = context.read<PublicationProvider>();
    final ranked = provider.rankedAuthorByName(author.name);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthorDetailScreen(
          author: ranked ??
              OpenAlexRankedEntity(
                id: author.id,
                name: author.name,
                count: 0,
              ),
          provider: provider,
        ),
      ),
    );
  }

  void _scrollToRelated() {
    final context = _relatedSectionKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final publication = widget.publication;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.publicationDetail,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
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
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _sharePublication(publication),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(publication: publication),
                  const SizedBox(height: 20),
                  _AuthorsSection(
                    publication: publication,
                    expanded: _expandedAuthors,
                    previewCount: _authorPreviewCount,
                    onToggleExpand: () {
                      setState(() => _expandedAuthors = !_expandedAuthors);
                    },
                    onAuthorTap: _openAuthor,
                  ),
                  const SizedBox(height: 20),
                  _AbstractSection(
                    publication: publication,
                    expanded: _expandedAbstract,
                    previewLines: _abstractPreviewLines,
                    onReadMore: () {
                      setState(() => _expandedAbstract = !_expandedAbstract);
                    },
                  ),
                  if (publication.concepts.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _ResearchTopicsSection(concepts: publication.concepts),
                  ],
                  const SizedBox(height: 20),
                  _PublicationInfoSection(publication: publication),
                  if (publication.relatedWorkIds.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _RelatedSection(
                      key: _relatedSectionKey,
                      relatedWorks: _relatedWorks,
                      loading: _loadingRelated,
                      onPaperTap: (paper) {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => DetailScreen(publication: paper),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 88 + bottomInset),
                ],
              ),
            ),
          ),
          _BottomActions(
            publication: publication,
            hasRelated: publication.relatedWorkIds.isNotEmpty,
            onOpenDoi: publication.doiUrl != null
                ? () => _openUrl(publication.doiUrl!)
                : null,
            onViewRelated: _scrollToRelated,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Publication publication;

  const _HeroCard({required this.publication});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final typeLabel = publicationTypeLabel(s, publication.workType);
    final doi = publication.displayDoi;

    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            publication.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(
                label: typeLabel,
                color: AppColors.primary,
                background: AppColors.primary.withValues(alpha: 0.1),
              ),
              if (publication.isOpenAccess)
                _InfoBadge(
                  label: s.openAccess,
                  color: AppColors.analyticsTeal,
                  background: const Color(0x1A14B8A6),
                ),
              _InfoBadge(
                label: s.publishedInYear(publication.year),
                color: AppColors.textSecondary,
                background: AppColors.surfaceMuted,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _SummaryStat(
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.citationAmber,
            iconBg: AppColors.citationAmber.withValues(alpha: 0.12),
            value: s.citationCountLabel(
              formatOpenAlexCount(publication.citations),
            ),
          ),
          const SizedBox(height: 12),
          _SummaryStat(
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primary.withValues(alpha: 0.1),
            value: publication.journal,
          ),
          if (doi.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SummaryStat(
              icon: Icons.link_rounded,
              iconColor: AppColors.textSecondary,
              iconBg: AppColors.surfaceMuted,
              value: 'DOI: $doi',
              valueStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _InfoBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryStat({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthorsSection extends StatelessWidget {
  final Publication publication;
  final bool expanded;
  final int previewCount;
  final VoidCallback onToggleExpand;
  final void Function(PublicationAuthor) onAuthorTap;

  const _AuthorsSection({
    required this.publication,
    required this.expanded,
    required this.previewCount,
    required this.onToggleExpand,
    required this.onAuthorTap,
  });

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static const _avatarColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.analyticsTeal,
    AppColors.citationAmber,
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final authors = publication.authorEntries;
    final hasMany = authors.length > previewCount;
    final visible = expanded || !hasMany
        ? authors
        : authors.take(previewCount).toList();

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(s.authors),
          const SizedBox(height: 14),
          ...visible.asMap().entries.map((entry) {
            final index = entry.key;
            final author = entry.value;
            final color = _avatarColors[index % _avatarColors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: author.hasOpenAlexId ? () => onAuthorTap(author) : null,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        _initials(author.name),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        author.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (author.hasOpenAlexId)
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                  ],
                ),
              ),
            );
          }),
          if (hasMany)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onToggleExpand,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  expanded
                      ? s.showFewerAuthors
                      : s.viewAllAuthors(authors.length),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AbstractSection extends StatelessWidget {
  final Publication publication;
  final bool expanded;
  final int previewLines;
  final VoidCallback onReadMore;

  const _AbstractSection({
    required this.publication,
    required this.expanded,
    required this.previewLines,
    required this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final abstract = publication.abstractText;
    final hasMore = abstract.length > 220;

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(s.abstract),
          const SizedBox(height: 12),
          Text(
            abstract,
            maxLines: expanded ? null : previewLines,
            overflow: expanded ? null : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
          if (hasMore) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onReadMore,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                expanded ? s.showLess : s.readMore,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResearchTopicsSection extends StatelessWidget {
  final List<String> concepts;

  const _ResearchTopicsSection({required this.concepts});

  static const _chipColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.analyticsTeal,
    AppColors.citationAmber,
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(s.researchTopics),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: concepts.asMap().entries.map((entry) {
              final color = _chipColors[entry.key % _chipColors.length];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PublicationInfoSection extends StatelessWidget {
  final Publication publication;

  const _PublicationInfoSection({required this.publication});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final typeLabel = publicationTypeLabel(s, publication.workType);
    final openAccessLabel =
        publication.isOpenAccess ? s.available : s.notAvailable;

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(s.publicationInformation),
          const SizedBox(height: 14),
          _InfoRow(label: s.publicationYear, value: '${publication.year}'),
          _InfoRow(label: s.journalLabel, value: publication.journal),
          _InfoRow(label: s.typeLabel, value: typeLabel),
          _InfoRow(label: s.languageLabel, value: s.englishLanguage),
          _InfoRow(
            label: s.openAccess,
            value: openAccessLabel,
            valueColor: publication.isOpenAccess
                ? AppColors.analyticsTeal
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedSection extends StatelessWidget {
  final List<Publication> relatedWorks;
  final bool loading;
  final void Function(Publication) onPaperTap;

  const _RelatedSection({
    super.key,
    required this.relatedWorks,
    required this.loading,
    required this.onPaperTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionTitle(s.relatedPapers)),
              if (!loading && relatedWorks.isNotEmpty)
                Text(
                  '${relatedWorks.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            SizedBox(
              height: 120,
              child: AppLoadingView(
                fillScreen: false,
                size: 80,
                message: s.loadingRelatedPapers,
              ),
            )
          else if (relatedWorks.isEmpty)
            Text(
              s.noRelatedPapers,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            ...relatedWorks.map(
              (paper) => RelatedPaperTile(
                paper: paper,
                onTap: () => onPaperTap(paper),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final Publication publication;
  final bool hasRelated;
  final VoidCallback? onOpenDoi;
  final VoidCallback onViewRelated;

  const _BottomActions({
    required this.publication,
    required this.hasRelated,
    required this.onOpenDoi,
    required this.onViewRelated,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onOpenDoi ??
                  (publication.readUrl != null
                      ? () async {
                          final uri = Uri.tryParse(publication.readUrl!);
                          if (uri != null) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      : null),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                s.openDoi,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: hasRelated ? onViewRelated : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: AppColors.border,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                s.viewRelatedPapers,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

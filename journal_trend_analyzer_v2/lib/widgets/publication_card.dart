import 'package:flutter/material.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/publication.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_logo.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;

  const PublicationCard({
    super.key,
    required this.publication,
  });

  static String formatAuthorLine(List<String> names) {
    if (names.isEmpty) return '';
    return names.take(3).map(_shortAuthorName).join(', ');
  }

  static String _shortAuthorName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return name;
    final last = parts.last;
    final first = parts.first;
    if (first.contains('.')) return name;
    return '${first[0]}. $last';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final authors = formatAuthorLine(publication.authors);
    final typeLabel = publicationTypeLabel(s, publication.workType);
    final isOpenAccess = publication.isOpenAccess;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(publication: publication),
            ),
          );
        },
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 19,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publication.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    publication.journal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${publication.year} • $typeLabel',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CitationBadge(
                    citations: publication.citations,
                    label: s.citationCountLabel(
                      formatOpenAlexCount(publication.citations),
                    ),
                  ),
                  if (authors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      authors,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (isOpenAccess) ...[
                    const SizedBox(height: 8),
                    _OpenAccessPill(label: s.openAccess),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitationBadge extends StatelessWidget {
  final int citations;
  final String label;

  const _CitationBadge({
    required this.citations,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.citationAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 13,
            color: AppColors.citationAmber,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.citationAmber,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenAccessPill extends StatelessWidget {
  final String label;

  const _OpenAccessPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.analyticsTeal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.analyticsTeal.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.analyticsTeal,
        ),
      ),
    );
  }
}

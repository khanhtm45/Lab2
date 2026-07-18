import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../models/ranked_author_entry.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import 'app_logo.dart';

enum AuthorSortOption { mostPublications, mostCitations, alphabetical }

Future<AuthorSortOption?> showAuthorSortSheet(
  BuildContext context,
  AuthorSortOption current,
) {
  return showModalBottomSheet<AuthorSortOption>(
    context: context,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.sortAuthors,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            RadioListTile<AuthorSortOption>(
              title: Text(s.mostPublications),
              value: AuthorSortOption.mostPublications,
              groupValue: current,
              activeColor: AppColors.secondary,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            RadioListTile<AuthorSortOption>(
              title: Text(s.mostCitations),
              value: AuthorSortOption.mostCitations,
              groupValue: current,
              activeColor: AppColors.secondary,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            RadioListTile<AuthorSortOption>(
              title: Text(s.sortAlphabetical),
              value: AuthorSortOption.alphabetical,
              groupValue: current,
              activeColor: AppColors.secondary,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class AuthorInitials {
  static String fromName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.length >= 2
          ? words.first.substring(0, 2).toUpperCase()
          : words.first[0].toUpperCase();
    }
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }
}

class FeaturedTopAuthorsCard extends StatelessWidget {
  final List<RankedAuthorEntry> authors;
  final void Function(RankedAuthorEntry author) onAuthorTap;

  const FeaturedTopAuthorsCard({
    super.key,
    required this.authors,
    required this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: authors.asMap().entries.map((entry) {
          final index = entry.key;
          final author = entry.value;
          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.7),
                ),
              _FeaturedAuthorRow(
                rank: index + 1,
                author: author,
                onTap: () => onAuthorTap(author),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FeaturedAuthorRow extends StatelessWidget {
  final int rank;
  final RankedAuthorEntry author;
  final VoidCallback onTap;

  const _FeaturedAuthorRow({
    required this.rank,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final isFirst = rank == 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isFirst ? AppColors.secondary : AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  AuthorInitials.fromName(author.name),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isFirst ? 15 : 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatOpenAlexCount(author.publicationCount)} ${s.metricPublications}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.analyticsTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          size: 14,
                          color: AppColors.citationAmber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.citationCountLabel(
                            formatOpenAlexCount(author.citationCount),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.citationAmber,
                          ),
                        ),
                      ],
                    ),
                    if (author.institution != 'N/A') ...[
                      const SizedBox(height: 4),
                      Text(
                        author.institution,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthorRankListCard extends StatelessWidget {
  final int rank;
  final RankedAuthorEntry author;
  final VoidCallback onTap;

  const AuthorRankListCard({
    super.key,
    required this.rank,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                AuthorInitials.fromName(author.name),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${author.name} — ${formatOpenAlexCount(author.publicationCount)} ${s.metricPublications}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        size: 13,
                        color: AppColors.citationAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.citationCountLabel(
                          formatOpenAlexCount(author.citationCount),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.citationAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author.institution,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

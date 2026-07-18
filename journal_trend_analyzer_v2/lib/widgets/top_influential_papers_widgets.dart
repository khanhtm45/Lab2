import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../models/publication.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import 'app_logo.dart';

class PodiumTopThree extends StatelessWidget {
  final List<Publication> papers;
  final void Function(Publication paper) onPaperTap;

  const PodiumTopThree({
    super.key,
    required this.papers,
    required this.onPaperTap,
  });

  static final _medalColors = [
    AppColors.citationAmber,
    Color(0xFF94A3B8),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    if (papers.isEmpty) return const SizedBox.shrink();

    final top3 = papers.take(3).toList();
    final order = top3.length >= 3
        ? [top3[1], top3[0], top3[2]]
        : top3.length == 2
            ? [top3[1], top3[0]]
            : top3;

    final ranks = top3.length >= 3
        ? [2, 1, 3]
        : top3.length == 2
            ? [2, 1]
            : [1];

    return SizedBox(
      height: top3.length >= 3 ? 210 : 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(order.length, (index) {
          final paper = order[index];
          final rank = ranks[index];
          final isFirst = rank == 1;
          final color = _medalColors[rank - 1];
          return Expanded(
            flex: isFirst ? 11 : 10,
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == order.length - 1 ? 0 : 4,
                bottom: isFirst ? 0 : 12,
              ),
              child: _PodiumSlot(
                rank: rank,
                paper: paper,
                accentColor: color,
                height: isFirst ? 190 : 158,
                onTap: () => onPaperTap(paper),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final int rank;
  final Publication paper;
  final Color accentColor;
  final double height;
  final VoidCallback onTap;

  const _PodiumSlot({
    required this.rank,
    required this.paper,
    required this.accentColor,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentColor.withValues(alpha: 0.45)),
            boxShadow: AppDimens.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      rank == 1
                          ? Icons.emoji_events_rounded
                          : Icons.military_tech_rounded,
                      color: accentColor,
                      size: rank == 1 ? 26 : 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$rank${_ordinal(rank)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper.title,
                        maxLines: rank == 1 ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: rank == 1 ? 12 : 11,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 12,
                            color: accentColor,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              formatOpenAlexCount(paper.citations),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ordinal(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }
}

class InfluentialPaperRankCard extends StatelessWidget {
  final int rank;
  final Publication paper;
  final VoidCallback onTap;

  const InfluentialPaperRankCard({
    super.key,
    required this.rank,
    required this.paper,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.title,
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
                    paper.journal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${paper.year}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                          s.citationCountLabel(
                            formatOpenAlexCount(paper.citations),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.citationAmber,
                          ),
                        ),
                      ],
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
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

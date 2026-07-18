import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import 'app_logo.dart';

class JournalsHorizontalBarChart extends StatelessWidget {
  final List<OpenAlexRankedEntity> journals;

  const JournalsHorizontalBarChart({
    super.key,
    required this.journals,
  });

  static Color _barColor(int index) {
    if (index == 0) return AppColors.analyticsTeal;
    return index.isOdd ? AppColors.secondary : AppColors.analyticsTeal;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final top = journals.take(5).toList();
    if (top.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            s.noJournalData,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxValue = top.first.count.toDouble();

    return Column(
      children: top.asMap().entries.map((entry) {
        final index = entry.key;
        final journal = entry.value;
        final ratio = journal.count / maxValue;
        final color = _barColor(index);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      journal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${formatOpenAlexCount(journal.count)} ${s.metricPublications}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.06, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: index == 0
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class RankedJournalCard extends StatelessWidget {
  final int rank;
  final OpenAlexRankedEntity journal;
  final VoidCallback onViewPublications;

  const RankedJournalCard({
    super.key,
    required this.rank,
    required this.journal,
    required this.onViewPublications,
  });

  static String initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.length >= 2
          ? words.first.substring(0, 2).toUpperCase()
          : words.first[0].toUpperCase();
    }
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final isTop = rank == 1;
    final accent = isTop ? AppColors.analyticsTeal : AppColors.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                initials(journal.name),
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
                    journal.name,
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
                    '${formatOpenAlexCount(journal.count)} ${s.metricPublications}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onViewPublications,
                    child: Text(
                      s.viewPublications,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum JournalSortOption { mostPublications, alphabetical }

Future<JournalSortOption?> showJournalSortSheet(
  BuildContext context,
  JournalSortOption current,
) {
  return showModalBottomSheet<JournalSortOption>(
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
                s.sortJournals,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            RadioListTile<JournalSortOption>(
              title: Text(s.mostPublications),
              value: JournalSortOption.mostPublications,
              groupValue: current,
              activeColor: AppColors.secondary,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            RadioListTile<JournalSortOption>(
              title: Text(s.sortAlphabetical),
              value: JournalSortOption.alphabetical,
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

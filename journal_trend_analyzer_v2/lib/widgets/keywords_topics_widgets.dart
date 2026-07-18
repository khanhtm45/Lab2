import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../models/openalex_ranked_entity.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import 'app_logo.dart';

class KeywordCloudCard extends StatelessWidget {
  final List<OpenAlexRankedEntity> keywords;

  const KeywordCloudCard({super.key, required this.keywords});

  static const _tagColors = [
    AppColors.secondary,
    AppColors.analyticsTeal,
    Color(0xFF6366F1),
    Color(0xFF0D9488),
    Color(0xFF818CF8),
    Color(0xFF2DD4BF),
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (keywords.isEmpty) {
      return PremiumCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            s.noKeywordsForTopic,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final maxCount = keywords.first.count.toDouble();

    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: keywords.asMap().entries.map((entry) {
          final index = entry.key;
          final keyword = entry.value;
          final ratio = keyword.count / maxCount;
          final fontSize = 12.0 + (ratio * 7);
          final color = _tagColors[index % _tagColors.length];

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 + ratio * 4,
              vertical: 7 + ratio * 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Text(
              keyword.name,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: ratio >= 0.75
                    ? FontWeight.w700
                    : ratio >= 0.45
                        ? FontWeight.w600
                        : FontWeight.w500,
                color: color,
                height: 1.2,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

IconData topicIconFor(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('learning') || lower.contains('neural')) {
    return Icons.model_training_outlined;
  }
  if (lower.contains('vision') || lower.contains('image')) {
    return Icons.visibility_outlined;
  }
  if (lower.contains('language') || lower.contains('nlp')) {
    return Icons.translate_rounded;
  }
  if (lower.contains('ethic') || lower.contains('fairness')) {
    return Icons.balance_rounded;
  }
  if (lower.contains('health') || lower.contains('medical')) {
    return Icons.health_and_safety_outlined;
  }
  if (lower.contains('robot')) return Icons.precision_manufacturing_outlined;
  if (lower.contains('data')) return Icons.storage_rounded;
  if (lower.contains('security')) return Icons.shield_outlined;
  return Icons.hub_outlined;
}

class TopicRankListCard extends StatelessWidget {
  final int rank;
  final OpenAlexRankedEntity topic;
  final double progress;
  final VoidCallback onTap;

  const TopicRankListCard({
    super.key,
    required this.rank,
    required this.topic,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = rank.isOdd ? AppColors.secondary : AppColors.analyticsTeal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                topicIconFor(topic.name),
                size: 18,
                color: barColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
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
                    '${formatOpenAlexCount(topic.count)} publications',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.06, 1.0),
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      color: barColor,
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

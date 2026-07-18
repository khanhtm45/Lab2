import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

class HomeScreenAppBar extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeScreenAppBar({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 12, 12, 4),
      child: Row(
        children: [
          JournalTrendIconMark(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.strings.appTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
            ),
          ),
          Material(
            color: palette.surfaceMuted,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: palette.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onFilterTap;
  final bool filtersActive;

  const HomeSearchBar({
    super.key,
    required this.onTap,
    required this.onFilterTap,
    this.filtersActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppDimens.cardShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.strings.searchHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              Material(
                color: filtersActive
                    ? AppColors.secondary.withValues(alpha: 0.1)
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onFilterTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: filtersActive ? AppColors.secondary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopicPillChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  const TopicPillChip({
    super.key,
    required this.label,
    this.onTap,
    this.accentColor,
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            14,
            9,
            onBookmarkTap != null ? 4 : 14,
            9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isBookmarked
                  ? AppColors.secondary.withValues(alpha: 0.45)
                  : color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (onBookmarkTap != null) ...[
                const SizedBox(width: 2),
                InkWell(
                  onTap: onBookmarkTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 16,
                      color: isBookmarked ? AppColors.secondary : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RecentSearchCard extends StatelessWidget {
  final String topic;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  const RecentSearchCard({
    super.key,
    required this.topic,
    required this.timeLabel,
    required this.onTap,
    required this.onDelete,
    this.isBookmarked = false,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          if (onBookmark != null)
            IconButton(
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 18,
              ),
              color: isBookmarked ? AppColors.secondary : AppColors.textTertiary,
              onPressed: onBookmark,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.textTertiary,
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class QuickInsightMiniCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const QuickInsightMiniCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: accentColor),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class DashboardEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const DashboardEntryCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.strings.researchDashboard,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.strings.chartsGrowthInsights,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

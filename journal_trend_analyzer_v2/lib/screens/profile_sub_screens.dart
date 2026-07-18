import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/recent_search_entry.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

/// Recent searches management from Profile settings.
class RecentSearchesScreen extends StatelessWidget {
  const RecentSearchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final recents = provider.recentSearches;
    final s = context.strings;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.recentSearchesMenu,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (recents.isNotEmpty)
            TextButton(
              onPressed: () async {
                await provider.clearRecentSearches();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.recentSearchesCleared)),
                  );
                }
              },
              child: Text(s.clearAll),
            ),
        ],
      ),
      body: recents.isEmpty
          ? Center(
              child: Text(
                s.noRecentSearchesYet,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: recents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = recents[index];
                return _RecentSearchTile(entry: entry);
              },
            ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  final RecentSearchEntry entry;

  const _RecentSearchTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.topic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.relativeTimeLabelFor(s),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.textTertiary,
            onPressed: () =>
                context.read<PublicationProvider>().removeRecentSearch(
                      entry.topic,
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 22),
            color: AppColors.textTertiary,
            onPressed: () async {
              context.read<AppNavigationProvider>().goToTab(1);
              await context
                  .read<PublicationProvider>()
                  .searchPublications(entry.topic);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

enum ProfileInfoType { about, privacy, aiCodeReview }

/// Static information pages linked from Profile.
class ProfileInfoScreen extends StatelessWidget {
  final ProfileInfoType type;

  const ProfileInfoScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final data = _contentFor(type, s);

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          data.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.leadingIcon != null) ...[
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.leadingIcon, color: data.accent, size: 22),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  data.heading,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...data.paragraphs.map(
                  (paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      paragraph,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static _InfoContent _contentFor(ProfileInfoType type, AppStrings s) {
    return switch (type) {
      ProfileInfoType.about => _InfoContent(
          title: s.aboutApplication,
          heading: s.appTitle,
          leadingIcon: Icons.menu_book_rounded,
          accent: AppColors.primary,
          paragraphs: [
            s.aboutParagraph1,
            s.aboutParagraph2,
            s.labVersionFooter,
          ],
        ),
      ProfileInfoType.privacy => _InfoContent(
          title: s.privacyAndDataSource,
          heading: s.yourDataAndOpenAlex,
          leadingIcon: Icons.shield_outlined,
          accent: AppColors.analyticsTeal,
          paragraphs: [
            s.privacyParagraph1,
            s.privacyParagraph2,
            s.privacyParagraph3,
          ],
        ),
      ProfileInfoType.aiCodeReview => _InfoContent(
          title: s.aiCodeReviewReport,
          heading: s.developmentReviewNotes,
          leadingIcon: Icons.auto_awesome_outlined,
          accent: AppColors.secondary,
          paragraphs: [
            s.aiReviewParagraph1,
            s.aiReviewParagraph2,
            s.aiReviewParagraph3,
          ],
        ),
    };
  }
}

class _InfoContent {
  final String title;
  final String heading;
  final IconData? leadingIcon;
  final Color accent;
  final List<String> paragraphs;

  const _InfoContent({
    required this.title,
    required this.heading,
    this.leadingIcon,
    required this.accent,
    required this.paragraphs,
  });
}

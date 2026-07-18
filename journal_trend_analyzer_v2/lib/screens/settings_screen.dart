import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/search_filters.dart';
import '../providers/publication_provider.dart';
import '../services/app_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_widgets.dart';

/// App settings — appearance, language, search and data preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();
    final provider = context.watch<PublicationProvider>();
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
          s.settings,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SettingsSectionCard(
            title: s.appearance,
            children: [
              SettingsRadioTile<AppAppearance>(
                title: s.lightMode,
                value: AppAppearance.light,
                groupValue: prefs.appearance,
                onChanged: (value) {
                  if (value != null) prefs.setAppearance(value);
                },
              ),
              SettingsRadioTile<AppAppearance>(
                title: s.darkMode,
                value: AppAppearance.dark,
                groupValue: prefs.appearance,
                onChanged: (value) {
                  if (value != null) prefs.setAppearance(value);
                },
              ),
              SettingsRadioTile<AppAppearance>(
                title: s.systemDefault,
                value: AppAppearance.system,
                groupValue: prefs.appearance,
                showDivider: false,
                onChanged: (value) {
                  if (value != null) prefs.setAppearance(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsSectionCard(
            title: s.languageSection,
            children: [
              SettingsRadioTile<AppLanguage>(
                title: s.english,
                value: AppLanguage.english,
                groupValue: prefs.language,
                onChanged: (value) {
                  if (value != null) prefs.setLanguage(value);
                },
              ),
              SettingsRadioTile<AppLanguage>(
                title: s.vietnamese,
                value: AppLanguage.vietnamese,
                groupValue: prefs.language,
                showDivider: false,
                onChanged: (value) {
                  if (value != null) prefs.setLanguage(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsSectionCard(
            title: s.searchPreferences,
            children: [
              SettingsDropdownField<int>(
                label: s.resultsPerPage,
                value: prefs.resultsPerPage,
                options: const [10, 20, 50],
                labelBuilder: (v) => '$v',
                onChanged: (value) {
                  if (value != null) prefs.setResultsPerPage(value);
                },
              ),
              SettingsDropdownField<SearchSortOption>(
                label: s.defaultSort,
                value: prefs.defaultSort,
                options: SearchSortOption.values,
                labelBuilder: (v) => v.labelFor(s),
                onChanged: (value) {
                  if (value != null) {
                    prefs.setDefaultSort(value);
                    provider.updateSearchSort(value);
                  }
                },
              ),
              SettingsDropdownField<AppTrendRange>(
                label: s.defaultTrendPeriod,
                value: prefs.trendRange,
                options: AppTrendRange.values,
                labelBuilder: (v) => switch (v) {
                  AppTrendRange.fiveYears => s.fiveYears,
                  AppTrendRange.sevenYears => s.sevenYears,
                  AppTrendRange.allTime => s.allTime,
                },
                showDivider: false,
                onChanged: (value) {
                  if (value != null) prefs.setTrendRange(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsSectionCard(
            title: s.dataPreferences,
            children: [
              SettingsSwitchTile(
                title: s.saveRecentSearches,
                subtitle: s.saveRecentSearchesSubtitle,
                value: prefs.saveRecentSearches,
                onChanged: prefs.setSaveRecentSearches,
              ),
              SettingsActionButton(
                label: s.clearSearchHistory,
                color: AppColors.error,
                onPressed: () => _confirmClearHistory(context, provider),
              ),
              SettingsActionButton(
                label: s.clearLocalCache,
                color: AppColors.primary,
                showDivider: false,
                onPressed: () => _confirmClearCache(context, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    PublicationProvider provider,
  ) async {
    final s = context.stringsOf;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearSearchHistoryTitle),
        content: Text(s.clearSearchHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.clear),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await provider.clearRecentSearches();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.searchHistoryCleared)),
    );
  }

  Future<void> _confirmClearCache(
    BuildContext context,
    PublicationProvider provider,
  ) async {
    final s = context.stringsOf;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearLocalCacheTitle),
        content: Text(s.clearLocalCacheBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.clear),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await provider.clearLocalCache();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.localCacheCleared)),
    );
  }
}

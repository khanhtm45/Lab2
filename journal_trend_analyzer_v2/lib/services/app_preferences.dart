import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_filters.dart';

enum AppAppearance { system, light, dark }

enum AppLanguage { english, vietnamese }

enum AppTrendRange { fiveYears, sevenYears, allTime }

/// User-facing app preferences persisted on device.
class AppPreferences extends ChangeNotifier {
  static const appearanceKey = 'app_appearance';
  static const languageKey = 'app_language';
  static const resultsPerPageKey = 'app_results_per_page';
  static const trendRangeKey = 'app_trend_range';
  static const defaultSortKey = 'app_default_sort';
  static const saveRecentSearchesKey = 'app_save_recent_searches';

  AppAppearance appearance = AppAppearance.system;
  AppLanguage language = AppLanguage.english;
  int resultsPerPage = 20;
  AppTrendRange trendRange = AppTrendRange.sevenYears;
  SearchSortOption defaultSort = SearchSortOption.mostCited;
  bool saveRecentSearches = true;

  ThemeMode get themeMode => switch (appearance) {
        AppAppearance.light => ThemeMode.light,
        AppAppearance.dark => ThemeMode.dark,
        AppAppearance.system => ThemeMode.system,
      };

  String get appearanceLabel => switch (appearance) {
        AppAppearance.system => 'System Default',
        AppAppearance.light => 'Light Mode',
        AppAppearance.dark => 'Dark Mode',
      };

  String get languageLabel => switch (language) {
        AppLanguage.english => 'English',
        AppLanguage.vietnamese => 'Vietnamese',
      };

  String get trendRangeLabel => switch (trendRange) {
        AppTrendRange.fiveYears => '5 Years',
        AppTrendRange.sevenYears => '7 Years',
        AppTrendRange.allTime => 'All Time',
      };

  String get defaultSortLabel => defaultSort.label;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    appearance = AppAppearance.values[
      (prefs.getInt(appearanceKey) ?? AppAppearance.system.index)
          .clamp(0, AppAppearance.values.length - 1)
    ];
    language = AppLanguage.values[
      (prefs.getInt(languageKey) ?? AppLanguage.english.index)
          .clamp(0, AppLanguage.values.length - 1)
    ];
    resultsPerPage = prefs.getInt(resultsPerPageKey) ?? 20;
    if (![10, 20, 50].contains(resultsPerPage)) {
      resultsPerPage = 20;
    }
    trendRange = AppTrendRange.values[
      (prefs.getInt(trendRangeKey) ?? AppTrendRange.sevenYears.index)
          .clamp(0, AppTrendRange.values.length - 1)
    ];
    final sortIndex = prefs.getInt(defaultSortKey) ?? SearchSortOption.mostCited.index;
    defaultSort = SearchSortOption.values[
      sortIndex.clamp(0, SearchSortOption.values.length - 1)
    ];
    saveRecentSearches = prefs.getBool(saveRecentSearchesKey) ?? true;
    notifyListeners();
  }

  Future<void> setAppearance(AppAppearance value) async {
    appearance = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(appearanceKey, value.index);
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(languageKey, value.index);
  }

  Future<void> setResultsPerPage(int value) async {
    resultsPerPage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(resultsPerPageKey, value);
  }

  Future<void> setTrendRange(AppTrendRange value) async {
    trendRange = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(trendRangeKey, value.index);
  }

  Future<void> setDefaultSort(SearchSortOption value) async {
    defaultSort = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(defaultSortKey, value.index);
  }

  Future<void> setSaveRecentSearches(bool value) async {
    saveRecentSearches = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(saveRecentSearchesKey, value);
  }

  Future<void> resetToDefaults() async {
    appearance = AppAppearance.system;
    language = AppLanguage.english;
    resultsPerPage = 20;
    trendRange = AppTrendRange.sevenYears;
    defaultSort = SearchSortOption.mostCited;
    saveRecentSearches = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(appearanceKey);
    await prefs.remove(languageKey);
    await prefs.remove(resultsPerPageKey);
    await prefs.remove(trendRangeKey);
    await prefs.remove(defaultSortKey);
    await prefs.remove(saveRecentSearchesKey);
  }
}

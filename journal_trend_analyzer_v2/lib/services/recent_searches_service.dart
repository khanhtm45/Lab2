import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_search_entry.dart';

/// Persists recent search topics on device.
class RecentSearchesService {
  static const String storageKey = 'recent_search_topics';
  static const int maxItems = 8;

  Future<List<RecentSearchEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? [];
    return raw.map(RecentSearchEntry.decode).toList();
  }

  Future<List<RecentSearchEntry>> add(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(storageKey) ?? [];
    final existing = current.map(RecentSearchEntry.decode).toList();

    final updated = [
      RecentSearchEntry(topic: trimmed, searchedAt: DateTime.now()),
      ...existing.where(
        (item) => item.topic.toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(maxItems).toList();

    await prefs.setStringList(
      storageKey,
      updated.map((e) => e.encode()).toList(),
    );
    return updated;
  }

  Future<List<RecentSearchEntry>> remove(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(storageKey) ?? [];
    final updated = current
        .map(RecentSearchEntry.decode)
        .where((item) => item.topic.toLowerCase() != trimmed.toLowerCase())
        .map((e) => e.encode())
        .toList();

    await prefs.setStringList(storageKey, updated);
    return updated.map(RecentSearchEntry.decode).toList();
  }

  Future<List<RecentSearchEntry>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
    return [];
  }
}

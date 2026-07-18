import 'package:shared_preferences/shared_preferences.dart';

/// Persists favorite research topics on device.
class BookmarkedTopicsService {
  static const String storageKey = 'bookmarked_topics';
  static const int maxItems = 12;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(storageKey) ?? [];
  }

  Future<List<String>> toggle(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(storageKey) ?? [];
    final lower = trimmed.toLowerCase();
    final exists = current.any((t) => t.toLowerCase() == lower);

    final updated = exists
        ? current.where((t) => t.toLowerCase() != lower).toList()
        : [trimmed, ...current].take(maxItems).toList();

    await prefs.setStringList(storageKey, updated);
    return updated;
  }

  Future<List<String>> remove(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(storageKey) ?? [];
    final updated = current
        .where((t) => t.toLowerCase() != trimmed.toLowerCase())
        .toList();

    await prefs.setStringList(storageKey, updated);
    return updated;
  }

  Future<List<String>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
    return [];
  }

  bool isBookmarked(List<String> topics, String topic) {
    final lower = topic.trim().toLowerCase();
    return topics.any((t) => t.toLowerCase() == lower);
  }
}

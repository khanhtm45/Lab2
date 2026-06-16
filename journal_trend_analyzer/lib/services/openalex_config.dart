import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình OpenAlex API key — dùng chung cho mọi request HTTP.
///
/// Thứ tự ưu tiên:
///   1. Key user nhập ở About → SharedPreferences
///   2. Key build qua `--dart-define-from-file=dart_defines.json`
class OpenAlexConfig extends ChangeNotifier {
  static const String storageKey = 'openalex_api_key';

  static const String compileTimeKey =
      String.fromEnvironment('OPENALEX_API_KEY');

  String _savedKey = '';

  String get apiKey {
    if (_savedKey.isNotEmpty) return _savedKey;
    return compileTimeKey;
  }

  bool get hasKey => apiKey.isNotEmpty;
  bool get hasSavedKey => _savedKey.isNotEmpty;
  bool get hasCompileTimeKey => compileTimeKey.isNotEmpty;

  String get keySourceLabel {
    if (hasSavedKey) return 'Saved in app';
    if (hasCompileTimeKey) return 'Build config';
    return 'Not configured';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedKey = prefs.getString(storageKey)?.trim() ?? '';
    notifyListeners();
  }

  Future<void> saveKey(String key) async {
    final trimmed = key.trim();
    final prefs = await SharedPreferences.getInstance();

    if (trimmed.isEmpty) {
      await prefs.remove(storageKey);
      _savedKey = '';
    } else {
      await prefs.setString(storageKey, trimmed);
      _savedKey = trimmed;
    }

    notifyListeners();
  }

  Future<void> clearSavedKey() => saveKey('');
}

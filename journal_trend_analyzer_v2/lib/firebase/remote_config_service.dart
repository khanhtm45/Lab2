import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_config.dart';

/// Firebase Remote Config service for dynamic configuration
class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseConfig.remoteConfig;
  static final FirebaseCrashlytics _crashlytics = FirebaseConfig.crashlytics;

  /// Initialize Remote Config with default values
  static Future<void> initialize() async {
    try {
      // Set default values
      await _remoteConfig.setDefaults({
        'max_journals': 10,
        'max_keywords': 15,
        'app_version': '1.0.0',
        'theme': 'light',
        'enable_analytics': true,
        'api_timeout_seconds': 30,
        'max_search_results': 50,
      });

      // Set config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Remote Config initialization failed',
      );
    }
  }

  /// Fetch latest config values
  static Future<bool> fetchConfig() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Remote Config fetch failed',
      );
      return false;
    }
  }

  /// Get maximum number of journals to display
  static int getMaxJournals() {
    return _remoteConfig.getInt('max_journals');
  }

  /// Get maximum number of keywords to display
  static int getMaxKeywords() {
    return _remoteConfig.getInt('max_keywords');
  }

  /// Get app version
  static String getAppVersion() {
    return _remoteConfig.getString('app_version');
  }

  /// Get theme setting
  static String getTheme() {
    return _remoteConfig.getString('theme');
  }

  /// Check if analytics is enabled
  static bool isAnalyticsEnabled() {
    return _remoteConfig.getBool('enable_analytics');
  }

  /// Get API timeout in seconds
  static int getApiTimeoutSeconds() {
    return _remoteConfig.getInt('api_timeout_seconds');
  }

  /// Get maximum search results
  static int getMaxSearchResults() {
    return _remoteConfig.getInt('max_search_results');
  }

  /// Get all config values as Map
  static Map<String, dynamic> getAllConfig() {
    return {
      'max_journals': getMaxJournals(),
      'max_keywords': getMaxKeywords(),
      'app_version': getAppVersion(),
      'theme': getTheme(),
      'enable_analytics': isAnalyticsEnabled(),
      'api_timeout_seconds': getApiTimeoutSeconds(),
      'max_search_results': getMaxSearchResults(),
    };
  }

  /// Check if a feature is enabled
  static bool isFeatureEnabled(String featureName) {
    return _remoteConfig.getBool('feature_$featureName');
  }

  /// Get string config value
  static String getStringConfig(String key, {String defaultValue = ''}) {
    return _remoteConfig.getString(key).isEmpty ? defaultValue : _remoteConfig.getString(key);
  }

  /// Get int config value
  static int getIntConfig(String key, {int defaultValue = 0}) {
    final value = _remoteConfig.getInt(key);
    return value == 0 ? defaultValue : value;
  }

  /// Get bool config value
  static bool getBoolConfig(String key, {bool defaultValue = false}) {
    return _remoteConfig.getBool(key);
  }
}
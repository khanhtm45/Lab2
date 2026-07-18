import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_config.dart';

/// Firebase Analytics service for tracking user events
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseConfig.analytics;

  /// Track login event
  static Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'google');
  }

  /// Track logout event
  static Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  /// Track search topic event
  static Future<void> logSearchTopic(String keyword) async {
    await _analytics.logEvent(
      name: 'search_topic',
      parameters: {'keyword': keyword},
    );
  }

  /// Track view publication event
  static Future<void> logViewPublication({
    required String publicationTitle,
    required int publicationYear,
  }) async {
    await _analytics.logEvent(
      name: 'view_publication',
      parameters: {
        'publication_title': publicationTitle,
        'publication_year': publicationYear,
      },
    );
  }

  /// Track view journal event
  static Future<void> logViewJournal(String journalName) async {
    await _analytics.logEvent(
      name: 'view_journal',
      parameters: {'journal_name': journalName},
    );
  }

  /// Track view keyword event
  static Future<void> logViewKeyword(String keyword) async {
    await _analytics.logEvent(
      name: 'view_keyword',
      parameters: {'keyword': keyword},
    );
  }

  /// Track export PDF event
  static Future<void> logExportPdf(String topic) async {
    await _analytics.logEvent(
      name: 'export_pdf',
      parameters: {'topic': topic},
    );
  }

  /// Track custom event
  static Future<void> logCustomEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? researchField,
    String? institution,
    String? userType,
  }) async {
    if (researchField != null) {
      await _analytics.setUserProperty(
        name: 'research_field',
        value: researchField,
      );
    }
    if (institution != null) {
      await _analytics.setUserProperty(
        name: 'institution',
        value: institution,
      );
    }
    if (userType != null) {
      await _analytics.setUserProperty(
        name: 'user_type',
        value: userType,
      );
    }
  }

  /// Enable/disable analytics collection
  static Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }
}
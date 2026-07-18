import '../firebase/analytics_service.dart';

/// Helper class for Firebase Analytics events specific to the Journal Trend Analyzer
class FirebaseAnalyticsHelper {
  /// Track search actions with specific parameters
  static Future<void> trackSearch({
    required String searchType,
    required String query,
    String? category,
    int? resultCount,
  }) async {
    final Map<String, Object> params = {
      'search_type': searchType,
      'query': query,
    };
    if (category != null) params['category'] = category;
    if (resultCount != null) params['result_count'] = resultCount;
    
    await AnalyticsService.logCustomEvent('search_performed', parameters: params);
  }

  /// Track navigation events
  static Future<void> trackNavigation({
    required String screenName,
    String? previousScreen,
  }) async {
    await AnalyticsService.logCustomEvent(
      'screen_view',
      parameters: {
        'screen_name': screenName,
        if (previousScreen != null) 'previous_screen': previousScreen,
      },
    );
  }

  /// Track user engagement with publications
  static Future<void> trackPublicationEngagement({
    required String action,
    required String publicationId,
    String? publicationTitle,
    String? journalName,
  }) async {
    await AnalyticsService.logCustomEvent(
      'publication_engagement',
      parameters: {
        'action': action,
        'publication_id': publicationId,
        if (publicationTitle != null) 'publication_title': publicationTitle,
        if (journalName != null) 'journal_name': journalName,
      },
    );
  }

  /// Track filter usage
  static Future<void> trackFilterUsage({
    required String filterType,
    required String filterValue,
    String? screen,
  }) async {
    await AnalyticsService.logCustomEvent(
      'filter_applied',
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
        if (screen != null) 'screen': screen,
      },
    );
  }

  /// Track export/share actions
  static Future<void> trackExportAction({
    required String exportType,
    required String format,
    String? topic,
  }) async {
    await AnalyticsService.logCustomEvent(
      'content_exported',
      parameters: {
        'export_type': exportType,
        'format': format,
        if (topic != null) 'topic': topic,
      },
    );
  }

  /// Track user preferences
  static Future<void> trackPreferenceChange({
    required String preferenceType,
    required String value,
  }) async {
    await AnalyticsService.logCustomEvent(
      'preference_changed',
      parameters: {
        'preference_type': preferenceType,
        'value': value,
      },
    );
  }

  /// Track error events
  static Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? screen,
  }) async {
    await AnalyticsService.logCustomEvent(
      'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (screen != null) 'screen': screen,
      },
    );
  }
}
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_config.dart';

/// Firebase Crashlytics service for crash monitoring and error reporting
class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseConfig.crashlytics;

  /// Initialize Crashlytics
  static Future<void> initialize() async {
    // Enable crash collection in debug mode for testing
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Record a non-fatal error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<Object> information = const [],
    bool printDetails = true,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      information: information,
      printDetails: printDetails,
      fatal: fatal,
    );
  }

  /// Record a custom error with context
  static Future<void> recordCustomError(
    String title,
    String message, {
    Map<String, String>? additionalData,
  }) async {
    final exception = CustomException(title, message, additionalData);
    await _crashlytics.recordError(
      exception,
      StackTrace.current,
      reason: title,
    );
  }

  /// Set user identifier
  static Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  /// Set custom key-value pairs
  static Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Set custom keys from map
  static Future<void> setCustomKeys(Map<String, Object> data) async {
    for (final entry in data.entries) {
      await _crashlytics.setCustomKey(entry.key, entry.value);
    }
  }

  /// Log a message
  static void log(String message) {
    _crashlytics.log(message);
  }

  /// Generate a test crash (for testing purposes)
  static void generateTestCrash() {
    _crashlytics.crash();
  }

  /// Generate a handled exception (for testing purposes)
  static Future<void> generateTestException() async {
    try {
      throw Exception('This is a test exception for Crashlytics');
    } catch (e, stackTrace) {
      await recordError(
        e,
        stackTrace,
        reason: 'Test exception generated from Crashlytics demo',
      );
    }
  }

  /// Check if crash reporting is enabled
  static Future<bool> isCrashlyticsCollectionEnabled() async {
    try {
      return _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Enable/disable crash collection
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Add breadcrumb for tracking user actions
  static void addBreadcrumb(String message, {Map<String, String>? data}) {
    final breadcrumb = StringBuffer(message);
    if (data != null && data.isNotEmpty) {
      breadcrumb.write(' - Data: ${data.toString()}');
    }
    log(breadcrumb.toString());
  }

  /// Record API call for debugging
  static void recordApiCall(String endpoint, {String? method, int? statusCode}) {
    setCustomKeys({
      'last_api_endpoint': endpoint,
      'last_api_method': method ?? 'GET',
      'last_api_status': statusCode ?? 0,
      'last_api_time': DateTime.now().toIso8601String(),
    });
    log('API Call: $method $endpoint - Status: $statusCode');
  }

  /// Record user action
  static void recordUserAction(String action, {Map<String, String>? context}) {
    addBreadcrumb('User Action: $action', data: context);
  }

  /// Record screen view
  static void recordScreenView(String screenName) {
    addBreadcrumb('Screen View: $screenName');
    setCustomKey('current_screen', screenName);
  }
}

/// Custom exception class for better error reporting
class CustomException implements Exception {
  final String title;
  final String message;
  final Map<String, String>? additionalData;

  CustomException(this.title, this.message, [this.additionalData]);

  @override
  String toString() {
    final buffer = StringBuffer('$title: $message');
    if (additionalData != null && additionalData!.isNotEmpty) {
      buffer.write('\nAdditional Data: ${additionalData.toString()}');
    }
    return buffer.toString();
  }
}
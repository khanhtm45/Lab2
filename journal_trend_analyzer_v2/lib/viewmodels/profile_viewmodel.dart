import 'package:flutter/foundation.dart';
import 'dart:math';
import '../firebase/remote_config_service.dart';
import '../firebase/storage_service.dart';
import '../firebase/messaging_service.dart';
import '../firebase/crashlytics_service.dart';
import '../firebase/analytics_service.dart';
import '../services/pdf_service.dart';

/// ViewModel for profile-related operations
class ProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  Map<String, dynamic> _remoteConfigValues = {};
  List<NotificationMessage> _notifications = [];
  List<String> _uploadedFiles = [];
  bool _isExportingPdf = false;

  /// Mock Firebase data for demonstration
  final List<String> _mockUploadedFiles = [
    'research_report_2024_12_15.pdf',
    'ai_analysis_november.pdf',
    'machine_learning_trends_2024.pdf',
  ];

  /// Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Map<String, dynamic> get remoteConfigValues => _remoteConfigValues;
  List<NotificationMessage> get notifications => _notifications;
  List<String> get uploadedFiles => _uploadedFiles;
  bool get isExportingPdf => _isExportingPdf;
  int get unreadNotificationCount => MessagingService.getUnreadCount();

  ProfileViewModel() {
    _initializeProfile();
  }

  /// Initialize profile data
  void _initializeProfile() {
    _loadRemoteConfigValues();
    _loadNotifications();
    _loadUploadedFiles();

    // Listen to notification changes
    MessagingService.notificationsNotifier.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    MessagingService.notificationsNotifier.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  /// Handle notification changes
  void _onNotificationsChanged() {
    _notifications = MessagingService.getNotifications();
    notifyListeners();
  }

  /// Load Remote Config values with mock data fallback
  Future<void> _loadRemoteConfigValues() async {
    try {
      // Try to fetch from Firebase
      await RemoteConfigService.fetchConfig();
      _remoteConfigValues = RemoteConfigService.getAllConfig();
      
      // If empty, use mock data
      if (_remoteConfigValues.isEmpty) {
        _remoteConfigValues = _getMockRemoteConfig();
      }
      
      notifyListeners();
    } catch (e) {
      // On error, use mock data
      _remoteConfigValues = _getMockRemoteConfig();
      notifyListeners();
      
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'Load remote config failed, using mock data',
      );
    }
  }

  /// Get mock remote config data
  Map<String, dynamic> _getMockRemoteConfig() {
    return {
      'max_journals': 20,
      'max_keywords': 25,
      'app_version': '1.2.0',
      'theme': 'modern',
      'enable_notifications': true,
      'cache_duration_hours': 24,
      'max_search_results': 100,
      'enable_analytics': true,
    };
  }

  /// Load notifications
  void _loadNotifications() {
    _notifications = MessagingService.getNotifications();
    notifyListeners();
  }

  /// Load uploaded files list with mock data fallback
  Future<void> _loadUploadedFiles() async {
    try {
      // Try to load from Firebase Storage
      final files = await StorageService.listUserFiles();
      _uploadedFiles = files.map((ref) => ref.name).toList();
      
      // If empty, use mock data
      if (_uploadedFiles.isEmpty) {
        _uploadedFiles = List<String>.from(_mockUploadedFiles);
      }
      
      notifyListeners();
    } catch (e) {
      // On error, use mock data
      _uploadedFiles = List<String>.from(_mockUploadedFiles);
      notifyListeners();
      
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'Load uploaded files failed, using mock data',
      );
    }
  }

  /// Export PDF report with MOCK/FAKE upload simulation
  Future<String?> exportPdfReport({
    String? topic,
    Map<String, dynamic>? analyticsData,
  }) async {
    try {
      _setExportLoading(true);
      _clearMessages();

      CrashlyticsService.recordUserAction('Started PDF Export (Mock)', 
        context: {'topic': topic ?? 'unknown'});

      // Simulate file picking delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate upload progress
      await Future.delayed(const Duration(milliseconds: 1200));

      // Generate mock filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random();
      final fileTypes = ['research_report', 'analytics_summary', 'trend_analysis', 'keyword_report'];
      final fileType = fileTypes[random.nextInt(fileTypes.length)];
      final fileName = '${fileType}_$timestamp.pdf';

      // Try real upload if Firebase is configured
      try {
        final pdfBytes = await PdfService.generateResearchReport(
          title: 'Research Analytics Report',
          topic: topic ?? 'Dashboard Summary',
          data: analyticsData,
        );

        final downloadUrl = await StorageService.uploadPdfReport(
          pdfBytes: pdfBytes,
          fileName: fileName,
          topic: topic,
        );

        if (downloadUrl != null) {
          // Real upload succeeded
          _uploadedFiles.insert(0, fileName);
          _setSuccessMessage('✅ Report uploaded to Firebase Storage successfully!');
          await AnalyticsService.logExportPdf(topic ?? 'Unknown');
          notifyListeners();
          return downloadUrl;
        }
      } catch (firebaseError) {
        // Firebase upload failed, continue with mock
        debugPrint('Firebase upload failed, using mock: $firebaseError');
      }

      // MOCK SUCCESS - Add to uploaded files list
      _uploadedFiles.insert(0, fileName);
      
      // Generate mock download URL
      final mockUrl = 'https://firebasestorage.googleapis.com/mock/${fileName}';
      
      _setSuccessMessage('✅ Report "$fileName" uploaded successfully! (Mock)');
      
      // Log mock analytics event
      try {
        await AnalyticsService.logExportPdf(topic ?? 'Unknown');
      } catch (e) {
        debugPrint('Analytics logging failed: $e');
      }
      
      CrashlyticsService.recordUserAction('Successful PDF Export (Mock)', 
        context: {'fileName': fileName, 'mockUrl': mockUrl});

      notifyListeners();
      return mockUrl;
      
    } catch (e) {
      _setError('❌ Export failed: ${e.toString()}');
      
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'PDF export failed',
      );
      
      return null;
    } finally {
      _setExportLoading(false);
    }
  }

  /// Simulate file selection (mock file picker)
  Future<String?> mockSelectFile() async {
    try {
      _setLoading(true);
      
      // Simulate file picker dialog delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock file selection
      final random = Random();
      final fileNames = [
        'my_document.pdf',
        'research_paper.pdf',
        'analysis_report.pdf',
        'study_results.pdf',
      ];
      
      final selectedFile = fileNames[random.nextInt(fileNames.length)];
      
      _setSuccessMessage('📄 Selected: $selectedFile');
      return selectedFile;
      
    } catch (e) {
      _setError('File selection failed');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Mock upload any file
  Future<bool> mockUploadFile(String fileName) async {
    try {
      _setExportLoading(true);
      _clearMessages();
      
      // Simulate upload delay with progress
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Add timestamp to filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadedFileName = '${fileName.replaceAll('.pdf', '')}_$timestamp.pdf';
      
      // Add to uploaded files
      _uploadedFiles.insert(0, uploadedFileName);
      
      _setSuccessMessage('✅ "$fileName" uploaded successfully! (Mock)');
      
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('❌ Upload failed: ${e.toString()}');
      return false;
    } finally {
      _setExportLoading(false);
    }
  }

  /// Refresh remote config with mock data fallback
  Future<void> refreshRemoteConfig() async {
    try {
      _setLoading(true);
      _clearMessages();

      // Simulate refresh delay
      await Future.delayed(const Duration(milliseconds: 600));

      try {
        final success = await RemoteConfigService.fetchConfig();
        
        if (success) {
          _remoteConfigValues = RemoteConfigService.getAllConfig();
          
          // If still empty, use mock
          if (_remoteConfigValues.isEmpty) {
            _remoteConfigValues = _getMockRemoteConfig();
            _setSuccessMessage('✅ Remote Config updated (Mock Data)');
          } else {
            _setSuccessMessage('✅ Remote Config updated from Firebase');
          }
        } else {
          throw Exception('Failed to fetch config');
        }
      } catch (e) {
        // Use mock data on error
        _remoteConfigValues = _getMockRemoteConfig();
        _setSuccessMessage('✅ Remote Config loaded (Mock Data)');
      }
      
    } catch (e) {
      _remoteConfigValues = _getMockRemoteConfig();
      _setSuccessMessage('✅ Remote Config loaded (Mock Data)');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate test exception for Crashlytics
  Future<void> generateTestException() async {
    try {
      _clearMessages();
      
      CrashlyticsService.recordUserAction('Generated Test Exception');
      
      await CrashlyticsService.generateTestException();
      _setSuccessMessage('Test exception sent to Crashlytics');
    } catch (e) {
      _setError('Failed to generate test exception');
    }
  }

  /// Generate test crash for Crashlytics
  void generateTestCrash() {
    try {
      _clearMessages();
      
      CrashlyticsService.recordUserAction('Generated Test Crash');
      
      // This will crash the app
      CrashlyticsService.generateTestCrash();
    } catch (e) {
      _setError('Failed to generate test crash');
    }
  }

  /// Mark notification as read
  void markNotificationAsRead(String notificationId) {
    MessagingService.markAsRead(notificationId);
  }

  /// Clear all notifications
  void clearAllNotifications() {
    MessagingService.clearNotifications();
  }

  /// Add demo notifications for testing
  void addDemoNotifications() {
    MessagingService.addDemoNotifications();
    _setSuccessMessage('Demo notifications added');
  }

  /// Subscribe to notification topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await MessagingService.subscribeToTopic(topic);
      _setSuccessMessage('Subscribed to $topic notifications');
    } catch (e) {
      _setError('Failed to subscribe to topic: ${e.toString()}');
    }
  }

  /// Unsubscribe from notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await MessagingService.unsubscribeFromTopic(topic);
      _setSuccessMessage('Unsubscribed from $topic notifications');
    } catch (e) {
      _setError('Failed to unsubscribe from topic: ${e.toString()}');
    }
  }

  /// Get remote config value by key
  T getRemoteConfigValue<T>(String key, T defaultValue) {
    return _remoteConfigValues[key] ?? defaultValue;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set export loading state
  void _setExportLoading(bool loading) {
    _isExportingPdf = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    _successMessage = null;
    notifyListeners();
  }

  /// Set success message
  void _setSuccessMessage(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  /// Clear messages
  void _clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
}
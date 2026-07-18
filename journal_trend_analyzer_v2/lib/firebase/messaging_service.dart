import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'firebase_config.dart';

/// Firebase Cloud Messaging service for push notifications
class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseConfig.messaging;
  static final FirebaseCrashlytics _crashlytics = FirebaseConfig.crashlytics;

  /// List to store received notifications for display in Profile
  static final List<NotificationMessage> _notifications = [];
  static final ValueNotifier<List<NotificationMessage>> notificationsNotifier = 
      ValueNotifier<List<NotificationMessage>>(_notifications);

  /// Initialize messaging service
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      await requestPermission();

      // Get and store FCM token
      await getToken();

      // Set up message handlers
      await setupMessageHandlers();

    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Messaging service initialization failed',
      );
    }
  }

  /// Request notification permissions
  static Future<void> requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permission status: ${settings.authorizationStatus}');
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Request notification permission failed',
      );
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Get FCM token failed',
      );
      return null;
    }
  }

  /// Set up message handlers
  static Future<void> setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

    // Handle notification tap when app is terminated
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('Error getting initial message: $e');
    }
  }

  /// Handle foreground message
  static void handleForegroundMessage(RemoteMessage message) {
    try {
      print('Foreground message received: ${message.notification?.title}');
      
      // Add to notifications list
      final notification = NotificationMessage.fromRemoteMessage(message);
      _notifications.insert(0, notification); // Add to beginning of list
      
      // Limit to last 50 notifications
      if (_notifications.length > 50) {
        _notifications.removeRange(50, _notifications.length);
      }
      
      // Notify listeners
      notificationsNotifier.value = List.from(_notifications);

    } catch (e, stackTrace) {
      _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Handle foreground message failed',
      );
    }
  }

  /// Handle notification tap
  static void handleNotificationTap(RemoteMessage message) {
    try {
      print('Notification tapped: ${message.notification?.title}');
      
      // Handle navigation based on notification data
      final data = message.data;
      if (data.containsKey('screen')) {
        // Navigate to specific screen
        navigateToScreen(data['screen']);
      }

    } catch (e, stackTrace) {
      _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Handle notification tap failed',
      );
    }
  }

  /// Navigate to screen based on notification data
  static void navigateToScreen(String screen) {
    // This would typically use navigation service or global navigator key
    print('Navigate to screen: $screen');
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Subscribe to topic failed',
      );
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Unsubscribe from topic failed',
      );
    }
  }

  /// Get all notifications
  static List<NotificationMessage> getNotifications() {
    return List.from(_notifications);
  }

  /// Clear all notifications
  static void clearNotifications() {
    _notifications.clear();
    notificationsNotifier.value = [];
  }

  /// Mark notification as read
  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notificationsNotifier.value = List.from(_notifications);
    }
  }

  /// Get unread count
  static int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Add demo notifications for testing
  static void addDemoNotifications() {
    final demoNotifications = [
      NotificationMessage(
        id: 'demo_1',
        title: 'New Trending Research Topic',
        body: 'Artificial Intelligence research is trending in the academic community',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'trending_topic',
      ),
      NotificationMessage(
        id: 'demo_2',
        title: 'Highly Cited Publication Alert',
        body: 'A paper in your research area has received over 1000 citations',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'citation_alert',
      ),
      NotificationMessage(
        id: 'demo_3',
        title: 'Research Trend Updates',
        body: 'Weekly summary of research trends in Computer Science',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: 'trend_update',
      ),
    ];

    _notifications.insertAll(0, demoNotifications);
    notificationsNotifier.value = List.from(_notifications);
  }
}

/// Notification message model
class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;

  const NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'general',
    this.data = const {},
    this.isRead = false,
  });

  /// Create from Firebase RemoteMessage
  factory NotificationMessage.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'No Title',
      body: message.notification?.body ?? 'No Body',
      timestamp: DateTime.now(),
      type: message.data['type'] ?? 'general',
      data: message.data,
    );
  }

  /// Copy with new values
  NotificationMessage copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
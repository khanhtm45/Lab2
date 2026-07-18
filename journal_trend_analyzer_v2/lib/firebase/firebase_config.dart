import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

/// Firebase configuration and initialization
class FirebaseConfig {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  static FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
  static FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Crashlytics
    await _initializeCrashlytics();

    // Initialize Remote Config
    await _initializeRemoteConfig();

    // Initialize Messaging
    await _initializeMessaging();

    print('Firebase initialized successfully');
  }

  /// Initialize Firebase Crashlytics
  static Future<void> _initializeCrashlytics() async {
    // Enable crash collection in debug mode for testing
    await crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  /// Initialize Firebase Remote Config
  static Future<void> _initializeRemoteConfig() async {
    try {
      // Set default values
      await remoteConfig.setDefaults({
        'max_journals': 10,
        'max_keywords': 15,
        'app_version': '1.0.0',
        'theme': 'light',
      });

      // Fetch and activate remote config
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      // Handle error gracefully
      print('Remote Config initialization failed: $e');
    }
  }

  /// Initialize Firebase Cloud Messaging
  static Future<void> _initializeMessaging() async {
    try {
      // Request permission for iOS
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      String? token = await messaging.getToken();
      print('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.notification?.title}');
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      print('Firebase Messaging initialization failed: $e');
    }
  }
}

/// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
}
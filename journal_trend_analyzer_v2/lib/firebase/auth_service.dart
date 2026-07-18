import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_config.dart';

/// OAuth client IDs from `android/app/google-services.json`.
class FirebaseOAuthConfig {
  /// Web client ID (client_type: 3) — required for Google Sign-In idToken on Android.
  static const String googleWebClientId =
      '410013553610-fdso7d2f398v66kf0veoiu77lt7uk4jq.apps.googleusercontent.com';
}

/// Firebase Authentication service
class AuthService {
  static final FirebaseAuth _auth = FirebaseConfig.auth;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: FirebaseOAuthConfig.googleWebClientId,
  );
  static final FirebaseAnalytics _analytics = FirebaseConfig.analytics;
  static final FirebaseCrashlytics _crashlytics = FirebaseConfig.crashlytics;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message:
              'Google Sign-In did not return an idToken. Check Firebase OAuth client configuration.',
        );
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Set user identifier for Crashlytics
      await _crashlytics.setUserIdentifier(userCredential.user?.uid ?? '');

      // Log analytics event
      await _analytics.logLogin(loginMethod: 'google');

      return userCredential;
    } catch (e, stackTrace) {
      // Log error to Crashlytics
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Google Sign-In failed',
      );
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      // Log analytics event
      await _analytics.logEvent(name: 'logout');

      // Sign out from Google and Firebase
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e, stackTrace) {
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Sign out failed',
      );
      rethrow;
    }
  }

  /// Get user display name
  static String getUserDisplayName() {
    final user = currentUser;
    if (user == null) return 'Unknown User';
    
    return user.displayName ?? user.email?.split('@')[0] ?? 'Unknown User';
  }

  /// Get user email
  static String getUserEmail() {
    return currentUser?.email ?? 'No Email';
  }

  /// Get user photo URL
  static String? getUserPhotoUrl() {
    return currentUser?.photoURL;
  }

  /// Get Firebase UID
  static String getUserUid() {
    return currentUser?.uid ?? '';
  }
}
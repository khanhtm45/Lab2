import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/auth_service.dart';
import '../firebase/analytics_service.dart';
import '../firebase/crashlytics_service.dart';

/// ViewModel for authentication-related operations
class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  /// Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _currentUser != null;
  String? get error => _error;
  String get userDisplayName => AuthService.getUserDisplayName();
  String get userEmail => AuthService.getUserEmail();
  String? get userPhotoUrl => AuthService.getUserPhotoUrl();
  String get userUid => AuthService.getUserUid();

  AuthViewModel() {
    _initializeAuth();
  }

  /// Initialize authentication and listen to auth state changes
  void _initializeAuth() {
    _currentUser = AuthService.currentUser;
    
    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      CrashlyticsService.recordUserAction('Attempted Google Sign-In');

      final userCredential = await AuthService.signInWithGoogle();
      
      if (userCredential != null) {
        _currentUser = userCredential.user;
        
        // Log analytics event
        await AnalyticsService.logLogin();
        
        CrashlyticsService.recordUserAction('Successful Google Sign-In', 
          context: {'userId': _currentUser?.uid ?? 'unknown'});
        
        return true;
      } else {
        _setError('Sign-in was cancelled');
        return false;
      }
    } catch (e) {
      _setError('Sign-in failed: ${e.toString()}');
      
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'Google Sign-In failed',
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      CrashlyticsService.recordUserAction('Attempted Sign Out');

      await AuthService.signOut();
      
      // Log analytics event
      await AnalyticsService.logLogout();
      
      _currentUser = null;
      
      CrashlyticsService.recordUserAction('Successful Sign Out');
      
      return true;
    } catch (e) {
      _setError('Sign-out failed: ${e.toString()}');
      
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'Sign out failed',
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user profile
  Future<void> refreshUser() async {
    try {
      await _currentUser?.reload();
      _currentUser = AuthService.currentUser;
      notifyListeners();
    } catch (e) {
      CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'Refresh user failed',
      );
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if user has completed profile
  bool get hasCompleteProfile {
    if (_currentUser == null) return false;
    return _currentUser!.displayName != null && 
           _currentUser!.email != null;
  }

  /// Get user initials for avatar
  String getUserInitials() {
    final displayName = userDisplayName;
    if (displayName == 'Unknown User') return '?';
    
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
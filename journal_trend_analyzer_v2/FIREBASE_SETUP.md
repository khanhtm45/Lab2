# Firebase Setup Instructions

This document provides step-by-step instructions for setting up Firebase services for the Journal Trend Analyzer Lab 3 project.

## Prerequisites

- Flutter SDK installed
- Android Studio or VS Code
- Google account for Firebase Console access
- Node.js (for Firebase CLI)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" or "Add project"
3. Enter project name: `journal-trend-analyzer`
4. Enable Google Analytics (recommended)
5. Choose analytics account or create new one
6. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android icon
2. Enter Android package name: `com.example.journal_trend_analyzer`
3. Enter app nickname: `Journal Trend Analyzer Android`
4. Click "Register app"
5. Download `google-services.json`
6. Place the file in `android/app/` directory

## Step 3: Add iOS App (Optional)

1. Click "Add app" → iOS icon
2. Enter iOS bundle ID: `com.example.journalTrendAnalyzer`
3. Enter app nickname: `Journal Trend Analyzer iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Place the file in `ios/Runner/` directory

## Step 4: Configure Android Build Files

### Project-level `android/build.gradle`

Add to dependencies block:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:3.0.0'
}
```

### App-level `android/app/build.gradle`

Add plugins at the top:
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'dev.flutter.flutter-gradle-plugin'
    id 'com.google.gms.google-services'        // Add this line
    id 'com.google.firebase.crashlytics'        // Add this line
}
```

## Step 5: Enable Firebase Services

In Firebase Console, enable the following services:

### Authentication
1. Go to Authentication → Sign-in method
2. Enable "Google" provider
3. Enter project support email
4. Add SHA-1 fingerprint for Android:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Start in test mode
4. Choose location (closest to your users)

### Cloud Storage
1. Go to Storage
2. Click "Get started"
3. Start in test mode
4. Choose location

### Cloud Messaging
1. Go to Cloud Messaging
2. No additional setup required for basic functionality

### Analytics
1. Go to Analytics
2. Already enabled if chosen during project creation

### Crashlytics
1. Go to Crashlytics
2. Click "Set up Crashlytics"
3. Follow the setup instructions

### Remote Config
1. Go to Remote Config
2. Click "Create configuration"
3. Add parameters:
   - `max_journals` (Number): 10
   - `max_keywords` (Number): 15
   - `app_version` (String): "1.0.0"
   - `theme` (String): "light"

## Step 6: Install Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure FlutterFire (run in project root)
flutterfire configure
```

This will:
- Create/update `firebase_options.dart`
- Configure platform-specific settings
- Link your project to Firebase

## Step 7: Update Dependencies

Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  google_sign_in: ^6.2.1
  firebase_analytics: ^11.3.3
  firebase_crashlytics: ^4.1.3
  firebase_remote_config: ^5.1.3
  firebase_storage: ^12.3.2
  firebase_messaging: ^15.1.3
```

Then run:
```bash
flutter pub get
```

## Step 8: Configure Google Sign-In

### Android Configuration
1. In Firebase Console → Authentication → Sign-in method → Google
2. Download the updated `google-services.json`
3. Replace the file in `android/app/`

### SHA-1 Fingerprint
Add your debug and release SHA-1 fingerprints to Firebase:

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (when you create one)
keytool -list -v -keystore /path/to/my-release-key.keystore -alias my-key-alias
```

## Step 9: Test Firebase Integration

1. Run the app: `flutter run`
2. Check Firebase Console for:
   - Analytics events
   - Authentication users (when signing in)
   - Crashlytics reports (when generating test crashes)
   - Remote Config parameter fetches

## Step 10: Production Setup

For production builds:

1. Generate a signed APK keystore
2. Add release SHA-1 to Firebase Console
3. Update Firebase security rules for Firestore and Storage
4. Configure proper Cloud Messaging certificates for iOS
5. Set up proper Remote Config targeting

## Troubleshooting

### Common Issues

1. **GoogleService-Info.plist not found (iOS)**
   - Ensure file is in `ios/Runner/` directory
   - Add to Xcode project if needed

2. **google-services.json not found (Android)**
   - Ensure file is in `android/app/` directory
   - File must be valid JSON

3. **Google Sign-In fails**
   - Check SHA-1 fingerprints
   - Ensure Google provider is enabled
   - Verify package name matches Firebase configuration

4. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check build.gradle configurations
   - Ensure all Firebase services are properly enabled

5. **Crashlytics not receiving reports**
   - Ensure debug builds have Crashlytics enabled
   - Check internet connectivity
   - Force crash and wait a few minutes

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

## Support

If you encounter issues:
1. Check Firebase Console logs
2. Review Flutter and Firebase documentation
3. Check device/emulator internet connectivity
4. Verify all configuration files are in correct locations
# Journal Trend Analyzer - Lab 03 (Firebase Integration)

**PRM393 - Mobile Programming**  
**Lab 03: Firebase-Powered Journal Trend Analyzer**

## Overview

This project enhances the Journal Trend Analyzer application by integrating Firebase services, implementing MVVM architecture, automated testing with Patrol, and AI-assisted code review practices.

## 🔥 Firebase Services Integration

### Implemented Firebase Services

| Service | Purpose | Implementation |
|---------|---------|----------------|
| **Firebase Authentication** | Google Sign-In | `lib/firebase/auth_service.dart` |
| **Firebase Storage** | PDF report uploads | `lib/firebase/storage_service.dart` |
| **Firebase Cloud Messaging** | Push notifications | `lib/firebase/messaging_service.dart` |
| **Firebase Analytics** | User activity tracking | `lib/firebase/analytics_service.dart` |
| **Firebase Crashlytics** | Crash monitoring | `lib/firebase/crashlytics_service.dart` |
| **Firebase Remote Config** | Dynamic configuration | `lib/firebase/remote_config_service.dart` |

### Firebase Analytics Events

The app tracks the following events as required:

- `login` - User successfully signs in
- `search_topic` - User searches for a research topic
- `view_publication` - User opens a publication detail page
- `view_journal` - User opens a journal detail page
- `view_keyword` - User opens a keyword detail page
- `export_pdf` - User exports and uploads a PDF report
- `logout` - User signs out

## 🏗️ MVVM Architecture

The application follows the Model-View-ViewModel pattern:

```
lib/
├── models/           # Data models
├── services/         # Business logic services
├── firebase/         # Firebase service implementations
├── viewmodels/       # ViewModels (business logic)
├── screens/          # Views (UI screens)
├── widgets/          # Reusable UI components
└── utils/           # Utility functions
```

### Key ViewModels

- `AuthViewModel` - Handles authentication state and operations
- `ProfileViewModel` - Manages profile-related functionality and Firebase services

## 📱 Navigation Structure

The app uses a bottom navigation bar with 4 main sections:

1. **Home** - Dashboard and research overview
2. **Journals** - Journal search and analysis
3. **Keywords** - Keyword-based research analysis  
4. **Profile** - User management and Firebase services

## 🔒 Authentication Flow

1. **Splash Screen** - Checks authentication status
2. **Login Screen** - Google Sign-In or continue as guest
3. **Main App** - Full features available when authenticated
4. **Profile Screen** - Displays user info and Firebase features when signed in

## 📊 Profile Screen Features

### User Information
- Profile picture, name, email
- Firebase UID display
- Sign out functionality

### Notification Center
- Displays FCM notifications
- Demo notifications for testing
- Unread notification badges

### Report Export
- Generate PDF reports
- Upload to Firebase Storage
- Display uploaded file URLs

### Remote Config Demo
- Maximum journals displayed
- Maximum keywords displayed
- App version
- Theme configuration

### Crashlytics Demo
- Generate test exceptions
- Generate test crashes
- Error logging and monitoring

## 🧪 Automated Testing (Patrol)

### Test Cases Implemented

| Test Case | Description | File |
|-----------|-------------|------|
| **Test Case 1** | Google Sign-In | `integration_test/authentication_test.dart` |
| **Test Case 2** | Topic Search | `integration_test/publication_test.dart` |
| **Test Case 3** | Publication Details | `integration_test/publication_test.dart` |
| **Test Case 4** | Journals Navigation | `integration_test/journal_test.dart` |
| **Test Case 5** | Journal Details | `integration_test/journal_test.dart` |
| **Test Case 6** | Keywords Navigation | `integration_test/keyword_test.dart` |
| **Test Case 7** | Keyword Details | `integration_test/keyword_test.dart` |
| **Test Case 8** | Profile Navigation | `integration_test/authentication_test.dart` |
| **Test Case 9** | PDF Export | `integration_test/profile_test.dart` |
| **Test Case 10** | Remote Config | `integration_test/profile_test.dart` |
| **Test Case 11** | Logout | `integration_test/authentication_test.dart` |

### Running Patrol Tests

```bash
# Install Patrol CLI
dart pub global activate patrol_cli

# Run all tests
patrol test
```

## 🚀 Setup Instructions

### 1. Dependencies Installation

```bash
flutter pub get
```

### 2. Firebase Setup (Required)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android/iOS apps to your project
3. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

### 3. Configure Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 4. Enable Firebase Services

In the Firebase Console, enable:
- Authentication (Google Sign-In)
- Cloud Firestore (if needed)
- Storage
- Cloud Messaging
- Analytics
- Crashlytics
- Remote Config

### 5. Update Build Configuration

#### Android (`android/app/build.gradle`)

```gradle
plugins {
    id 'com.google.gms.google-services'
    id 'com.google.firebase.crashlytics'
}
```

#### Android Project Level (`android/build.gradle`)

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:3.0.0'
}
```

## 📱 Running the App

```bash
# Debug mode
flutter run

# Release mode  
flutter run --release

# On specific device
flutter run -d <device-id>
```

## 🔧 Key Features

### Firebase Authentication
- Google Sign-In integration
- User state management
- Secure authentication flow

### Cloud Messaging
- Push notification support
- Notification center in Profile
- Demo notifications for testing

### Analytics & Crashlytics
- User activity tracking
- Crash monitoring and reporting
- Custom events and parameters

### Remote Configuration
- Dynamic app configuration
- A/B testing capability
- Feature flags support

### Storage Integration
- PDF report generation
- File upload to Firebase Storage
- Download URL management

## 📋 Requirements Met

- ✅ Firebase Authentication (Google Sign-In)
- ✅ Firebase Storage (PDF reports)
- ✅ Firebase Cloud Messaging (Push notifications)
- ✅ Firebase Analytics (Event tracking)
- ✅ Firebase Crashlytics (Error monitoring)
- ✅ Firebase Remote Config (Dynamic configuration)
- ✅ MVVM Architecture implementation
- ✅ Automated testing with Patrol
- ✅ 4-tab navigation structure
- ✅ All required screens implemented

## 🐛 Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` is in `android/app/`
   - Run `flutterfire configure`

2. **Google Sign-In fails**
   - Check SHA-1 fingerprints in Firebase Console
   - Ensure Google Sign-In is enabled in Authentication

3. **Patrol tests fail**
   - Ensure app is running in debug mode
   - Check device/emulator connectivity

4. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Firebase configuration files

## 📚 Dependencies

### Core Dependencies
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
google_sign_in: ^6.2.1
firebase_analytics: ^11.3.3
firebase_crashlytics: ^4.1.3
firebase_remote_config: ^5.1.3
firebase_storage: ^12.3.2
firebase_messaging: ^15.1.3
pdf: ^3.11.1
provider: ^6.1.5
```

### Dev Dependencies
```yaml
patrol: ^3.12.0
flutter_test: sdk
```

## 👨‍💻 Development Team

**Student:** [Your Student ID]  
**Course:** PRM393 - Mobile Programming  
**Assignment:** Lab 03 - Firebase-Powered Journal Trend Analyzer  

## 📄 License

This project is developed for educational purposes as part of PRM393 coursework.

---

**Powered by OpenAlex API & Firebase**
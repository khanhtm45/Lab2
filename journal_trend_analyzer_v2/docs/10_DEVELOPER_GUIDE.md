# Developer Guide — Journal Trend Analyzer

---

## 1. Prerequisites

| Tool | Version |
|------|---------|
| Flutter | 3.x (stable) |
| Dart | ^3.11.0 |
| Android Studio | 2024.x or VS Code |
| Java | 17 (JVM target) |
| Android SDK | API 21+ (minSdk) |

---

## 2. Setup

```bash
# Clone and get dependencies
cd journal_trend_analyzer_v2
flutter pub get

# Run on Android/iOS/Desktop
flutter run

# Run in release mode
flutter run --release
```

---

## 3. Project Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, provider setup, Firebase init |
| `lib/screens/splash_screen.dart` | First screen, transitions to MainShell |
| `lib/screens/main_shell.dart` | Bottom nav shell with 4 tabs |
| `lib/theme/app_theme.dart` | Colors, typography, component themes |
| `lib/services/openalex_service.dart` | All API calls |

---

## 4. Running Lints

```bash
flutter analyze
flutter pub run flutter_lints
```

---

## 5. Building

```bash
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS (requires macOS + Xcode)
flutter build ios
```

---

## 6. Adding a New Screen

1. Create `lib/screens/new_screen.dart`
2. Add route in the calling screen:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => const NewScreen()),
   );
   ```
3. If it's a new bottom tab, add to `main_shell.dart`

---

## 7. Adding a New Widget

1. Create `lib/widgets/new_widget.dart`
2. Export from the widget or import directly in screens
3. Use `context.palette` for theme-aware colors
4. Use `AppDimens.pagePadding` / `AppDimens.cardRadius` for consistency

---

## 8. Adding Strings (Localization)

1. Open `lib/l10n/app_strings.dart`
2. Add new getter:
   ```dart
   String get newStringKey => switch (language) {
     AppLanguage.vietnamese => 'Chuỗi tiếng Việt',
     _ => 'English string',
   };
   ```
3. Use in screen: `context.strings.newStringKey`

---

## 9. Firebase Setup (when adding Firebase)

### Step 1: Create Firebase Project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create new project: "journal-trend-analyzer"
3. Add Android app with `com.example.journal_trend_analyzer_v2`

### Step 2: Download Config Files
- Android: `google-services.json` → `android/app/google-services.json`

### Step 3: Add pubspec.yaml dependencies
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  google_sign_in: ^6.2.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0
  firebase_remote_config: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
```

### Step 4: Update build.gradle.kts (Android)
```kotlin
// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")        // ADD THIS
    id("com.google.firebase.crashlytics")        // ADD THIS
}
```

```kotlin
// android/build.gradle.kts (project level)
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.0")
    }
}
```

### Step 5: Generate firebase_options.dart
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### Step 6: Initialize in main.dart
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // existing setup...
}
```

---

## 10. OpenAlex API Key

Optionally configure an API key for higher rate limits:

1. Register at [openalex.org](https://openalex.org)
2. Go to Profile → Settings in the app
3. Enter the API key
4. The key is stored in `shared_preferences` via `OpenAlexConfig`

Alternatively, just use `mailto` param (polite pool) without a key.

---

## 11. Key Dependencies

| Package | Version | Use |
|---------|---------|-----|
| `provider` | ^6.1.5 | State management |
| `http` | ^1.6.0 | HTTP requests |
| `fl_chart` | ^1.2.0 | Charts |
| `google_fonts` | ^6.2.1 | Typography |
| `shared_preferences` | ^2.5.3 | Local storage |
| `url_launcher` | ^6.3.2 | Open URLs/DOI |

---

## 12. Common Tasks

### Refresh data
```dart
await context.read<PublicationProvider>().refreshCurrentAnalysis();
```

### Search a topic
```dart
await context.read<PublicationProvider>().searchPublications('Machine Learning');
```

### Navigate to tab
```dart
context.read<AppNavigationProvider>().goToTab(2); // Trend tab
```

### Access theme palette
```dart
final palette = context.palette;
// palette.primary, palette.textSecondary, palette.surface, etc.
```

### Format a number
```dart
import 'package:journal_trend_analyzer/utils/count_format.dart';
formatOpenAlexCount(1250000); // "1.3M"
```

---

## 13. Troubleshooting

| Issue | Solution |
|-------|----------|
| `403` from OpenAlex | Check API key in Settings |
| `429` rate limit | Reduce API call frequency; use API key |
| Charts not rendering | Ensure `fl_chart` data has at least 2 points |
| Dark mode colors wrong | Use `context.palette` instead of hardcoded colors |
| Fonts not loading | Run `flutter pub get` and check `google_fonts` cache |
| Build fails | Check `flutter doctor`, Java 17, gradle version |

# Firebase Integration — Journal Trend Analyzer

> All Firebase features are planned additions.
> Current app is fully functional without Firebase (OpenAlex API only).

---

## Features Overview

| Feature | Package | Status |
|---------|---------|--------|
| Google Sign-In | `firebase_auth` + `google_sign_in` | Planned |
| Cloud Messaging (FCM) | `firebase_messaging` | Planned |
| Analytics | `firebase_analytics` | Planned |
| Crashlytics | `firebase_crashlytics` | Planned |
| Remote Config | `firebase_remote_config` | Planned |
| Storage | `firebase_storage` | Planned |

---

## 1. Google Sign-In / Firebase Authentication

### Setup

```yaml
# pubspec.yaml additions
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
google_sign_in: ^6.2.0
```

### Android Setup
1. Add `google-services.json` to `android/app/`
2. Add to `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
     id("com.google.gms.google-services")
   }
   ```
3. Add to `android/build.gradle.kts`:
   ```kotlin
   dependencies {
     classpath("com.google.gms:google-services:4.4.0")
   }
   ```

### main.dart Initialization
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // existing init...
  runApp(MyApp(...));
}
```

### AuthService
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

### Profile Data from Google Account
```dart
User? user = FirebaseAuth.instance.currentUser;
String? displayName = user?.displayName;   // "John Doe"
String? email       = user?.email;          // "john@gmail.com"
String? photoURL    = user?.photoURL;       // Avatar image URL
String  uid         = user?.uid ?? '';      // Firebase UID
```

---

## 2. Cloud Messaging (FCM)

### Setup
```yaml
firebase_messaging: ^15.0.0
```

### Initialization
```dart
final messaging = FirebaseMessaging.instance;

// Request permission (iOS)
await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

// Get FCM token
final token = await messaging.getToken();
print('FCM Token: $token');

// Foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final notification = message.notification;
  // Show local notification or update UI
});
```

### Notification Center (Profile Screen)
- Store received messages in `shared_preferences` as JSON list
- Display in Profile → Notification Center section
- Show unread badge count on Profile tab icon
- Mark all as read on screen open

### Sample Notification Types

| Type | Title | Body |
|------|-------|------|
| `new_paper` | "New paper in your topic" | "3 new papers on Machine Learning today" |
| `trending` | "Trending now" | "Blockchain is trending — 150% increase" |
| `weekly` | "Weekly digest" | "Your week in research: 12 new papers" |

---

## 3. Firebase Analytics

### Setup
```yaml
firebase_analytics: ^11.0.0
```

### Initialization
```dart
final analytics = FirebaseAnalytics.instance;
final observer  = FirebaseAnalyticsObserver(analytics: analytics);

// Add to MaterialApp
MaterialApp(
  navigatorObservers: [observer],
  ...
)
```

### Tracked Events

| Event Name | Parameters | When |
|------------|-----------|------|
| `search_topic` | `keyword`, `results_count` | User searches a topic |
| `view_journal` | `journal_name`, `journal_id` | Opens journal detail |
| `view_paper` | `paper_title`, `paper_id`, `year` | Opens paper detail |
| `bookmark_paper` | `paper_id`, `title` | Bookmarks a paper |
| `bookmark_journal` | `journal_id`, `name` | Bookmarks a journal |
| `bookmark_keyword` | `keyword` | Bookmarks a keyword |
| `view_trend` | `keyword`, `tab` | Opens trend analysis |
| `export_pdf` | `type`, `size_bytes` | Exports report as PDF |
| `app_open` | — | App launched |
| `login` | `method: google` | User signs in |
| `logout` | — | User signs out |
| `filter_applied` | `filter_type`, `value` | Search filter applied |
| `tab_switch` | `from_tab`, `to_tab` | Bottom nav tab changed |

### Analytics Logging
```dart
// Track search
await analytics.logEvent(
  name: 'search_topic',
  parameters: {
    'keyword': keyword,
    'results_count': totalCount,
  },
);

// Track paper view
await analytics.logViewItem(
  currency: null,
  value: null,
  items: [
    AnalyticsEventItem(
      itemId: paper.id,
      itemName: paper.title,
      itemCategory: 'paper',
    ),
  ],
);
```

### Profile Screen — Display Events
```dart
// Store events locally for display in Profile screen
class AnalyticsLocalStore {
  static const _key = 'tracked_events';

  Future<void> log(String name, Map<String, dynamic> params) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final entry = jsonEncode({
      'event': name,
      'params': params,
      'time': DateTime.now().toIso8601String(),
    });
    existing.insert(0, entry);
    await prefs.setStringList(_key, existing.take(50).toList());
  }

  Future<List<Map<String, dynamic>>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }
}
```

---

## 4. Firebase Crashlytics

### Setup
```yaml
firebase_crashlytics: ^4.0.0
```

### main.dart Integration
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Catch Flutter errors
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

// Catch Dart errors
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

### Profile Screen — Debug Buttons
```dart
// Generate non-fatal exception
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.recordError(
      Exception('Test exception from Profile screen'),
      StackTrace.current,
      fatal: false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exception sent to Crashlytics')),
    );
  },
  child: Text('Generate Exception'),
)

// Generate fatal crash
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: Text('Generate Crash'),
  style: ElevatedButton.styleFrom(backgroundColor: errorColor),
)
```

---

## 5. Firebase Remote Config

### Setup
```yaml
firebase_remote_config: ^5.0.0
```

### Default Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `max_journals` | int | 50 | Max journals in list |
| `max_keywords` | int | 20 | Max keywords tracked |
| `app_version` | String | "1.0.0" | App version label |
| `theme` | String | "light" | Default theme override |
| `feature_firebase_auth` | bool | false | Enable Google login |
| `feature_pdf_export` | bool | true | Enable PDF export |
| `results_per_page` | int | 20 | Default page size |

### RemoteConfigService
```dart
class RemoteConfigService {
  static final _rc = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _rc.setDefaults({
      'max_journals': 50,
      'max_keywords': 20,
      'app_version': '1.0.0',
      'theme': 'light',
      'feature_firebase_auth': false,
      'feature_pdf_export': true,
      'results_per_page': 20,
    });
    await _rc.fetchAndActivate();
  }

  static int get maxJournals => _rc.getInt('max_journals');
  static int get maxKeywords => _rc.getInt('max_keywords');
  static String get appVersion => _rc.getString('app_version');
  static String get theme => _rc.getString('theme');
  static bool get featureAuthEnabled => _rc.getBool('feature_firebase_auth');
  static bool get featurePdfEnabled => _rc.getBool('feature_pdf_export');
}
```

### Profile Screen Display
```dart
// Show Remote Config values in Profile
ProfileSection(
  title: 'App Configuration',
  children: [
    ConfigRow('Max Journals', '${RemoteConfigService.maxJournals}'),
    ConfigRow('Max Keywords', '${RemoteConfigService.maxKeywords}'),
    ConfigRow('Version', RemoteConfigService.appVersion),
    ConfigRow('Theme', RemoteConfigService.theme),
  ],
)
```

---

## 6. Firebase Storage

### Setup
```yaml
firebase_storage: ^12.0.0
```

### PDF Generation & Upload
```dart
class PdfReportService {
  static Future<String?> generateAndUpload({
    required String topic,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    // 1. Generate PDF bytes (using pdf package)
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Journal Trend Analyzer — Report'),
            pw.Text('Topic: $topic'),
            // ... charts, tables
          ],
        ),
      ),
    );
    final bytes = await pdf.save();

    // 2. Upload to Firebase Storage
    final ref = FirebaseStorage.instance
        .ref('reports/$userId/${topic}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    final task = await ref.putData(bytes);
    final url = await task.ref.getDownloadURL();
    return url;
  }
}
```

### Profile Screen — Export Section
```dart
// Generate PDF from current analysis
Column(
  children: [
    FilledButton.icon(
      onPressed: () async {
        setState(() => _generating = true);
        final url = await PdfReportService.generateAndUpload(
          topic: provider.currentTopic,
          data: provider.analysisData,
          userId: currentUser.uid,
        );
        setState(() { _pdfUrl = url; _generating = false; });
      },
      icon: Icon(Icons.picture_as_pdf_rounded),
      label: Text('Generate & Upload PDF'),
    ),
    if (_pdfUrl != null)
      InkWell(
        onTap: () => launchUrl(Uri.parse(_pdfUrl!)),
        child: Text(_pdfUrl!, style: linkStyle),
      ),
  ],
)
```

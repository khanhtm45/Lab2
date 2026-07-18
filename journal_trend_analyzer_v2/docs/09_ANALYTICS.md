# Analytics & Events — Journal Trend Analyzer

> Firebase Analytics event definitions and tracking implementation.

---

## Tracked Events

### App Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `app_open` | — | App launched |
| `app_foreground` | — | App returns from background |
| `session_start` | — | New session begins |

### Auth Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `login` | `method: "google"` | User signs in with Google |
| `logout` | — | User taps Sign Out |
| `sign_up` | `method: "google"` | First-time Google sign-in |

### Navigation Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `tab_switch` | `from_tab`, `to_tab` | Bottom nav tab changed |
| `screen_view` | `screen_name`, `screen_class` | Screen becomes visible |

### Search Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `search_topic` | `keyword`, `results_count` | User searches a topic |
| `search_journal` | `query`, `results_count` | User searches a journal |
| `search_cleared` | — | Recent searches cleared |
| `filter_applied` | `filter_type`, `value` | Filter applied to search |
| `sort_changed` | `sort_option` | Sort option changed |
| `suggested_topic_tapped` | `topic` | User taps a suggested topic chip |

### Content Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `view_paper` | `paper_id`, `title`, `year`, `journal` | Publication detail opened |
| `view_journal` | `journal_id`, `journal_name`, `publisher` | Journal detail opened |
| `view_author` | `author_id`, `author_name` | Author detail opened |
| `view_volume` | `journal_id`, `volume_number`, `year` | Volume detail opened |
| `view_trend` | `keyword`, `tab` | Trend page opened with keyword |

### Bookmark Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `bookmark_paper` | `paper_id`, `title` | Paper bookmarked |
| `unbookmark_paper` | `paper_id` | Paper bookmark removed |
| `bookmark_journal` | `journal_id`, `journal_name` | Journal bookmarked |
| `unbookmark_journal` | `journal_id` | Journal bookmark removed |
| `bookmark_keyword` | `keyword` | Keyword bookmarked |
| `unbookmark_keyword` | `keyword` | Keyword bookmark removed |

### Engagement Events

| Event Name | Parameters | Trigger |
|------------|-----------|---------|
| `open_doi_link` | `doi`, `paper_id` | "View Original Paper" tapped |
| `share_paper` | `paper_id`, `method` | Paper shared |
| `export_pdf` | `topic`, `paper_count` | PDF report generated |
| `pdf_uploaded` | `file_size_bytes`, `topic` | PDF uploaded to Firebase Storage |
| `chart_viewed` | `chart_type`, `context` | Chart section scrolled into view |
| `load_more_results` | `entity_type`, `page` | Load more button tapped |

---

## Implementation

### Analytics Service

```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  // Navigation observer (add to MaterialApp)
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Convenience log method
  static Future<void> log(String name, [Map<String, Object>? params]) async {
    await _analytics.logEvent(name: name, parameters: params);
    // Also store locally for Profile screen display
    await _localStore.log(name, params ?? {});
  }

  // Auth
  static Future<void> logLogin() => log('login', {'method': 'google'});
  static Future<void> logLogout() => log('logout');

  // Search
  static Future<void> logSearchTopic(String keyword, int count) =>
      log('search_topic', {'keyword': keyword, 'results_count': count});

  static Future<void> logSearchJournal(String query, int count) =>
      log('search_journal', {'query': query, 'results_count': count});

  // Views
  static Future<void> logViewPaper(String id, String title, int year) =>
      log('view_paper', {'paper_id': id, 'title': title, 'year': year});

  static Future<void> logViewJournal(String id, String name) =>
      log('view_journal', {'journal_id': id, 'journal_name': name});

  static Future<void> logViewTrend(String keyword) =>
      log('view_trend', {'keyword': keyword});

  // Bookmarks
  static Future<void> logBookmarkPaper(String id, String title) =>
      log('bookmark_paper', {'paper_id': id, 'title': title});

  static Future<void> logBookmarkJournal(String id, String name) =>
      log('bookmark_journal', {'journal_id': id, 'journal_name': name});

  // Export
  static Future<void> logExportPdf(String topic, int paperCount) =>
      log('export_pdf', {'topic': topic, 'paper_count': paperCount});

  // Navigation
  static Future<void> logTabSwitch(int from, int to) =>
      log('tab_switch', {'from_tab': from, 'to_tab': to});
}
```

### Local Event Store (for Profile Screen Display)

```dart
// lib/services/analytics_local_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsLocalStore {
  static const _key = 'analytics_events';
  static const _maxEvents = 50;

  static Future<void> log(String name, Map<String, Object> params) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final entry = jsonEncode({
      'event': name,
      'params': params.map((k, v) => MapEntry(k, v.toString())),
      'time': DateTime.now().toIso8601String(),
    });
    existing.insert(0, entry);
    await prefs.setStringList(_key, existing.take(_maxEvents).toList());
  }

  static Future<List<AnalyticsEvent>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return AnalyticsEvent(
        name: map['event'] as String,
        params: Map<String, String>.from(map['params'] as Map),
        time: DateTime.parse(map['time'] as String),
      );
    }).toList();
  }
}

class AnalyticsEvent {
  final String name;
  final Map<String, String> params;
  final DateTime time;

  const AnalyticsEvent({
    required this.name,
    required this.params,
    required this.time,
  });
}
```

### Profile Screen — Analytics Display

```dart
// In ProfileScreen
FutureBuilder<List<AnalyticsEvent>>(
  future: AnalyticsLocalStore.getRecent(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox.shrink();
    final events = snapshot.data!;
    return ProfileSection(
      title: 'Analytics Events',
      children: events.take(10).map((e) => _EventTile(event: e)).toList(),
    );
  },
)

class _EventTile extends StatelessWidget {
  final AnalyticsEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(event.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(
        event.params.entries.map((e) => '${e.key}: ${e.value}').join(', '),
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Text(
        _relativeTime(event.time),
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
```

---

## User Properties

Set on login / profile update:

```dart
await _analytics.setUserProperty(name: 'user_type', value: 'researcher');
await _analytics.setUserProperty(name: 'theme', value: isDark ? 'dark' : 'light');
await _analytics.setUserProperty(name: 'language', value: language.code);
```

---

## Screen Tracking

Automatic screen tracking via `FirebaseAnalyticsObserver` in `navigatorObservers`.

Manual screen tracking for custom screens:
```dart
@override
void initState() {
  super.initState();
  AnalyticsService.log('screen_view', {
    'screen_name': 'JournalDetail',
    'screen_class': 'JournalDetailScreen',
  });
}
```

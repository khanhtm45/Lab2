# System Architecture — Journal Trend Analyzer

---

## Project Structure

```
lib/
├── main.dart                  # Entry point, Firebase init, Provider setup
│
├── l10n/                      # Localization
│   ├── app_strings.dart       # All UI strings (EN/VI)
│   ├── l10n_models.dart       # Localization models
│   └── strings_extension.dart # BuildContext.strings extension
│
├── models/                    # Data models (plain Dart classes)
│   ├── publication.dart
│   ├── journal.dart
│   ├── author.dart
│   ├── author_profile.dart
│   ├── journal_source_profile.dart
│   ├── openalex_ranked_entity.dart
│   ├── openalex_works_result.dart
│   ├── publication_author.dart
│   ├── ranked_author_entry.dart
│   ├── recent_search_entry.dart
│   ├── research_insight.dart
│   ├── search_filters.dart
│   ├── year_activity_snapshot.dart
│   ├── advanced_analytics_data.dart
│   ├── analytics_catalog.dart
│   └── analytics_extra_bundle.dart
│
├── providers/                 # State management (Provider pattern)
│   ├── publication_provider.dart   # Main data provider
│   └── app_navigation_provider.dart # Tab navigation state
│
├── screens/                   # UI screens (one per route)
│   ├── splash_screen.dart
│   ├── main_shell.dart        # Bottom nav shell
│   ├── home_screen.dart       # Tab 0: Home dashboard
│   ├── journal_screen.dart    # Tab 1: Journal search (new)
│   ├── trend_screen.dart      # Tab 2: Trend analysis
│   ├── profile_screen.dart    # Tab 3: Profile
│   ├── journal_detail_screen.dart
│   ├── volume_detail_screen.dart   # (new)
│   ├── detail_screen.dart          # Publication detail
│   ├── author_detail_screen.dart
│   ├── search_screen.dart
│   ├── search_suggestions_screen.dart
│   ├── settings_screen.dart
│   ├── about_screen.dart
│   └── ... (analysis sub-screens)
│
├── services/                  # API & storage services
│   ├── openalex_service.dart  # All OpenAlex API calls
│   ├── openalex_config.dart   # API key management
│   ├── openalex_exception.dart
│   ├── app_preferences.dart   # SharedPreferences wrapper
│   ├── recent_searches_service.dart
│   ├── bookmarked_topics_service.dart
│   └── analytics_cache_service.dart
│
├── theme/
│   └── app_theme.dart         # Material 3 theme, colors, typography
│
├── utils/
│   ├── count_format.dart      # Number formatting (K/M/B)
│   ├── chart_axis.dart        # Chart axis helpers
│   ├── publication_analytics.dart
│   ├── research_insights.dart
│   └── research_summary_share.dart
│
└── widgets/                   # Reusable UI components
    ├── publication_card.dart
    ├── home_widgets.dart
    ├── journal_detail_widgets.dart
    ├── trend_chart.dart
    ├── citation_bar_chart.dart
    ├── compact_trend_chart.dart
    ├── distribution_chart.dart
    ├── analytics_charts.dart
    └── ... (40+ widget files)
```

---

## Data Flow

```
User Action (search / tap)
        │
        ▼
  [Screen Widget]
        │ calls provider method
        ▼
  [PublicationProvider]   ←──────── ChangeNotifier
        │
        ├── updates state fields
        │
        ▼
  [OpenAlexService]
        │ HTTP GET → api.openalex.org
        │
        ▼
  [OpenAlex API Response]
        │ JSON parsing
        ▼
  [Model Classes]
        │
        ▼
  notifyListeners()
        │
        ▼
  [UI rebuilds via Consumer / context.watch]
```

---

## State Architecture

### PublicationProvider (main state)

```
PublicationProvider
├── AnalysisScope: global | topic
├── currentTopic: String
├── publications: List<Publication>
├── totalOnOpenAlex: int
├── yearlyTrendFromOpenAlex: Map<int,int>
├── citationsByYearOpenAlex: Map<int,int>
├── topAuthorsOpenAlex: List<OpenAlexRankedEntity>
├── topJournalsOpenAlex: List<OpenAlexRankedEntity>
├── topKeywordsOpenAlex: List<OpenAlexRankedEntity>
├── topInstitutionsOpenAlex: List<OpenAlexRankedEntity>
├── topCountriesOpenAlex: List<OpenAlexRankedEntity>
├── recentSearches: List<RecentSearchEntry>
├── bookmarkedTopics: List<String>
├── searchFilters: SearchFilters
├── isDashboardLoading: bool
├── isSearchLoading: bool
└── errorMessage: String?
```

### AppNavigationProvider

```
AppNavigationProvider
└── tabIndex: int (0–3)
    goToTab(int index)
```

---

## API Layer Design

### OpenAlexService

All methods return typed Dart objects. No raw JSON leaves the service layer.

```
OpenAlexService
├── fetchSearchPage(topic, page) → OpenAlexWorksResult
├── fetchTopPapers(search?) → List<Publication>
├── fetchPublicationTrendByYear(search?) → Map<int,int>
├── fetchWorksGroupedCounts(groupBy, search?) → List<OpenAlexRankedEntity>
├── fetchDistribution(groupBy, search?) → Map<String,int>
├── fetchCitationMetricsByYear(search?) → ({totals, averages})
├── fetchAverageCitation(search?) → double
├── fetchWorksTotalCount(search?) → int
├── fetchAuthorDetailProfile(id) → AuthorProfile?
├── fetchSourceProfile(id) → JournalSourceProfile?
├── fetchSourceYearlyTrend(sourceId) → Map<int,int>
├── fetchConceptYearlyTrend(conceptId) → Map<int,int>
├── fetchAdvancedAnalyticsBundle(search?) → AdvancedAnalyticsData
└── compareTopics(topicA, topicB) → TopicComparisonResult
```

---

## Routing

Navigation uses `Navigator.push` with `MaterialPageRoute`. No named routes.

```
MainShell (IndexedStack, 4 tabs)
    ├── HomeScreen
    │       ├── push → SearchSuggestionsScreen
    │       └── push → ResearchDashboardScreen
    ├── JournalScreen (tab 1)
    │       └── push → JournalDetailScreen
    │               └── push → VolumeDetailScreen
    │                       └── push → DetailScreen
    ├── TrendScreen (tab 2)
    │       └── push → DetailScreen
    └── ProfileScreen (tab 3)
            ├── push → SettingsScreen
            ├── push → AboutScreen
            └── push → BookmarksScreen
```

---

## Concurrency & Error Handling

- All API calls are `async`/`await` with `try/catch`
- `_searchGeneration` counter prevents stale data from out-of-order async responses
- `OpenAlexException` for API errors (status code + message)
- `_tryAggregate()` swallows individual metric failures without breaking the whole dashboard
- Retry logic: up to 4 retries with exponential backoff for 429/502/503/504

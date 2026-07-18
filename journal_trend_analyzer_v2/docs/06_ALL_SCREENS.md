# All Screens — Journal Trend Analyzer

> Complete UI specification for every screen in the app.
> Style: Material Design 3 · Premium Academic Dashboard · Glassmorphism (light)

---

## Navigation Map

```
MainShell (BottomNav — 4 tabs)
├── [0] HomeScreen
│   ├── SearchSuggestionsScreen
│   └── ResearchDashboardScreen
│       ├── TopPapersScreen
│       ├── TopAuthorsScreen
│       └── TopJournalsScreen
├── [1] JournalScreen  (new — replaces SearchScreen)
│   └── JournalDetailScreen
│       └── VolumeDetailScreen
│           └── PublicationDetailScreen (DetailScreen)
├── [2] TrendScreen
│   └── PublicationDetailScreen (DetailScreen)
└── [3] ProfileScreen
    ├── BookmarksScreen
    ├── NotificationsScreen (Firebase)
    ├── SettingsScreen
    └── AboutScreen
```

---

## SCREEN 1 — Home

**File:** `lib/screens/home_screen.dart`
**Tab:** #0 Home

### Layout Structure

```
SafeArea
└── ListView (padding: 20px horizontal, 24px bottom)
    ├── HomeAppBar
    │   ├── Left: App logo (32px) + "Journal Trend Analyzer" text
    │   └── Right: Avatar/Profile button (40px circle)
    │
    ├── GreetingSection
    │   ├── "Good morning, Researcher 👋" (bodyMedium, muted)
    │   └── "Explore Research Trends" (headlineLarge, 24px bold)
    │
    ├── SearchBar (full width, 52px height)
    │   ├── Leading: search icon (primary)
    │   ├── Hint: "Search AI, journals, authors..."
    │   ├── Trailing: filter icon button (badge if active)
    │   └── onTap → SearchSuggestionsScreen
    │
    ├── RecentSearches Section
    │   ├── Header: "Recent Searches" + "Clear" TextButton
    │   └── RecentSearchChips (horizontal scroll)
    │       Each chip: clock icon + topic text + X button
    │
    ├── SuggestedTopics Section
    │   ├── Header: "Suggested Topics"
    │   └── Wrap of TopicPillChips:
    │       "Artificial Intelligence" | "Machine Learning"
    │       "Blockchain" | "Cyber Security"
    │       "IoT" | "Data Science"
    │       Each chip: bookmark toggle (filled/outlined)
    │
    ├── QuickStatistics Section (2×3 grid)
    │   ├── Header: "Quick Statistics"
    │   └── GridView (crossAxisCount: 2, gap: 10)
    │       StatCard: Total Publications (🔵 article icon)
    │       StatCard: Average Citation   (🟡 quote icon)
    │       StatCard: Most Active Year   (🟢 trending icon)
    │       StatCard: Top Journal        (🔷 book icon)
    │       StatCard: Top Author         (🟣 person icon)
    │       StatCard: Trending Keyword   (🔴 tag icon)
    │
    ├── LatestPublications Section
    │   ├── Header: "Latest Publications" + "See All" button
    │   └── Horizontal PageView (card carousel, 280px wide)
    │       Each card (PaperCarouselCard):
    │         ┌───────────────────────────────┐
    │         │ [Type badge]      [Bookmark]  │
    │         │ Title (2 lines, bold)         │
    │         │ Journal name (muted, 12px)    │
    │         │ ─────────────────────────    │
    │         │ 📅 Year    💬 Citations       │
    │         └───────────────────────────────┘
    │
    ├── ResearchHighlights Section
    │   ├── Header: "Research Highlights"
    │   ├── HighlightTile: "Newest Paper" → latest paper
    │   ├── HighlightTile: "Most Influential" → top cited paper
    │   ├── HighlightTile: "Trending Journal" → top journal
    │   └── HighlightTile: "Trending Topic" → top concept
    │
    ├── Charts Section
    │   ├── Header: "Publication Trend"
    │   ├── LineChart (trend 2016–present, height: 180px)
    │   ├── Header: "Citation Trend"
    │   ├── LineChart (citations by year, height: 180px)
    │   ├── Header: "Research Landscape"
    │   ├── Treemap (top concepts, height: 200px)
    │   ├── Header: "Emerging Keywords"
    │   └── BubbleChart (keyword bubbles, height: 200px)
    │
    ├── LatestUpdates Timeline
    │   ├── Header: "Latest Updates"
    │   └── Vertical timeline (last 5 events):
    │       Each item: dot + line + date + description
    │
    └── RecommendedResearch
        ├── Header: "Recommended Research"
        └── 3 PublicationCard items
```

### Sample Data (OpenAlex)
```json
{
  "greeting": "Good morning, Researcher",
  "stats": {
    "totalPublications": "284.7M",
    "avgCitation": "12.4",
    "mostActiveYear": "2023",
    "topJournal": "Nature",
    "topAuthor": "Yoshua Bengio",
    "trendingKeyword": "Large Language Models"
  },
  "latestPapers": [
    {
      "title": "Attention Is All You Need",
      "journal": "NeurIPS",
      "year": 2023,
      "citations": 98450
    }
  ]
}
```

### Floating Search Button
```dart
FloatingActionButton.extended(
  onPressed: () => openSearch(),
  icon: Icon(Icons.search_rounded),
  label: Text('Search'),
  backgroundColor: primary,
)
```

---

## SCREEN 2 — Journal

**File:** `lib/screens/journal_screen.dart` (new tab screen)
**Tab:** #1 Journal

### Layout Structure

```
Scaffold
├── AppBar (gradient, transparent)
│   └── Title: "Journals"
│
└── Column
    ├── SearchBar (pinned below AppBar, 16px padding)
    │   ├── Leading: search icon
    │   ├── Hint: "Search journals by name, ISSN..."
    │   └── onSubmit → searchJournals(query)
    │
    ├── RecentSearches (horizontal chip scroll, 8px height)
    │   Each: clock icon + name + X
    │
    ├── PopularJournals Section (horizontal scroll)
    │   Header: "Popular Journals"
    │   Each PopularJournalChip:
    │     - Cover color (gradient by category)
    │     - Journal name (short)
    │     - Paper count badge
    │
    └── Expanded ListView (journal results)
        │  (shows placeholder list when no search)
        └── JournalCard (each):
            ┌──────────────────────────────────────┐
            │ [Logo] Journal Name          ❤️      │
            │        Publisher             [Q1]    │
            │        ─────────────────────────    │
            │        🌍 Country  H: 145  SJR: 4.2 │
            │        📄 12,450 papers  💬 980K cit │
            └──────────────────────────────────────┘
```

### Journal Card Details

| Field | Source | Display |
|-------|--------|---------|
| Cover logo | Generated avatar (gradient + initials) | 52×52 rounded |
| Journal name | `source.display_name` | Bold 15px |
| Publisher | `source.host_organization_name` | Muted 12px |
| SJR | Computed / displayed as badge | "SJR: 4.2" |
| H-index | Simulated from citation count | "H: 145" |
| Country | `source.country_code` | Flag emoji + code |
| Total papers | `source.works_count` | Formatted count |
| Total citations | `source.cited_by_count` | Formatted count |
| Favorite | Local `shared_preferences` | Heart icon toggle |

---

## SCREEN 3 — Journal Detail

**File:** `lib/screens/journal_detail_screen.dart`
**Route:** Pushed from JournalCard tap

### Layout Structure

```
Scaffold
├── SliverAppBar (collapsing, gradient banner)
│   ├── expandedHeight: 200px
│   ├── Background: gradient (primary → secondary)
│   ├── Flexible space:
│   │   ├── Journal logo (64px circle, white border)
│   │   ├── Journal name (white, 20px bold)
│   │   └── Publisher (white 70% opacity, 13px)
│   └── Actions: Bookmark, Share
│
└── SliverList body
    ├── InfoSection
    │   ├── ISSN: "1234-5678"
    │   ├── Publisher: "Elsevier"
    │   ├── Homepage: clickable link button
    │   └── Description: 3-line expandable text
    │
    ├── StatisticsGrid (2×3)
    │   StatTile: Publication Count
    │   StatTile: Citation Count
    │   StatTile: Average Citation
    │   StatTile: H-Index
    │   StatTile: SJR score
    │   StatTile: Quartile (Q1/Q2/Q3/Q4 badge)
    │
    ├── Publication Trend Chart
    │   ├── Section header: "Publication Activity"
    │   └── LineChart (2016–2025, height: 180px)
    │
    ├── Citation Trend Chart
    │   ├── Section header: "Citation Growth"
    │   └── BarChart (citations by year, height: 160px)
    │
    ├── Top Authors (horizontal scroll, 5 items)
    │   Each AuthorChip: avatar + name + count badge
    │
    ├── Top Topics (Wrap of TopicChips)
    │
    ├── Recent Volumes Section
    │   Header: "Recent Volumes"
    │   └── VolumeList (latest 5 volumes):
    │       Each VolumeCard:
    │         ┌──────────────────────────────────┐
    │         │ Vol. 45 · 2024    →  12 Issues   │
    │         │ 284 papers  ·  Total: 45,000 cit │
    │         └──────────────────────────────────┘
    │         onTap → VolumeDetailScreen
    │
    └── BottomCTA button: "View All Publications"
```

---

## SCREEN 4 — Volume Detail

**File:** `lib/screens/volume_detail_screen.dart` (new)
**Route:** Pushed from VolumeCard tap

### Layout Structure

```
Scaffold
├── AppBar
│   └── Title: "Vol. 45 (2024)"
│
└── Column
    ├── VolumeHeader Card (rounded 20px)
    │   ├── Volume Number: "Volume 45"
    │   ├── Year: "2024"
    │   ├── Issues: "12 issues"
    │   └── Paper count: "284 papers"
    │
    ├── IssuesList (vertical scroll)
    │   Each IssueCard:
    │     ┌──────────────────────────────────┐
    │     │ Issue 1 · January 2024           │
    │     │ 24 papers · DOI prefix: 10.1016  │
    │     └──────────────────────────────────┘
    │
    └── PapersList (papers in volume)
        Header: "Papers in this Volume"
        Each PaperCard (compact):
          - Title (2 lines)
          - Authors
          - DOI
          - Citations
          - Year
          - Bookmark button
          onTap → PublicationDetailScreen
```

---

## SCREEN 5 — Trend

**File:** `lib/screens/trend_screen.dart`
**Tab:** #2 Trend

### Layout Structure

```
SafeArea
└── Column
    ├── Header: "Trend Analysis"
    │
    ├── TopSearchBox (full width)
    │   ├── Hint: "Enter a keyword to analyze..."
    │   ├── onSubmit → analyzeTrend(keyword)
    │   └── SearchButton (primary filled)
    │
    ├── KeywordChips (quick suggestions, horizontal scroll)
    │   "Artificial Intelligence" | "IoT" | "Blockchain"
    │   "Machine Learning" | "Deep Learning" | "NLP"
    │
    ├── (Empty state when no keyword entered)
    │   IllustrationEmptyState: "Enter a keyword above"
    │
    └── (After search — analysis dashboard):
        Expanded ListView
        │
        ├── DashboardSummaryRow (4 metric cards, horizontal scroll)
        │   Card: Publication Count  (blue gradient)
        │   Card: Citation Count     (cyan gradient)
        │   Card: Top Author         (violet gradient)
        │   Card: Top Journal        (amber gradient)
        │   Card: Top Institution    (green gradient)
        │   Card: Top Country        (teal gradient)
        │
        ├── Charts Section
        │   ├── "Publication Trend" → LineChart (2016–2025)
        │   ├── "Citation Trend" → BarChart
        │   ├── "Keyword Trend" → MultiLineChart (compare keywords)
        │   ├── "Topic Evolution" → StackedAreaChart
        │   └── "Research Landscape" → Treemap
        │
        ├── Keywords Analysis Section
        │   ├── "Top Keywords" → HorizontalBarChart
        │   ├── "Emerging Keywords" → BubbleChart (size=growth rate)
        │   └── "Keyword Co-occurrence" → NetworkGraph
        │
        ├── Network Section
        │   └── "Topic Network" → ForceDirectedGraph
        │
        ├── Geographic Analysis
        │   ├── "Country Heatmap" → GridHeatmap (country × citations)
        │   └── "Institution Heatmap" → GridHeatmap
        │
        ├── Author Analysis
        │   └── "Author Productivity Scatter" → ScatterPlot
        │       (X: publications, Y: citations, size: h-index)
        │
        ├── Special Charts
        │   ├── "Citation Velocity" → LineChart (ΔCitations/year)
        │   └── "Research Frontier Bubble" → BubbleChart
        │       (size=recency, color=topic cluster)
        │
        └── Rankings Section (4 tabs)
            ├── AuthorRanking (ranked list with avatar + stats)
            ├── JournalRanking (ranked list with logo + metrics)
            ├── CountryRanking (flag + bar + count)
            └── InstitutionRanking (icon + bar + count)
```

### Trend Dashboard Metrics

| Metric | Description | Source |
|--------|-------------|--------|
| Publication Count | Total works for keyword | `/works?search={kw}` |
| Citation Count | Total citations | Aggregated from results |
| Top Author | Highest publication count | `group_by=authorships.author.id` |
| Top Journal | Most papers in topic | `group_by=primary_location.source.id` |
| Top Institution | Most affiliated authors | `group_by=authorships.institutions.id` |
| Top Country | Dominant country | `group_by=authorships.institutions.country_code` |

---

## SCREEN 6 — Publication Detail

**File:** `lib/screens/detail_screen.dart`
**Route:** Pushed from any paper card

### Layout Structure

```
Scaffold
├── SliverAppBar
│   ├── Leading: Back button
│   └── Actions: Share, Bookmark
│
└── SliverList body
    ├── HeroCard (gradient background, large)
    │   ├── TypeBadge (e.g., "Journal Article")
    │   ├── Title (bold, 18px, white or dark on gradient)
    │   ├── Authors list (truncated to 3 + "+N more")
    │   ├── Divider
    │   ├── Row: Journal name | Year | Citations
    │   └── DOI clickable link
    │
    ├── AbstractSection
    │   ├── Header: "Abstract"
    │   ├── Text (expandable, max 5 lines collapsed)
    │   └── "Read more" / "Collapse" toggle
    │
    ├── MetadataGrid (2 columns)
    │   ├── OpenAlex ID (clickable)
    │   ├── DOI (clickable → doi.org)
    │   ├── Publication Year
    │   ├── Type
    │   ├── Open Access status (badge)
    │   └── Language
    │
    ├── KeywordsSection
    │   └── Wrap of keyword chips (tappable → Trend page search)
    │
    ├── ReferencesSection
    │   ├── Header: "References (N)"
    │   └── List of reference tiles (title + year + link)
    │
    ├── RelatedPapersSection
    │   ├── Header: "Related Papers"
    │   └── List of RelatedPaperTile (5 items):
    │       Each: title + year + citations + bookmark
    │
    └── OriginalPaperButton
        FilledButton: "View Original Paper"
        onTap → url_launcher → DOI link
```

### Hero Animation
```dart
// Hero tag: 'paper-${paper.id}-title'
Hero(
  tag: 'paper-${paper.id}',
  child: Material(
    color: Colors.transparent,
    child: Text(paper.title, style: titleStyle),
  ),
)
```

---

## SCREEN 7 — Profile

**File:** `lib/screens/profile_screen.dart`
**Tab:** #3 Profile

### Layout Structure

```
SafeArea
└── ListView
    ├── ProfileHeader Card (gradient banner)
    │   ├── Avatar (64px circle — Google photo or initials)
    │   ├── Display Name (Google account name)
    │   ├── Email
    │   ├── Firebase UID (monospace, copyable)
    │   └── [Google Sign-In button] (if not logged in)
    │
    ├── BookmarksSection
    │   ├── Header: "My Bookmarks" + badge count
    │   ├── BookmarkedPapers (expandable list, 3 shown by default)
    │   │   Each item: truncated title + year + citations
    │   ├── BookmarkedJournals (expandable list)
    │   │   Each item: journal name + publisher
    │   └── BookmarkedKeywords (chip wrap)
    │
    ├── NotificationCenter Section
    │   ├── Header: "Notifications"
    │   └── NotificationList (from Firebase Cloud Messaging):
    │       Each item:
    │         - Icon (colored by type)
    │         - Title + message
    │         - Timestamp
    │         - Unread badge (blue dot)
    │
    ├── ExportPDF Section
    │   ├── Header: "Export Report"
    │   ├── GeneratePDF button → generates PDF of current analysis
    │   ├── UploadPDF button → uploads to Firebase Storage
    │   └── UploadedFileURL (clickable, once uploaded)
    │
    ├── RemoteConfig Section
    │   ├── Header: "App Configuration" (Remote Config)
    │   ├── Maximum Journals: 50 (from RC)
    │   ├── Maximum Keywords: 20 (from RC)
    │   ├── Version: 1.0.0 (from RC)
    │   └── Theme: Light / Dark (from RC)
    │
    ├── CrashlyticsSection (Debug only)
    │   ├── Header: "Debug Tools"
    │   ├── [Generate Exception] button → throws exception
    │   └── [Generate Crash] button → forces crash
    │
    ├── AnalyticsSection
    │   ├── Header: "Analytics Events"
    │   └── List of tracked events (from Firebase Analytics):
    │       Each item: event name + timestamp + params summary
    │
    └── LogoutButton
        OutlinedButton.icon(
          icon: Icons.logout_rounded,
          label: 'Sign Out',
          style: red border / text,
          onPressed: () => signOut(),
        )
```

---

## SCREEN 8 — Splash Screen

**File:** `lib/screens/splash_screen.dart`

```
Scaffold (gradient background: primary → secondary)
└── Center
    └── Column
        ├── AppLogo (80px, animated fade-in)
        ├── SizedBox(20)
        ├── Text: "Journal Trend Analyzer"
        │     (white, 24px bold, Be Vietnam Pro)
        ├── SizedBox(8)
        ├── Text: "Powered by OpenAlex"
        │     (white 70% opacity, 13px)
        ├── SizedBox(48)
        └── CircularProgressIndicator (white, size: 28px)
```

Transition: Fade to MainShell after 2 seconds (or when data ready).

---

## SCREEN 9 — Settings

**File:** `lib/screens/settings_screen.dart`

```
Scaffold
├── AppBar: "Settings"
└── ListView
    ├── AppearanceSection
    │   ├── ThemeSelector (Light / Dark / System)
    │   └── FontSizeSlider
    │
    ├── DataSection
    │   ├── ResultsPerPage (10 / 20 / 50)
    │   ├── DefaultSort (Most Cited / Newest / Relevance)
    │   └── SaveRecentSearches toggle
    │
    ├── OpenAlexSection
    │   ├── API Key input
    │   └── Test Connection button
    │
    └── CacheSection
        ├── Cache size info
        └── Clear Cache button
```

---

## Additional UI Patterns

### Gradient AppBar Pattern
```dart
SliverAppBar(
  expandedHeight: 200,
  pinned: true,
  flexibleSpace: FlexibleSpaceBar(
    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF0891B2)],
        ),
      ),
    ),
  ),
)
```

### Bookmark Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(bookmarked ? '✓ Saved to Bookmarks' : 'Removed from Bookmarks'),
    backgroundColor: bookmarked ? success : textSecondary,
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
)
```

### Section Header Pattern
```dart
Row(
  children: [
    Text(title, style: headlineSmall),
    Spacer(),
    if (trailing != null) trailing,
  ],
)
```

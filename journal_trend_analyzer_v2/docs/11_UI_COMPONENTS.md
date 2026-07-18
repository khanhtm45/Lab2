# UI Component Catalog — Journal Trend Analyzer

> Complete reference for all reusable widgets.
> All widgets respect `AppPalette` for light/dark mode.

---

## 1. Cards

### PremiumCard / MockupCard
**File:** `lib/widgets/app_logo.dart` (contains MockupCard)
```dart
// Usage:
MockupCard(
  padding: EdgeInsets.all(16),
  child: MyContent(),
)
```
- Rounded 20px
- White surface / dark surface
- Subtle border + soft shadow
- Optional gradient header strip

### GlassCard
```dart
// Glassmorphism card with blur
GlassCard(
  child: Row(children: [...]),
)
```
- `BackdropFilter(blur: 12)`
- `Color(0xFFFFFFFF).withOpacity(0.65)` background
- White border 40% opacity

### StatCard (Metric Tile)
**File:** `lib/widgets/dashboard_card.dart`
```dart
StatCard(
  value: '284.7M',
  label: 'Total Publications',
  icon: Icons.article_outlined,
  accentColor: AppColors.primary,
  onTap: () => navigateToDashboard(),
)
```
- 2-column grid layout (in parent GridView)
- Icon top-left
- Large bold value
- Small muted label
- Optional gradient background

---

## 2. Publication Widgets

### PublicationCard
**File:** `lib/widgets/publication_card.dart`
```dart
PublicationCard(publication: paper)
// Hero animation tag: 'paper-${paper.id}'
```
Features:
- Type badge (top-left, colored)
- Bookmark button (top-right)
- Title (2 lines, bold 15px)
- Authors (1 line, muted)
- Journal chip + Year badge + Citation badge
- Shadow + 20px radius
- Hero animation support

### PaperCarouselCard
```dart
// Used in Latest Publications horizontal scroll
PaperCarouselCard(paper: paper, onTap: () => openDetail())
```
- Width: 280px fixed
- Gradient strip at top (category color)
- Compact layout for carousel

### RelatedPaperTile
**File:** `lib/widgets/related_paper_tile.dart`
```dart
RelatedPaperTile(paper: paper, onTap: () => openDetail())
```
- Compact list tile
- No avatar
- Title (2 lines)
- Year + citations inline

### TopPaperListTile
**File:** `lib/widgets/top_paper_list_tile.dart`
```dart
TopPaperListTile(paper: paper, rank: 1, onTap: () => {})
```
- Rank number (large, colored)
- Title + journal
- Citation badge

---

## 3. Journal Widgets

### JournalCard
```dart
JournalCard(
  journal: entity,
  isFavorite: false,
  onTap: () => openDetail(),
  onFavorite: () => toggleFavorite(),
)
```
- 52px logo avatar (gradient + initials)
- Name, publisher, country, SJR, H-index
- Paper/citation counts
- Heart favorite toggle

### JournalHeaderCard
**File:** `lib/widgets/journal_detail_widgets.dart`
```dart
JournalHeaderCard(profile: journalProfile)
```
- Full journal identity display
- ISSN, publisher, homepage URL button
- Expandable description

### JournalStatTile
```dart
JournalStatTile(value: '12,450', label: 'Papers')
```
- Small 2×2 grid tile
- Bold value + muted label

### JournalTopPaperCard
```dart
JournalTopPaperCard(paper: paper, onTap: () => openDetail())
```
- Compact card for top papers in journal detail

---

## 4. Author Widgets

### AuthorDetailHeader
**File:** `lib/widgets/author_detail_widgets.dart`
```dart
AuthorDetailHeader(profile: authorProfile, onWebsite: () => {})
```
- Avatar (large initials circle)
- Name, institution, country
- H-index, i10-index, citation count
- ORCID link

### AuthorPaperCard
```dart
// Compact publication card in author detail
AuthorPaperCard(paper: paper, onTap: () => openDetail())
```

---

## 5. Search Widgets

### HomeSearchBar
**File:** `lib/widgets/home_widgets.dart`
```dart
HomeSearchBar(
  filtersActive: false,
  onTap: () => openSearch(),
  onFilterTap: () => showFilters(),
)
```
- Tappable (navigates to SearchSuggestionsScreen)
- Filter icon with active badge
- Rounded 14px, white fill

### TopicPillChip
```dart
TopicPillChip(
  label: 'Artificial Intelligence',
  isBookmarked: false,
  onTap: () => searchTopic(label),
  onBookmarkTap: () => toggleBookmark(),
)
```
- Rounded pill shape
- Bookmark icon toggle (star/bookmark)
- Accent color when bookmarked

### RecentSearchCard
```dart
RecentSearchCard(
  topic: 'Machine Learning',
  timeLabel: '2h ago',
  isBookmarked: false,
  onTap: () => searchTopic(),
  onBookmark: () => toggleBookmark(),
  onDelete: () => removeFromRecents(),
)
```
- Clock icon
- Topic text
- Time label (right)
- Delete swipe or X button

### SearchFilterSheet
**File:** `lib/widgets/search_filter_sheets.dart`
```dart
showSearchFilterSheet(context)
```
Modal bottom sheet with:
- Year range slider
- Open access toggle
- Type selector (journal/conference/etc.)
- Apply / Reset buttons

---

## 6. Chart Widgets

### TrendChart
**File:** `lib/widgets/trend_chart.dart`
```dart
TrendChart(yearlyData: Map<int, int>)
```
- `LineChart` from fl_chart
- Smooth bezier curve
- Gradient fill
- Year X-axis, count Y-axis (K/M formatted)
- Tap tooltips

### CitationBarChart
**File:** `lib/widgets/citation_bar_chart.dart`
```dart
CitationBarChart(yearlyData: Map<int, int>)
```
- `BarChart` from fl_chart
- Gradient bar fill (primary→secondary)
- Rounded top corners

### CompactTrendChart
**File:** `lib/widgets/compact_trend_chart.dart`
```dart
CompactTrendChart(yearlyData: Map<int, int>)
```
- Smaller version for card embeds
- No axis labels (space saving)

### DistributionChart
**File:** `lib/widgets/distribution_chart.dart`
```dart
DistributionChart(data: Map<String,int>, donut: false)
```
- Pie or donut chart
- Legend below (horizontal wrap)
- Tap to highlight section

### AnalyticsCharts
**File:** `lib/widgets/analytics_charts.dart`
Multiple chart widgets for the advanced analytics screen:
- `HeatmapChart`
- `NetworkGraphWidget`
- `BubbleChartWidget`
- `ScatterPlotWidget`
- `StackedAreaChart`

### ResearchLandscapeGrid
**File:** `lib/widgets/research_landscape_grid.dart`
```dart
ResearchLandscapeGrid(concepts: List<OpenAlexRankedEntity>)
```
- Treemap-style grid
- Each cell: concept name + count
- Color intensity by count

---

## 7. Loading & State Widgets

### AppLoadingView
**File:** `lib/widgets/app_loading_view.dart`
```dart
AppLoadingView(
  fillScreen: true,
  message: 'Loading publications...',
)
```
- Centered logo + progress indicator + message

### PublicationListSkeleton
**File:** `lib/widgets/publication_list_skeleton.dart`
```dart
PublicationListSkeleton(count: 3)
```
- N shimmer skeleton cards
- Animated shimmer gradient

### AnalyticsSectionSkeleton
**File:** `lib/widgets/analytics_section_skeleton.dart`
```dart
AnalyticsSectionSkeleton()
```
- Chart placeholder skeletons

### EmptyStateView
**File:** `lib/widgets/empty_state_view.dart`
```dart
EmptyStateView(
  icon: Icons.search_rounded,
  title: 'No results found',
  subtitle: 'Try a different keyword',
  actionLabel: 'Search Again',
  onAction: () => openSearch(),
)
```

### SearchEmptyState / SearchErrorState
**Files:** `lib/widgets/search_empty_state.dart`, `search_error_state.dart`
Specific states for search screen.

### ErrorBanner
**File:** `lib/widgets/error_banner.dart`
```dart
ErrorBanner(message: errorMessage, onRetry: () => reload())
```
- Red accent banner at top of content
- Error icon + message + retry button

---

## 8. Layout Widgets

### SectionHeader
**File:** `lib/widgets/home_widgets.dart`
```dart
SectionHeader(
  title: 'Latest Publications',
  trailing: TextButton(onPressed: () => seeAll(), child: Text('See all')),
)
```

### ScreenHeader
**File:** `lib/widgets/screen_header.dart`
```dart
ScreenHeader(title: 'Research Dashboard', subtitle: 'Based on OpenAlex data')
```

### LoadMoreFooter
**File:** `lib/widgets/load_more_footer.dart`
```dart
LoadMoreFooter(
  loadedCount: 20,
  totalCount: 450,
  isLoading: false,
  hasMore: true,
  onLoadMore: () => loadMore(),
)
```
- "Showing 20 of 450 results"
- Load More button or progress indicator

---

## 9. Profile Widgets

### ProfileHeaderCard
**File:** `lib/widgets/profile_widgets.dart`
```dart
ProfileHeaderCard(version: '1.0.0')
```
- App logo / Google avatar
- User name, email
- Version badge

### ProfileSection
```dart
ProfileSection(
  title: 'Account',
  children: [
    ProfileMenuRow(...),
    ProfileMenuRow(...),
  ],
)
```
- Card container with title
- Dividers between rows

### ProfileMenuRow
```dart
ProfileMenuRow(
  icon: Icons.settings_rounded,
  iconColor: AppColors.secondary,
  label: 'Settings',
  value: 'Preferences',
  onTap: () => navigate(),
)
```
- Leading colored icon container
- Title + optional value (right)
- Trailing chevron

---

## 10. Insight Widgets

### MockupCard (insight card)
**File:** `lib/widgets/app_logo.dart`
Used as generic card container throughout insight screens.

### MomentumBadge
**File:** `lib/widgets/insight_widgets.dart`
```dart
MomentumBadge(level: MomentumLevel.high)
```
- Colored badge: 🔥 High / 📈 Growing / ➡️ Stable / 📉 Declining

### YearBreakdownRow
```dart
YearBreakdownRow(
  year: 2023,
  count: 45230,
  ratio: 0.85,
  valueLabel: 'Publications',
  onTap: () => openYearDetail(),
)
```
- Year label
- Progress bar (ratio of max)
- Count value
- Tappable → YearDetailScreen

---

## 11. Ranked List Widgets

### RankedListWidgets
**File:** `lib/widgets/ranked_list_widgets.dart`
Multiple widgets for displaying ranked entities:
- `RankedAuthorTile`
- `RankedJournalTile`
- `RankedInstitutionTile`
- `RankedCountryTile`
- `RankedKeywordTile`

Each tile:
- Rank number (colored)
- Avatar/icon
- Name + count
- Bar indicator (proportion of max)

---

## 12. AppBar & Navigation

### HomeScreenAppBar
**File:** `lib/widgets/home_widgets.dart`
```dart
HomeScreenAppBar(onProfileTap: () => goToProfile())
```
- App logo (left)
- App name
- Profile avatar button (right)

### GradientSliverAppBar
Used in JournalDetail, PublicationDetail:
```dart
SliverAppBar(
  expandedHeight: 200,
  pinned: true,
  flexibleSpace: FlexibleSpaceBar(
    background: GradientHeader(
      title: name,
      subtitle: publisher,
      logoUrl: null, // initials avatar
    ),
  ),
)
```

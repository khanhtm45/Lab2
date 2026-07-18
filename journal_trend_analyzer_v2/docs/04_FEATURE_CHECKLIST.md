# Feature Checklist — Journal Trend Analyzer

> Track implementation status of every feature.
> ✅ Done  🔄 In Progress  ⬜ Todo  🔥 Firebase (planned)

---

## Navigation

| Feature | Status | Notes |
|---------|--------|-------|
| Bottom NavigationBar (4 tabs) | ✅ | MainShell |
| Home tab | ✅ | HomeScreen |
| Journal tab | ⬜ | NEW: JournalScreen (currently SearchScreen) |
| Trend tab | ✅ | TrendScreen (tab 2) |
| Profile tab | ✅ | ProfileScreen |
| IndexedStack (tab state preservation) | ✅ | |

---

## Home Screen

| Feature | Status | Notes |
|---------|--------|-------|
| App bar with logo | ✅ | HomeScreenAppBar |
| Greeting (time-based) | ⬜ | Add time-based greeting |
| Search bar | ✅ | HomeSearchBar |
| Recent searches | ✅ | RecentSearchCard |
| Suggested topics chips | ✅ | TopicPillChip |
| Bookmark topics | ✅ | toggleBookmarkTopic |
| Quick Statistics (6 cards) | ⬜ | Currently only 2 mini-cards |
| Latest Publications Carousel | ⬜ | Add horizontal carousel |
| Research Highlights section | ⬜ | 4 tiles |
| Publication Trend line chart | ⬜ | In dashboard sub-screen |
| Citation Trend line chart | ⬜ | |
| Research Landscape Treemap | ⬜ | |
| Emerging Keywords Bubble | ⬜ | |
| Latest Updates Timeline | ⬜ | |
| Recommended Research | ⬜ | |
| Floating Search Button (FAB) | ⬜ | |

---

## Journal Screen (Tab 1)

| Feature | Status | Notes |
|---------|--------|-------|
| Journal search bar | ⬜ | NEW SCREEN |
| Recent journal searches | ⬜ | |
| Popular journals chips | ⬜ | |
| Journal card list | ✅ | In TopJournalsScreen |
| Journal card: logo/avatar | ⬜ | Gradient initials avatar |
| Journal card: name, publisher | ✅ | |
| Journal card: SJR score | ⬜ | |
| Journal card: H-index | ⬜ | |
| Journal card: country | ✅ | |
| Journal card: paper/citation counts | ✅ | |
| Journal card: favorite button | ✅ | Bookmark toggle |

---

## Journal Detail Screen

| Feature | Status | Notes |
|---------|--------|-------|
| Gradient banner header | ✅ | Basic version |
| Journal logo + name | ✅ | JournalHeaderCard |
| ISSN display | ✅ | |
| Publisher | ✅ | |
| Homepage link | ⬜ | Add url_launcher |
| Description (expandable) | ⬜ | |
| Statistics grid (6 tiles) | ✅ | 4 tiles currently |
| SJR score tile | ⬜ | |
| Quartile badge tile | ⬜ | |
| Publication trend chart | ✅ | CompactTrendChart |
| Citation trend chart | ⬜ | Add bar chart |
| Top Authors (horizontal scroll) | ⬜ | |
| Top Topics chips | ⬜ | |
| Recent Volumes list | ⬜ | NEW |
| Volume cards (number, year, issues, count) | ⬜ | NEW |
| Bookmark button | ✅ | |

---

## Volume Detail Screen (NEW)

| Feature | Status | Notes |
|---------|--------|-------|
| Volume header card | ⬜ | NEW SCREEN |
| Issues list | ⬜ | Simulated from year |
| Papers in volume (from API) | ⬜ | Filter by year + journal |
| Paper cards with DOI | ⬜ | |
| Bookmark papers | ⬜ | |
| Navigate to Publication Detail | ⬜ | |

---

## Trend Screen (Tab 2)

| Feature | Status | Notes |
|---------|--------|-------|
| Keyword search box | ✅ | Via provider |
| Keyword suggestion chips | ⬜ | Add quick chips |
| Empty state | ✅ | |
| Dashboard summary (6 cards) | ⬜ | Currently embedded in other screens |
| Publication trend chart | ✅ | TrendChart |
| Citation trend chart | ✅ | CitationBarChart |
| Keyword trend (multi-line) | ⬜ | |
| Topic evolution (stacked area) | ⬜ | |
| Research Landscape treemap | ⬜ | ResearchLandscapeGrid |
| Top keywords chart | ⬜ | |
| Emerging keywords bubble | ⬜ | |
| Keyword co-occurrence network | ✅ | In AdvancedAnalytics |
| Topic network | ✅ | In AdvancedAnalytics |
| Country heatmap | ✅ | In AdvancedAnalytics |
| Institution heatmap | ✅ | In AdvancedAnalytics |
| Author productivity scatter | ✅ | In AdvancedAnalytics |
| Citation velocity chart | ✅ | In AdvancedAnalytics |
| Research frontier bubble | ✅ | In AdvancedAnalytics |
| Author ranking | ✅ | TopAuthorsScreen |
| Journal ranking | ✅ | TopJournalsScreen |
| Country ranking | ✅ | |
| Institution ranking | ✅ | |

---

## Publication Detail Screen

| Feature | Status | Notes |
|---------|--------|-------|
| Hero animation (title) | ⬜ | Add Hero widget |
| Title | ✅ | |
| Authors list | ✅ | |
| Abstract (expandable) | ✅ | |
| Journal name | ✅ | |
| Year | ✅ | |
| Citations | ✅ | |
| DOI link | ✅ | url_launcher |
| OpenAlex ID | ✅ | |
| Keywords chips | ✅ | |
| Open access badge | ✅ | |
| References list | ⬜ | |
| Related Papers | ✅ | RelatedPaperTile |
| View Original Paper button | ✅ | |
| Bookmark | ⬜ | Add bookmark for papers |
| Share button | ⬜ | |

---

## Profile Screen

| Feature | Status | Notes |
|---------|--------|-------|
| App logo / avatar | ✅ | ProfileHeaderCard |
| Google name display | 🔥 | Requires Firebase Auth |
| Email display | 🔥 | |
| Firebase UID display | 🔥 | |
| Google Sign-In button | 🔥 | |
| Bookmarked Papers list | ⬜ | Topics bookmarked, not papers |
| Bookmarked Journals list | ⬜ | |
| Bookmarked Keywords chips | ✅ | bookmarkedTopics |
| Notification Center | 🔥 | Firebase FCM |
| Export PDF | 🔥 | + Firebase Storage |
| Upload PDF → Firebase Storage | 🔥 | |
| Display uploaded PDF URL | 🔥 | |
| Remote Config: Max Journals | 🔥 | |
| Remote Config: Max Keywords | 🔥 | |
| Remote Config: Version | 🔥 | |
| Remote Config: Theme | 🔥 | |
| Crashlytics: Generate Exception | 🔥 | |
| Crashlytics: Generate Crash | 🔥 | |
| Analytics Events list | 🔥 | |
| Logout button | 🔥 | |

---

## Firebase Features

| Feature | Status | Package | Notes |
|---------|--------|---------|-------|
| Google Sign-In | 🔥 | `firebase_auth`, `google_sign_in` | Not yet |
| FCM Push Notifications | 🔥 | `firebase_messaging` | Not yet |
| Firebase Analytics | 🔥 | `firebase_analytics` | Not yet |
| Crashlytics | 🔥 | `firebase_crashlytics` | Not yet |
| Remote Config | 🔥 | `firebase_remote_config` | Not yet |
| Firebase Storage | 🔥 | `firebase_storage` | Not yet |
| google-services.json | 🔥 | — | Missing |

---

## UI Quality

| Feature | Status | Notes |
|---------|--------|-------|
| Material Design 3 | ✅ | |
| Be Vietnam Pro font | ⬜ | Currently Inter. Add to GoogleFonts |
| Card radius 20px | ⬜ | Currently 14px |
| Glassmorphism cards | ⬜ | Partial |
| Gradient AppBar | ⬜ | Add to main screens |
| Smooth animations | ⬜ | Page transitions |
| Hero animation | ⬜ | Paper → detail |
| Shimmer skeleton loading | ✅ | PublicationListSkeleton |
| Dark mode | ✅ | AppPalette.dark |
| Empty state | ✅ | EmptyStateView |
| Error state | ✅ | ErrorBanner |
| Loading state | ✅ | AppLoadingView |
| Responsive layout | ⬜ | Partial |
| Accessibility (44px targets) | ⬜ | Review all tap targets |

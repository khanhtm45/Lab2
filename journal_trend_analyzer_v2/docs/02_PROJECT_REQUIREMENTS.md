# Project Requirements — Journal Trend Analyzer

---

## 1. Application Overview

| Field | Value |
|-------|-------|
| App Name | Journal Trend Analyzer |
| Platform | Flutter (Android + iOS) |
| Purpose | Analyze scientific publications via OpenAlex API |
| Data Source | OpenAlex API only (no backend, no local DB) |
| Style | Material Design 3, Premium, Academic Dashboard |

---

## 2. Navigation

**Bottom Navigation Bar — 4 Tabs:**

| # | Tab | Icon | Screen |
|---|-----|------|--------|
| 0 | Home | `home_rounded` | HomeScreen |
| 1 | Journal | `menu_book_rounded` | JournalScreen |
| 2 | Trend | `trending_up_rounded` | TrendScreen |
| 3 | Profile | `person_rounded` | ProfileScreen |

---

## 3. HOME PAGE Requirements

- **Must NOT** display generic OpenAlex global summary as a simple stat dump
- Instead show a **modern research dashboard** related to the current search context
- When no search done, show global trending data

### Sections Required

| Section | Component |
|---------|-----------|
| Top Section | Greeting + SearchBar + RecentSearches + SuggestedTopics |
| Quick Statistics (6 cards) | Total Publications, Avg Citation, Most Active Year, Top Journal, Top Author, Trending Keyword |
| Latest Publications Carousel | Horizontal scrollable paper cards with Bookmark |
| Research Highlights | Newest, Most Influential, Trending Journal, Trending Topic |
| Charts | Publication Trend (line), Citation Trend (line), Research Landscape (treemap), Emerging Keywords (bubble) |
| Latest Updates Timeline | Vertical timeline of recent activity |
| Recommended Research | 3 publication cards |
| Floating Search Button | FAB for quick search |

---

## 4. JOURNAL PAGE Requirements

### Main Journal Screen
- Search bar for journals
- Recent searches (journal-specific)
- Popular Journals chips (horizontal scroll)
- Journal Card list (search results + browse)

### Journal Card Fields
| Field | Required |
|-------|----------|
| Cover logo / avatar | ✅ |
| Journal name | ✅ |
| Publisher | ✅ |
| SJR score | ✅ |
| H-index | ✅ |
| Country (flag) | ✅ |
| Total papers | ✅ |
| Total citations | ✅ |
| Favorite button | ✅ |

### Journal Detail Screen
| Section | Content |
|---------|---------|
| Banner/Header | Logo, name, ISSN, publisher |
| Info | Homepage URL, description |
| Statistics (6 tiles) | Publication count, Citation count, Avg citation, H-index, SJR, Quartile |
| Charts | Publication trend (line), Citation trend (bar) |
| Top Authors | Horizontal chip scroll |
| Top Topics | Wrap of chips |
| Recent Volumes | List of 5 volumes with paper counts |
| Bottom CTA | "View All Publications" button |

### Volume Detail Screen
- Volume number, year, issues count
- Issues list
- Papers list within volume
- Each paper: title, authors, citations, DOI, bookmark

---

## 5. TREND PAGE Requirements

- Single keyword analysis
- Keyword chip suggestions
- After search: comprehensive dashboard

### Dashboard Metrics (6 cards)
Publication Count · Citation Count · Top Author · Top Journal · Top Institution · Top Country

### Charts Required

| Chart | Type |
|-------|------|
| Publication Trend | Line chart (2016–present) |
| Citation Trend | Bar chart |
| Keyword Trend | Multi-line chart |
| Topic Evolution | Stacked area chart |
| Research Landscape | Treemap |
| Top Keywords | Horizontal bar chart |
| Emerging Keywords | Bubble chart |
| Keyword Co-occurrence | Network graph |
| Topic Network | Force-directed graph |
| Country Heatmap | Grid heatmap |
| Institution Heatmap | Grid heatmap |
| Author Productivity | Scatter plot (X=pubs, Y=cit) |
| Citation Velocity | Line chart (year-over-year delta) |
| Research Frontier | Bubble chart |

### Rankings (4 tabs)
Author Ranking · Journal Ranking · Country Ranking · Institution Ranking

---

## 6. PUBLICATION DETAIL Requirements

| Section | Fields |
|---------|--------|
| Hero Card | Title, authors, abstract, journal, year, citations |
| Metadata | DOI, OpenAlex ID, type, open access, language |
| Keywords | Clickable chips → Trend search |
| References | List with links |
| Related Papers | 5 items |
| Actions | View Original Paper, Bookmark, Share |

### Animations
- Hero animation: paper title from list → detail
- Smooth scroll behavior

---

## 7. PROFILE PAGE Requirements

### Identity
- Google avatar, display name, email, Firebase UID

### Bookmarks
- Bookmarked Papers (list)
- Bookmarked Journals (list)
- Bookmarked Keywords (chip wrap)

### Notification Center
- Firebase Cloud Messaging notifications
- Unread count badge

### Export PDF
- Generate PDF button
- Upload to Firebase Storage
- Display uploaded URL

### Remote Config Display
| Key | Label |
|-----|-------|
| max_journals | Maximum Journals |
| max_keywords | Maximum Keywords |
| app_version | Version |
| theme | Theme |

### Debug / Crashlytics
- Generate Exception button
- Generate Crash button

### Firebase Analytics
- List of tracked events (name, timestamp, params)

### Logout
- Red Sign Out button

---

## 8. Firebase Features Required

| Feature | Usage |
|---------|-------|
| Authentication | Google Sign-In |
| Cloud Messaging | Push notifications |
| Analytics | Event tracking (14+ events) |
| Crashlytics | Error/crash reporting |
| Remote Config | Feature flags, limits, theme |
| Storage | PDF report upload/download |

---

## 9. UI & Style Requirements

| Requirement | Specification |
|-------------|---------------|
| Design system | Material Design 3 |
| Primary color | `#2563EB` |
| Font | Be Vietnam Pro |
| Card radius | 20px |
| Shadow | Soft, multi-layer |
| Glass effect | Light glassmorphism on floating elements |
| Animations | Hero, fade-slide transitions, shimmer loading |
| Loading | Shimmer skeleton cards |
| Empty state | Illustration + message + CTA |
| Error state | Icon + message + retry button |
| Dark mode | Full dark palette support |
| Responsive | 360px–desktop breakpoints |

---

## 10. Non-Functional Requirements

- All data from OpenAlex API (dynamic, no static mock data in production)
- No backend server
- No local database (only SharedPreferences for preferences/bookmarks)
- App must work offline gracefully (show cached data or empty states)
- API requests: polite pool via `mailto` param
- Handle API rate limiting (retry with backoff)
- Minimum Android API: flutter.minSdkVersion (21)
- Target Android API: flutter.targetSdkVersion (34)
- Dart SDK: ^3.11.0

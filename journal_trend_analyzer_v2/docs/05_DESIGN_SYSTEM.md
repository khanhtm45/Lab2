# Design System — Journal Trend Analyzer

> Material Design 3 · Be Vietnam Pro · Premium Academic Dashboard

---

## 1. Color Palette

### Brand Colors

```dart
// Primary — Deep Blue (trust, academic)
const Color primary   = Color(0xFF2563EB);
const Color secondary = Color(0xFF06B6D4);   // Cyan — secondary actions
const Color accent    = Color(0xFF7C3AED);   // Violet — highlights, accents
```

### Semantic Colors

```dart
const Color success = Color(0xFF22C55E);   // Green
const Color warning = Color(0xFFF59E0B);   // Amber
const Color error   = Color(0xFFEF4444);   // Red
```

### Surface Colors

```dart
const Color background = Color(0xFFF8FAFC);  // Page background
const Color card       = Color(0xFFFFFFFF);  // Card surface
const Color surfaceMuted = Color(0xFFF1F5F9); // Subtle backgrounds
```

### Text Colors

```dart
const Color textPrimary   = Color(0xFF0F172A);  // Headings, body
const Color textSecondary = Color(0xFF64748B);  // Subtitles, captions
const Color textTertiary  = Color(0xFF94A3B8);  // Placeholders, disabled
```

### Border & Divider

```dart
const Color divider = Color(0xFFE2E8F0);
const Color border  = Color(0xFFE2E8F0);
```

### Chart Palette (ordered sequence)

```dart
static const List<Color> chartColors = [
  Color(0xFF2563EB),  // blue
  Color(0xFF06B6D4),  // cyan
  Color(0xFF7C3AED),  // violet
  Color(0xFFF59E0B),  // amber
  Color(0xFF22C55E),  // green
  Color(0xFFEF4444),  // red
  Color(0xFF6366F1),  // indigo
  Color(0xFF0D9488),  // teal
];
```

### Dark Mode Palette

```dart
background: Color(0xFF0F172A)   // Slate 900
surface:    Color(0xFF1E293B)   // Slate 800
muted:      Color(0xFF334155)   // Slate 700
primary:    Color(0xFF818CF8)   // Indigo 400 (light)
secondary:  Color(0xFF22D3EE)   // Cyan 400
accent:     Color(0xFFA78BFA)   // Violet 400
textPrimary:   Color(0xFFF8FAFC)
textSecondary: Color(0xFFCBD5E1)
border:     Color(0xFF334155)
```

---

## 2. Typography

**Font Family:** `Be Vietnam Pro` (via `google_fonts`) — headings & UI  
**Fallback:** `Inter` — body text and labels  

### Type Scale

| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| `displayLarge` | Be Vietnam Pro | 32px | 800 | Hero headings |
| `headlineLarge` | Be Vietnam Pro | 24px | 700 | Page titles |
| `headlineMedium` | Be Vietnam Pro | 20px | 700 | Section titles |
| `headlineSmall` | Be Vietnam Pro | 18px | 600 | Card titles |
| `titleMedium` | Be Vietnam Pro | 15px | 600 | List item titles |
| `titleSmall` | Be Vietnam Pro | 13px | 600 | Chips, labels |
| `bodyLarge` | Inter | 16px | 400 | Body text |
| `bodyMedium` | Inter | 14px | 400 | Secondary body |
| `bodySmall` | Inter | 12px | 400 | Captions |
| `labelSmall` | Inter | 11px | 500 | Metadata, tags |

### Letter Spacing
- Headings: `-0.4px` to `-0.2px` (tight)  
- Body: `0` (default)  
- Labels: `0.2px` (slight expansion)  

---

## 3. Spacing System

Based on **8pt grid**:

| Token | Value | Usage |
|-------|-------|-------|
| `space4` | 4px | Micro gap |
| `space8` | 8px | Inner padding, chip spacing |
| `space12` | 12px | Small gap |
| `space16` | 16px | Standard padding |
| `space20` | 20px | Page horizontal padding |
| `space24` | 24px | Section gap |
| `space32` | 32px | Large section gap |
| `space48` | 48px | Hero spacing |

---

## 4. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSmall` | 8px | Chips, tags |
| `radiusMedium` | 12px | Buttons, inputs |
| `radiusLarge` | 16px | Cards |
| `radiusXL` | 20px | Large cards, sheets |
| `radiusCircle` | 50% | Avatars, FABs |

> **Default card radius: 20px** (as specified in requirements)

---

## 5. Elevation & Shadow

### Card Shadow (Light)
```dart
BoxShadow(
  color: Color(0x0F0F172A),   // 6% opacity
  blurRadius: 16,
  offset: Offset(0, 4),
)
```

### Card Shadow (Dark)
```dart
BoxShadow(
  color: Colors.black26,
  blurRadius: 20,
  offset: Offset(0, 6),
)
```

### Glassmorphism Effect
```dart
// Glass container — AppBar, floating cards
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.72),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: child,
  ),
)
```

---

## 6. Gradient Patterns

### AppBar Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
)
```

### Hero Card Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF0891B2)],
  stops: [0.0, 0.5, 1.0],
)
```

### Accent Gradient
```dart
LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
)
```

### Success Gradient
```dart
LinearGradient(
  colors: [Color(0xFF059669), Color(0xFF22C55E)],
)
```

---

## 7. Animation Specifications

### Durations
| Name | Duration | Curve |
|------|----------|-------|
| `micro` | 100ms | `Curves.easeOut` |
| `fast` | 200ms | `Curves.easeInOut` |
| `normal` | 300ms | `Curves.easeInOut` |
| `slow` | 500ms | `Curves.easeInOut` |
| `hero` | 400ms | `Curves.fastOutSlowIn` |

### Animation Types Used
- **Hero animation** — paper card → detail screen (title, journal tag)
- **Fade + slide** — page route transitions (bottom-up slide 20px)
- **Scale** — card press feedback (0.97x)
- **Shimmer** — loading skeleton
- **Staggered list** — items animate in sequence (50ms delay each)
- **Count-up** — statistics animate from 0 to value on load

---

## 8. Component Specifications

### PremiumCard

```dart
Container(
  decoration: BoxDecoration(
    color: cardColor,                // #FFFFFF / dark surface
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: divider.withOpacity(0.6)),
    boxShadow: cardShadow,
  ),
  padding: EdgeInsets.all(16),
  child: child,
)
```

### GlassCard

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
      ),
      child: child,
    ),
  ),
)
```

### StatCard (Metric Tile)

```dart
// 2-column grid layout
Container(
  height: 96,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: subtleGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: cardShadow,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: accentColor),
      Spacer(),
      Text(value, style: valuStyle),     // Large, bold
      Text(label, style: labelStyle),    // Small, muted
    ],
  ),
)
```

### SearchBar

```dart
TextField(
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.search_rounded),
    suffixIcon: FilterButton(),
    hintText: 'Search journals, papers, authors...',
    filled: true,
    fillColor: card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: divider),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
)
```

### NavigationBar (Bottom)

```dart
NavigationBar(
  height: 68,
  selectedIndex: tabIndex,
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
      label: 'Journal',
    ),
    NavigationDestination(
      icon: Icon(Icons.trending_up_outlined),
      selectedIcon: Icon(Icons.trending_up_rounded),
      label: 'Trend',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ],
)
```

### PublicationCard

```dart
// Large, rounded, clickable paper card with hero tag
Container(
  margin: EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(20),
    boxShadow: cardShadow,
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: () => openDetail(paper),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [TypeBadge, Spacer, BookmarkButton]),
          SizedBox(height: 8),
          Text(title, maxLines: 2, style: titleStyle),
          SizedBox(height: 6),
          AuthorRow(authors),
          SizedBox(height: 8),
          Row(children: [
            JournalChip(journal),
            Spacer,
            YearBadge(year),
            CitationBadge(citations),
          ]),
        ],
      ),
    ),
  ),
)
```

### JournalCard

```dart
Container(
  margin: EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(20),
    boxShadow: cardShadow,
  ),
  child: InkWell(
    onTap: () => openJournalDetail(),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          JournalLogoAvatar(size: 52),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: titleMedium),
                Text(publisher, style: bodySmall),
                SizedBox(height: 6),
                Row(children: [
                  CountryFlag(),
                  SizedBox(width: 4),
                  Text(country),
                  Spacer,
                  SjrBadge(sjr),
                  HIndexBadge(hIndex),
                ]),
              ],
            ),
          ),
          FavoriteButton(),
        ],
      ),
    ),
  ),
)
```

---

## 9. Loading States

### Shimmer Skeleton

```dart
// Use shimmer animation for skeleton placeholders
AnimatedContainer shimmerContainer = Container(
  width: width,
  height: height,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [skeletonBase, skeletonHighlight, skeletonBase],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment(-1 + animValue * 2, 0),
      end: Alignment(animValue * 2, 0),
    ),
    borderRadius: BorderRadius.circular(radius ?? 8),
  ),
);
```

### Skeleton Card Layout

```
┌─────────────────────────────────────┐
│ ░░░░░░  ░░░░░░░░░░░░░░░░░  [░░░]   │
│                                     │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░    │
│ ░░░░░░░░░░░░░░░░░░░░░░                │
│                                     │
│ [░░░░░░░░░]     [░░░]  [░░░░]      │
└─────────────────────────────────────┘
```

---

## 10. Empty, Error & Loading States

### Empty State
- Centered illustration (SVG or icon, 80px)
- Headline: e.g., "No results found"
- Subtext: Actionable description
- Optional CTA button

### Error State
- Red icon or illustration
- Error headline
- Detail message (API error / network error)
- "Try Again" button with loading indicator

### Loading State
- Full page: centered circular progress with app logo
- List: 3–5 skeleton cards
- Charts: skeleton placeholder (rectangle with shimmer)

---

## 11. Icon Set

**Icon font:** Material Symbols Rounded (`Icons.*` with rounded style)

### Key Icons Used

| Usage | Icon |
|-------|------|
| Home | `Icons.home_rounded` |
| Journal | `Icons.menu_book_rounded` |
| Trend | `Icons.trending_up_rounded` |
| Profile | `Icons.person_rounded` |
| Search | `Icons.search_rounded` |
| Bookmark (on) | `Icons.bookmark_rounded` |
| Bookmark (off) | `Icons.bookmark_border_rounded` |
| Paper/Article | `Icons.article_outlined` |
| Citation | `Icons.format_quote_rounded` |
| Author | `Icons.person_outline_rounded` |
| Institution | `Icons.account_balance_outlined` |
| Country | `Icons.public_rounded` |
| Keyword | `Icons.tag_rounded` |
| Chart | `Icons.bar_chart_rounded` |
| Analytics | `Icons.analytics_rounded` |
| Star/Rating | `Icons.star_rounded` |
| Share | `Icons.share_rounded` |
| DOI | `Icons.link_rounded` |
| Download/PDF | `Icons.picture_as_pdf_rounded` |
| Notification | `Icons.notifications_outlined` |
| Settings | `Icons.settings_rounded` |
| Filter | `Icons.tune_rounded` |
| Calendar | `Icons.calendar_today_rounded` |
| Volume | `Icons.library_books_outlined` |
| Issue | `Icons.newspaper_rounded` |
| Logout | `Icons.logout_rounded` |

---

## 12. Chart Design Guidelines

All charts use `fl_chart` package.

### Line Chart (Trend)
- Smooth bezier curves (`isCurved: true`)
- Gradient fill below line
- Dot indicators at data points (6px, filled)
- Hover tooltip card (white, shadow, rounded 8px)
- Y-axis: formatted numbers (K/M suffix)
- X-axis: year labels

### Bar Chart (Citation / Distribution)
- Rounded top corners (4px)
- Gradient fill: primary → secondary
- Bar width: adaptive to count
- Tooltip on tap

### Pie / Donut Chart
- Donut style (center hole ratio: 0.5)
- Legend below (horizontal wrap)
- Selected section: scale 1.05
- Label: percentage + name

### Treemap (Research Landscape)
- Nested rectangles
- Color gradient by value
- Label inside (white text)
- Border: 2px white separator

### Bubble Chart
- Circle size = publication count
- Color = topic/category
- Animated on load (scale 0 → 1)

### Scatter Plot (Author Productivity)
- X = publications, Y = citations
- Color = institution or country
- Size = h-index
- Tooltip on tap

### Heatmap
- Grid of colored cells
- Color scale: white → primary blue
- Row labels on left, column labels on bottom
- Cell value tooltip on tap

---

## 13. Responsive Breakpoints

| Width | Layout |
|-------|--------|
| < 360px | Compact: single column, smaller padding |
| 360–600px | Standard mobile: `pagePadding = 20px` |
| 600–900px | Tablet: `pagePadding = 32px`, 2-col grids → 3-col |
| > 900px | Desktop: `pagePadding = 48px`, sidebar nav |

---

## 14. Accessibility

- Minimum tap target: **44×44px**
- Color contrast: all text ≥ 4.5:1 WCAG AA
- Semantic labels on all icons
- Focus indicators enabled
- Screen reader support via `Semantics` widget on custom widgets

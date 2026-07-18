# Screen Implementation Guide — Journal Trend Analyzer

> Flutter implementation patterns for each screen.
> Uses existing providers, services, and widgets.

---

## 1. Main Shell (Tab Navigation)

**File:** `lib/screens/main_shell.dart`

```dart
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 4 permanent tab screens — use IndexedStack for state preservation
  static const _pages = [
    HomeScreen(),
    JournalScreen(),   // NEW: replaces SearchScreen in tab
    TrendScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationProvider>();
    return Scaffold(
      body: IndexedStack(index: nav.tabIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.tabIndex,
        onDestinationSelected: nav.goToTab,
        destinations: const [
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
      ),
    );
  }
}
```

---

## 2. Home Screen Implementation Notes

**File:** `lib/screens/home_screen.dart`

### Key Patterns

**Greeting (time-based):**
```dart
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
```

**Quick Stats Grid:**
```dart
// 2-column GridView inside ListView
GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  childAspectRatio: 1.4,
  children: [
    QuickStatCard(
      value: provider.formattedTotalOnOpenAlex,
      label: 'Total Publications',
      icon: Icons.article_outlined,
      color: AppColors.primary,
    ),
    QuickStatCard(
      value: provider.averageCitationOpenAlex.toStringAsFixed(1),
      label: 'Average Citations',
      icon: Icons.format_quote_rounded,
      color: AppColors.citationAmber,
    ),
    // ... 4 more
  ],
)
```

**Latest Publications Carousel:**
```dart
SizedBox(
  height: 180,
  child: PageView.builder(
    controller: PageController(viewportFraction: 0.85),
    itemCount: papers.length,
    itemBuilder: (context, index) => Padding(
      padding: EdgeInsets.only(right: 12),
      child: PaperCarouselCard(
        paper: papers[index],
        onTap: () => openPaperDetail(papers[index]),
      ),
    ),
  ),
)
```

**Research Highlights Tiles:**
```dart
Column(
  children: [
    HighlightTile(
      label: 'Newest Paper',
      value: provider.topPapersOpenAlex.isNotEmpty
          ? provider.topPapersOpenAlex.first.title
          : 'No data',
      icon: Icons.new_releases_outlined,
      color: AppColors.primary,
    ),
    HighlightTile(
      label: 'Most Influential',
      value: provider.topPaperLabel,
      icon: Icons.emoji_events_outlined,
      color: AppColors.citationAmber,
    ),
    HighlightTile(
      label: 'Trending Journal',
      value: provider.topJournalLabel,
      icon: Icons.menu_book_rounded,
      color: AppColors.secondary,
    ),
    HighlightTile(
      label: 'Trending Topic',
      value: provider.topTopicLabel,
      icon: Icons.tag_rounded,
      color: AppColors.accent,
    ),
  ],
)
```

---

## 3. Journal Screen (NEW — Tab 1)

**File:** `lib/screens/journal_screen.dart` *(create new)*

```dart
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _searchController = TextEditingController();
  List<OpenAlexRankedEntity> _results = [];
  bool _loading = false;
  String? _error;

  // Popular journal seeds
  static const _popular = [
    'Nature', 'Science', 'The Lancet', 'Cell',
    'PLOS ONE', 'IEEE Access', 'Physical Review',
  ];

  // Recent journal searches stored in SharedPreferences
  List<String> _recentJournalSearches = [];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final provider = context.read<PublicationProvider>();
      // Search journals via group_by on source
      final results = await provider.openAlexService
          .fetchWorksGroupedCounts(
            groupBy: OpenAlexService.groupByJournal,
            search: query,
            limit: 20,
          );
      setState(() { _results = results; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _openJournalDetail(OpenAlexRankedEntity journal) {
    final provider = context.read<PublicationProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalDetailScreen(
          journal: journal,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Journals',
              style: Theme.of(context).textTheme.headlineLarge),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _searchController,
              onSubmitted: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search journals by name, ISSN...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => _search(_searchController.text),
                ),
              ),
            ),
          ),
          // Popular chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              scrollDirection: Axis.horizontal,
              itemCount: _popular.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ActionChip(
                label: Text(_popular[i]),
                onPressed: () {
                  _searchController.text = _popular[i];
                  _search(_popular[i]);
                },
              ),
            ),
          ),
          // Results
          Expanded(
            child: _loading
                ? const PublicationListSkeleton(count: 4)
                : _error != null
                    ? ErrorBanner(message: _error!, onRetry: () => _search(_searchController.text))
                    : _results.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                            itemCount: _results.length,
                            itemBuilder: (_, i) => _JournalCard(
                              journal: _results[i],
                              onTap: () => _openJournalDetail(_results[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => EmptyStateView(
    icon: Icons.menu_book_outlined,
    title: 'Find Journals',
    subtitle: 'Search by journal name, publisher, or topic',
  );
}
```

---

## 4. Journal Detail Screen Patterns

**File:** `lib/screens/journal_detail_screen.dart`

### Key Pattern — Collapsing AppBar with Gradient Banner:
```dart
Scaffold(
  body: NestedScrollView(
    headerSliverBuilder: (context, _) => [
      SliverAppBar(
        expandedHeight: 200,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: _buildGradientBanner(),
        ),
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: Colors.white,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: _share,
          ),
        ],
      ),
    ],
    body: _buildBody(),
  ),
)

Widget _buildGradientBanner() => Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFF1E40AF), const Color(0xFF0891B2)],
    ),
  ),
  child: SafeArea(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _JournalLogoAvatar(name: journalName, size: 64),
        const SizedBox(height: 12),
        Text(journalName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        Text(publisher,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    ),
  ),
)
```

---

## 5. Volume Detail Screen (NEW)

**File:** `lib/screens/volume_detail_screen.dart`

```dart
class VolumeDetailScreen extends StatelessWidget {
  final String journalName;
  final int volumeNumber;
  final int year;
  final PublicationProvider provider;
  final OpenAlexRankedEntity journal;

  const VolumeDetailScreen({
    super.key,
    required this.journalName,
    required this.volumeNumber,
    required this.year,
    required this.provider,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vol. $volumeNumber ($year)'),
        leading: const BackButton(),
      ),
      body: _VolumeBody(
        journal: journal,
        year: year,
        provider: provider,
      ),
    );
  }
}

class _VolumeBody extends StatefulWidget {
  // ... loads papers for journal filtered by year
}
```

### Loading papers by year for volume:
```dart
// Reuse existing: provider.loadWorksByJournalPage with year filter
Future<void> _loadPapers() async {
  final result = await provider.openAlexService.fetchWorksBySourceIdPage(
    sourceId: journal.id,
    page: 1,
    search: 'publication_year:$year',
  );
  setState(() => _papers = result.publications);
}
```

---

## 6. Trend Screen Implementation Notes

**File:** `lib/screens/trend_screen.dart`

### New Structure (expanded)
The current TrendScreen is a general trend view. The new requirement specifies it should analyze ONE keyword entered by the user. The recommended approach:

1. **Keep existing TrendScreen** for the `AnalysisTabScreen` embedded use
2. **Add a dedicated keyword search** at the top
3. **After search**, show the full dashboard (metrics + all charts + rankings)

```dart
// Top section of TrendScreen
Widget _buildTopSearch() => Padding(
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Trend Analysis',
        style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12),
      TextField(
        controller: _keywordController,
        onSubmitted: _analyzeTrend,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.analytics_outlined),
          hintText: 'Enter a keyword to analyze...',
          suffixIcon: FilledButton(
            onPressed: () => _analyzeTrend(_keywordController.text),
            child: const Text('Analyze'),
          ),
        ),
      ),
      const SizedBox(height: 12),
      // Quick keyword chips
      _buildKeywordChips(),
    ],
  ),
)

static const _suggestedKeywords = [
  'Artificial Intelligence', 'IoT', 'Blockchain',
  'Machine Learning', 'Deep Learning', 'NLP',
];
```

### Dashboard Summary Row (scrollable cards)
```dart
SizedBox(
  height: 110,
  child: ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    scrollDirection: Axis.horizontal,
    itemCount: 6,
    separatorBuilder: (_, __) => const SizedBox(width: 10),
    itemBuilder: (_, i) {
      final items = [
        ('Publications', provider.formattedTotalOnOpenAlex, Icons.article_outlined, AppColors.primary),
        ('Avg Citations', provider.averageCitationOpenAlex.toStringAsFixed(1), Icons.format_quote_rounded, AppColors.citationAmber),
        ('Top Author', provider.topAuthorLabel, Icons.person_outline_rounded, AppColors.accent),
        ('Top Journal', provider.topJournalLabel, Icons.menu_book_outlined, AppColors.secondary),
        // ... institutions, countries
      ];
      final item = items[i];
      return _DashboardMetricCard(
        label: item.$1, value: item.$2,
        icon: item.$3, color: item.$4,
      );
    },
  ),
)
```

---

## 7. Publication Detail Screen (Hero Animation)

**File:** `lib/screens/detail_screen.dart`

### Hero transition from list:
```dart
// In PublicationCard:
Hero(
  tag: 'paper-${paper.id}',
  child: Text(paper.title, style: titleStyle, maxLines: 2),
)

// In DetailScreen:
Hero(
  tag: 'paper-${paper.id}',
  child: Text(paper.title, style: detailTitleStyle),
)
```

### Abstract decoding:
```dart
// OpenAlex returns abstract as inverted index
// Decode in Publication model:
static String _decodeAbstract(Map<String, dynamic>? index) {
  if (index == null) return '';
  final positions = <int, String>{};
  index.forEach((word, posList) {
    for (final pos in posList as List) {
      positions[pos as int] = word;
    }
  });
  final sorted = positions.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return sorted.map((e) => e.value).join(' ');
}
```

---

## 8. Profile Screen — Firebase Integration Points

**File:** `lib/screens/profile_screen.dart`

### Google Sign-In section:
```dart
// When user not logged in:
FilledButton.icon(
  icon: SvgPicture.asset('assets/google_logo.svg', width: 20),
  label: const Text('Sign in with Google'),
  onPressed: () => context.read<AuthProvider>().signInWithGoogle(),
)

// When logged in:
Row(
  children: [
    CircleAvatar(
      backgroundImage: NetworkImage(user.photoURL ?? ''),
      radius: 32,
    ),
    const SizedBox(width: 16),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.displayName ?? ''),
        Text(user.email ?? '', style: captionStyle),
        SelectableText(user.uid, style: monoStyle),
      ],
    ),
  ],
)
```

### Remote Config display:
```dart
FutureBuilder<RemoteConfigValues>(
  future: RemoteConfigService.getAll(),
  builder: (context, snapshot) {
    final config = snapshot.data;
    return ProfileSection(
      title: 'App Configuration',
      children: [
        ConfigRow('Max Journals', '${config?.maxJournals ?? 50}'),
        ConfigRow('Max Keywords', '${config?.maxKeywords ?? 20}'),
        ConfigRow('Version', config?.appVersion ?? '1.0.0'),
        ConfigRow('Theme', config?.theme ?? 'light'),
      ],
    );
  },
)
```

---

## 9. Animations Reference

### Page Transition (bottom-up slide)
```dart
PageRouteBuilder(
  pageBuilder: (_, animation, __) => const MyScreen(),
  transitionsBuilder: (_, animation, __, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(opacity: animation, child: child),
    );
  },
  transitionDuration: const Duration(milliseconds: 280),
)
```

### Staggered list items
```dart
AnimationLimiter(
  child: ListView.builder(
    itemBuilder: (context, index) =>
        AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 24,
            child: FadeInAnimation(child: MyListItem()),
          ),
        ),
  ),
)
// Package: flutter_staggered_animations (optional)
```

### Count-up animation for stats
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: targetValue.toDouble()),
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeOut,
  builder: (context, value, _) =>
      Text(formatOpenAlexCount(value.toInt()), style: statStyle),
)
```

---

## 10. Dark Mode Checklist

When adding any new widget, ensure:

- [ ] Use `context.palette.textPrimary` instead of `AppColors.textPrimary`
- [ ] Use `context.palette.surface` instead of `Colors.white`
- [ ] Use `context.palette.background` instead of `AppColors.background`
- [ ] Use `context.palette.border` instead of `AppColors.border`
- [ ] Gradient colors: adjust opacity for dark mode
- [ ] Shadow opacity: higher in dark mode (`Colors.black38` vs `Colors.black12`)
- [ ] Icons: inherit color from `IconTheme` or use `palette.textPrimary`
- [ ] Charts: use `chartSeriesColors(palette)` helper from `app_theme.dart`

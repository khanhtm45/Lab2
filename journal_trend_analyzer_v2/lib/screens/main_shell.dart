import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import '../firebase/crashlytics_service.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'keywords_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _pages = [
    HomeScreen(),
    JournalScreen(),
    KeywordsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    CrashlyticsService.recordScreenView('MainShell');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PublicationProvider>();
      if (!provider.hasData && !provider.isDashboardLoading) {
        provider.loadDefaultDashboard();
      }
      provider.loadRecentSearches();
      provider.loadBookmarkedTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationProvider>();
    final s   = context.strings;

    return Scaffold(
      body: IndexedStack(
        index: nav.tabIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.tabIndex,
        onDestinationSelected: (index) {
          context.read<AppNavigationProvider>().goToTab(index);
        },
        destinations: [
          NavigationDestination(
            icon:         const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label:        s.tabHome,
          ),
          NavigationDestination(
            icon:         const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label:        'Journals',
          ),
          NavigationDestination(
            icon:         const Icon(Icons.label_outlined),
            selectedIcon: const Icon(Icons.label_rounded),
            label:        'Keywords',
          ),
          NavigationDestination(
            icon:         const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label:        s.tabProfile,
          ),
        ],
      ),
    );
  }
}

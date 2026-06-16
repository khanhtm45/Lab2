import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_navigation_provider.dart';
import '../providers/publication_provider.dart';
import 'about_screen.dart';
import 'explore_screen.dart';
import 'insights_screen.dart';
import 'overview_screen.dart';
import 'search_screen.dart';
import 'trend_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _pages = [
    OverviewScreen(),
    SearchScreen(),
    TrendScreen(),
    InsightsScreen(),
    ExploreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PublicationProvider>();
      if (!provider.hasData && !provider.isDashboardLoading) {
        provider.loadDefaultDashboard();
      }
      provider.loadRecentSearches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationProvider>();

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Trends',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
      ),
      floatingActionButton: nav.tabIndex == 0
          ? FloatingActionButton.small(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
              tooltip: 'About',
              child: const Icon(Icons.info_outline, size: 20),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'explore_screen.dart';
import 'insights_screen.dart';
import 'trend_screen.dart';

/// Analysis tab — Trends, Insights, and Explore in one premium surface.
class AnalysisTabScreen extends StatelessWidget {
  const AnalysisTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumAppBar(
              title: s.tabAnalysis,
              subtitle: s.trendsAndInsights,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppDimens.cardShadow,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: [
                    Tab(text: s.trends),
                    Tab(text: s.insights),
                    Tab(text: s.explore),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: TabBarView(
                children: [
                  TrendScreen(embedded: true),
                  InsightsScreen(embedded: true),
                  ExploreScreen(embedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

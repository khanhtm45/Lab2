import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../models/research_insight.dart';
import '../providers/publication_provider.dart';
import '../services/app_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../utils/research_insights.dart';
import '../widgets/app_logo.dart';
import '../widgets/search_filter_sheets.dart';
import '../widgets/trend_chart.dart';
import '../widgets/year_activity_sheet.dart';
import 'year_detail_screen.dart';

enum TrendPeriod { fiveYear, sevenYear, allTime }

/// Publication trend analysis — full chart and insights for the active topic.
class PublicationTrendsScreen extends StatefulWidget {
  const PublicationTrendsScreen({super.key});

  @override
  State<PublicationTrendsScreen> createState() =>
      _PublicationTrendsScreenState();
}

@Deprecated('Use PublicationTrendsScreen')
typedef GrowthScreen = PublicationTrendsScreen;

class _PublicationTrendsScreenState extends State<PublicationTrendsScreen> {
  late TrendPeriod _period;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<AppPreferences>();
    _period = switch (prefs.trendRange) {
      AppTrendRange.fiveYears => TrendPeriod.fiveYear,
      AppTrendRange.sevenYears => TrendPeriod.sevenYear,
      AppTrendRange.allTime => TrendPeriod.allTime,
    };
  }

  Map<int, int> _filterTrend(Map<int, int> source) {
    if (source.isEmpty) return source;
    final currentYear = DateTime.now().year;
    final startYear = switch (_period) {
      TrendPeriod.fiveYear => currentYear - 4,
      TrendPeriod.sevenYear => currentYear - 6,
      TrendPeriod.allTime => source.keys.reduce((a, b) => a < b ? a : b),
    };
    return Map.fromEntries(
      source.entries.where((e) => e.key >= startYear),
    );
  }

  String _growthSinceStart(Map<int, int> trend) {
    if (trend.isEmpty) return 'N/A';
    final years = trend.keys.toList()..sort();
    final startCount = trend[years.first] ?? 0;
    final endCount = trend[years.last] ?? 0;
    if (startCount <= 0) return endCount > 0 ? '+100%' : '0%';
    final change = ((endCount - startCount) / startCount) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.round()}%';
  }

  int _peakCount(Map<int, int> trend) {
    if (trend.isEmpty) return 0;
    return trend.entries.reduce((a, b) => a.value >= b.value ? a : b).value;
  }

  int _peakYear(Map<int, int> trend) {
    if (trend.isEmpty) return 0;
    return trend.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _periodSubtitle(AppStrings s, Map<int, int> trend) {
    if (trend.isEmpty) return s.publicationActivityDefault;
    final years = trend.keys.toList()..sort();
    return s.publicationActivityFromTo(years.first, years.last);
  }

  String _trendInsightText(TrendInsight insight) {
    if (insight.summary.isNotEmpty) return insight.summary;
    return insight.headline;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final provider = context.watch<PublicationProvider>();
    final topic = provider.isGlobalScope
        ? 'Artificial Intelligence'
        : provider.currentTopic;
    final trend = _filterTrend(provider.yearlyTrendFromOpenAlex);
    final insight = ResearchInsights.analyzeTrend(
      strings: s,
      volumeByYear: trend,
      topicLabel: topic,
    );
    final peakYear = _peakYear(trend);
    final peakCount = _peakCount(trend);
    final firstYear = trend.keys.isEmpty
        ? null
        : (trend.keys.toList()..sort()).first;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.publicationTrendsTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: provider.searchFilters.isActive
                  ? AppColors.secondary
                  : AppColors.textSecondary,
            ),
            onPressed: () => showSearchFilterSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            topic,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _periodSubtitle(s, trend),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _PeriodSelector(
            selected: _period,
            onChanged: (period) => setState(() => _period = period),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.publicationsByYear,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                trend.isEmpty
                    ? SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            s.noTrendData,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : TrendChart(
                        yearlyData: trend,
                        height: 260,
                        lineColor: AppColors.analyticsTeal,
                        dotColor: AppColors.secondary,
                        onYearTapped: (year) => showYearActivitySheet(
                          context,
                          year,
                          publicationCountHint: trend[year],
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  label: s.peakYear,
                  value: peakYear > 0 ? '$peakYear' : s.na,
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightCard(
                  label: s.peakPublications,
                  value: peakCount > 0
                      ? formatOpenAlexCount(peakCount)
                      : s.na,
                  accentColor: AppColors.analyticsTeal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightCard(
                  label: firstYear != null
                      ? s.growthSinceYear(firstYear)
                      : s.growth,
                  value: _growthSinceStart(trend),
                  accentColor: AppColors.citationAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PremiumCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.trendInsight,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _trendInsightText(insight),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: peakYear > 0
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YearDetailScreen(
                            year: peakYear,
                            provider: provider,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(
                peakYear > 0
                    ? s.viewPublicationsFromYear(peakYear)
                    : s.viewPublications,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final TrendPeriod selected;
  final ValueChanged<TrendPeriod> onChanged;

  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TrendPeriod.values.map((period) {
          final active = selected == period;
          final label = switch (period) {
            TrendPeriod.fiveYear => s.fiveYears,
            TrendPeriod.sevenYear => s.sevenYears,
            TrendPeriod.allTime => s.allTime,
          };
          return Expanded(
            child: Material(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: () => onChanged(period),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: active ? AppDimens.cardShadow : null,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color:
                          active ? AppColors.secondary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

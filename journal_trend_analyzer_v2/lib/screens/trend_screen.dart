import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../utils/research_insights.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import '../widgets/insight_widgets.dart';
import '../widgets/citation_bar_chart.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/trend_chart.dart';
import 'year_detail_screen.dart';

enum TrendMetric {
  publications,
  citationImpact,
  avgCitations,
}

extension TrendMetricX on TrendMetric {
  String labelFor(AppStrings s) {
    switch (this) {
      case TrendMetric.publications:
        return s.publicationVolume;
      case TrendMetric.citationImpact:
        return s.citations;
      case TrendMetric.avgCitations:
        return s.avgCitations;
    }
  }
}

class TrendScreen extends StatefulWidget {
  final bool embedded;

  const TrendScreen({super.key, this.embedded = false});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  TrendMetric _metric = TrendMetric.publications;
  int? _yearRange; // null = All, 5, 10

  Map<int, int> _dataForMetric(PublicationProvider provider) {
    Map<int, int> raw;
    switch (_metric) {
      case TrendMetric.publications:
        raw = provider.yearlyTrendFromOpenAlex;
      case TrendMetric.citationImpact:
        raw = provider.citationsByYearOpenAlex;
      case TrendMetric.avgCitations:
        raw = provider.avgCitationsByYearOpenAlex;
    }
    if (_yearRange == null) return raw;
    final cutoff = DateTime.now().year - _yearRange! + 1;
    return Map.fromEntries(raw.entries.where((e) => e.key >= cutoff));
  }

  String _metricValueLabel(AppStrings s) {
    switch (_metric) {
      case TrendMetric.publications:
        return s.metricPublications;
      case TrendMetric.citationImpact:
        return s.metricTotalCitations;
      case TrendMetric.avgCitations:
        return s.metricAvgCitations;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PublicationProvider>();
    final s = context.strings;
    final palette = context.palette;

    if (provider.isDashboardLoading && !provider.hasData) {
      return AppLoadingView(
        fillScreen: false,
        expand: true,
        message: s.loadingTrends,
      );
    }

    if (!provider.hasData) {
      return Center(child: Text(s.openHomeFirst));
    }

    final yearlyData = _dataForMetric(provider);
    final sortedYears = yearlyData.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final maxCount = yearlyData.values.isEmpty
        ? 1
        : yearlyData.values.reduce((a, b) => a > b ? a : b);
    final insight = provider.trendInsight;

    final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                s.trends,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 22,
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Wrap(
              spacing: 8,
              children: [
                _PeriodChip(
                  label: s.period5Y,
                  selected: _yearRange == 5,
                  onSelected: () => setState(() => _yearRange = 5),
                ),
                _PeriodChip(
                  label: s.period10Y,
                  selected: _yearRange == 10,
                  onSelected: () => setState(() => _yearRange = 10),
                ),
                _PeriodChip(
                  label: s.periodAll,
                  selected: _yearRange == null,
                  onSelected: () => setState(() => _yearRange = null),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SegmentedButton<TrendMetric>(
              segments: TrendMetric.values
                  .map(
                    (m) => ButtonSegment(
                      value: m,
                      label: Text(m.labelFor(s), style: const TextStyle(fontSize: 11)),
                    ),
                  )
                  .toList(),
              selected: {_metric},
              onSelectionChanged: (value) {
                setState(() => _metric = value.first);
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  '${_metric.labelFor(s)} ${s.overTime}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.isGlobalScope
                      ? s.globalResearchOpenAlex
                      : provider.currentTopic,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                if (yearlyData.isEmpty)
                  Text(
                    s.noChartData,
                    style: TextStyle(color: palette.textSecondary),
                  )
                else if (_metric == TrendMetric.citationImpact)
                  MockupCard(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                    child: CitationBarChart(yearlyData: yearlyData),
                  )
                else
                  MockupCard(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                    child: TrendChart(yearlyData: yearlyData),
                  ),
                const SizedBox(height: 24),
                Text(
                  s.publicationTypeDistribution,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: palette.textPrimary),
                ),
                const SizedBox(height: 12),
                MockupCard(
                  child: DistributionChart(data: provider.typeDistribution),
                ),
                const SizedBox(height: 20),
                Text(
                  s.openAccessRatio,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: palette.textPrimary),
                ),
                const SizedBox(height: 12),
                MockupCard(
                  child: DistributionChart(
                    data: provider.oaDistribution,
                    donut: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  s.languageDistribution,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: palette.textPrimary),
                ),
                const SizedBox(height: 12),
                MockupCard(
                  child: DistributionChart(data: provider.languageDistribution),
                ),
                const SizedBox(height: 16),
                MockupCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            s.researchMomentum,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: palette.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          MomentumBadge(level: insight.momentum),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ResearchInsights.formatGrowth(insight.periodGrowthPercent),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        s.periodGrowthVolume,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: s.annualGrowth,
                              value: ResearchInsights.formatGrowth(
                                insight.avgAnnualGrowthPercent,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _MiniStat(
                              label: s.peakYear,
                              value: '${insight.peakYear}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        insight.headline,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.yearlyBreakdown,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.countPerYear(_metricValueLabel(s)),
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                MockupCard(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    children: sortedYears
                        .map(
                          (entry) => YearBreakdownRow(
                            year: entry.key,
                            count: entry.value,
                            ratio: entry.value / maxCount,
                            valueLabel: _metricValueLabel(s),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => YearDetailScreen(
                                  year: entry.key,
                                  provider: provider,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

    return widget.embedded ? content : SafeArea(child: content);
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      checkmarkColor: palette.secondary,
      backgroundColor: palette.surface,
      selectedColor: palette.secondary.withValues(alpha: 0.14),
      side: BorderSide(
        color: selected ? palette.secondary : palette.border,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? palette.secondary : palette.textPrimary,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

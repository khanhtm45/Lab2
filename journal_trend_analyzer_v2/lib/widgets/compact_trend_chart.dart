import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../utils/chart_axis.dart';
import '../utils/count_format.dart';

/// Compact publication trend line chart for dashboard cards.
class CompactTrendChart extends StatelessWidget {
  final Map<int, int> yearlyData;
  final ValueChanged<int>? onYearTapped;

  const CompactTrendChart({
    super.key,
    required this.yearlyData,
    this.onYearTapped,
  });

  void _onChartTouch(
    FlTouchEvent event,
    LineTouchResponse? response,
    TrendChartLayout layout,
  ) {
    if (onYearTapped == null) return;
    if (event is! FlTapUpEvent) return;
    final barSpots = response?.lineBarSpots;
    if (barSpots == null || barSpots.isEmpty) return;
    final index = barSpots.first.spotIndex;
    if (index < 0 || index >= layout.years.length) return;
    onYearTapped!(layout.years[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            context.strings.noTrendData,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    final layout = TrendChartLayout.fromYearlyCounts(yearlyData);
    final spots = <FlSpot>[];
    for (var i = 0; i < layout.years.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), yearlyData[layout.years[i]]!.toDouble()),
      );
    }

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (layout.years.length - 1).toDouble(),
          minY: layout.chartMinY,
          maxY: layout.chartMaxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: layout.yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border.withValues(alpha: 0.7),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (event, response) =>
                _onChartTouch(event, response, layout),
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (tooltipSpots) {
                return tooltipSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= layout.years.length) return null;
                  return LineTooltipItem(
                    '${layout.years[index]}\n${formatOpenAlexCount(spot.y.toInt())}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: layout.years.length > 2,
              curveSmoothness: 0.22,
              color: AppColors.analyticsTeal,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.analyticsTeal.withValues(alpha: 0.18),
                    AppColors.analyticsTeal.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 ||
                      index >= layout.years.length ||
                      index % layout.labelInterval != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${layout.years[index]}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

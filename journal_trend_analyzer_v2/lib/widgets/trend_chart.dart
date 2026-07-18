import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../utils/chart_axis.dart';
import '../utils/count_format.dart';

/// Line chart — trục X theo thứ tự năm, không hiển thị label trên đỉnh (tránh chồng chữ).
class TrendChart extends StatelessWidget {
  final Map<int, int> yearlyData;
  final double height;
  final Color lineColor;
  final Color dotColor;
  final ValueChanged<int>? onYearTapped;

  const TrendChart({
    super.key,
    required this.yearlyData,
    this.height = 280,
    this.lineColor = AppColors.analyticsTeal,
    this.dotColor = AppColors.analyticsTeal,
    this.onYearTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            context.strings.noTrendData,
            style: const TextStyle(color: AppColors.textSecondary),
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
      height: height,
      child: LineChart(_buildChartData(layout, spots)),
    );
  }

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

  LineChartData _buildChartData(TrendChartLayout layout, List<FlSpot> spots) {
    return LineChartData(
      minX: 0,
      maxX: (layout.years.length - 1).toDouble(),
      minY: layout.chartMinY,
      maxY: layout.chartMaxY,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: layout.yInterval,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: AppColors.border,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchCallback: (event, response) => _onChartTouch(event, response, layout),
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (tooltipSpots) {
            return tooltipSpots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= layout.years.length) {
                return null;
              }
              return LineTooltipItem(
                '${layout.years[index]}\n${formatOpenAlexCount(spot.y.toInt())}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
          curveSmoothness: 0.2,
          color: lineColor,
          barWidth: 2.5,
          dotData: FlDotData(
            show: layout.years.length <= 12,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: dotColor,
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
                lineColor.withValues(alpha: 0.16),
                lineColor.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
      titlesData: _buildTitles(layout),
    );
  }

  FlTitlesData _buildTitles(TrendChartLayout layout) {
    return FlTitlesData(
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 ||
                index >= layout.years.length ||
                index % layout.labelInterval != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${layout.years[index]}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: layout.yInterval,
          getTitlesWidget: (value, meta) {
            if (value < layout.chartMinY || value > layout.chartMaxY) {
              return const SizedBox.shrink();
            }
            return Text(
              formatOpenAlexCount(value.toInt()),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/chart_axis.dart';
import '../utils/count_format.dart';

/// Line chart — trục X theo thứ tự năm, không hiển thị label trên đỉnh (tránh chồng chữ).
class TrendChart extends StatelessWidget {
  final Map<int, int> yearlyData;

  const TrendChart({
    super.key,
    required this.yearlyData,
  });

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No trend data available',
            style: TextStyle(color: AppColors.textSecondary),
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
      height: 280,
      child: LineChart(_buildChartData(layout, spots)),
    );
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
          color: AppColors.primary,
          barWidth: 2.5,
          dotData: FlDotData(
            show: layout.years.length <= 12,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 3.5,
              color: AppColors.primary,
              strokeWidth: 0,
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

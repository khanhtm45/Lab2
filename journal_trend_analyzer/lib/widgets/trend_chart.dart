import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/count_format.dart';

class _TrendChartLayout {
  const _TrendChartLayout({
    required this.years,
    required this.spots,
    required this.chartMinY,
    required this.chartMaxY,
    required this.yInterval,
    required this.labelInterval,
  });

  final List<int> years;
  final List<FlSpot> spots;
  final double chartMinY;
  final double chartMaxY;
  final double yInterval;
  final int labelInterval;

  factory _TrendChartLayout.from(Map<int, int> yearlyData) {
    final years = yearlyData.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < years.length; i++) {
      spots.add(FlSpot(i.toDouble(), yearlyData[years[i]]!.toDouble()));
    }

    final maxY = yearlyData.values.reduce(math.max).toDouble();
    final minY = yearlyData.values.reduce(math.min).toDouble();
    final range = maxY - minY;
    final padding = range > 0 ? range * 0.15 : math.max(1.0, maxY.abs() * 0.1);

    var chartMinY = minY - padding;
    var chartMaxY = maxY + padding;
    if (minY >= 0 && chartMinY < 0) chartMinY = 0;
    if (chartMaxY <= chartMinY) chartMaxY = chartMinY + 1;

    return _TrendChartLayout(
      years: years,
      spots: spots,
      chartMinY: chartMinY,
      chartMaxY: chartMaxY,
      yInterval: _niceInterval(chartMaxY - chartMinY),
      labelInterval: years.length <= 6 ? 1 : (years.length / 5).ceil(),
    );
  }
}

double _niceInterval(double range) {
  if (range <= 0) return 1;
  final raw = range / 4;
  final magnitude =
      _pow10(raw.floor().toString().length - 1).clamp(1, 1000000000);
  final normalized = raw / magnitude;
  double nice;
  if (normalized <= 1) {
    nice = 1;
  } else if (normalized <= 2) {
    nice = 2;
  } else if (normalized <= 5) {
    nice = 5;
  } else {
    nice = 10;
  }
  return nice * magnitude;
}

double _pow10(int exponent) {
  var value = 1.0;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}

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

    final layout = _TrendChartLayout.from(yearlyData);

    return SizedBox(
      height: 280,
      child: LineChart(_buildChartData(layout)),
    );
  }

  LineChartData _buildChartData(_TrendChartLayout layout) {
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
          getTooltipItems: (spots) {
            return spots.map((spot) {
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
          spots: layout.spots,
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

  FlTitlesData _buildTitles(_TrendChartLayout layout) {
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

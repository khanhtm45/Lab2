import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';

/// Bar chart — citation count by year (spec Trends / Dashboard)
class CitationBarChart extends StatelessWidget {
  final Map<int, int> yearlyData;

  const CitationBarChart({super.key, required this.yearlyData});

  @override
  Widget build(BuildContext context) {
    final years = yearlyData.keys.toList()..sort();
    if (years.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            context.strings.noCitationData,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxY = yearlyData.values.reduce((a, b) => a > b ? a : b).toDouble();
    final chartMaxY = maxY * 1.15;
    final labelInterval = years.length <= 6 ? 1 : (years.length / 5).ceil();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: chartMaxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final year = years[group.x.toInt()];
                return BarTooltipItem(
                  '$year\n${formatOpenAlexCount(rod.toY.toInt())}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 ||
                      index >= years.length ||
                      index % labelInterval != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${years[index]}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value > chartMaxY) return const SizedBox.shrink();
                  return Text(
                    formatOpenAlexCount(value.toInt()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < years.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: yearlyData[years[i]]!.toDouble(),
                    color: AppColors.primary,
                    width: years.length > 12 ? 8 : 14,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

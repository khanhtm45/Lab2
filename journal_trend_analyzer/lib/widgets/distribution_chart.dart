import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/count_format.dart';

/// Pie / Donut chart cho phân bố type, language, OA
class DistributionChart extends StatelessWidget {
  final Map<String, int> data;
  final bool donut;
  final double height;

  const DistributionChart({
    super.key,
    required this.data,
    this.donut = false,
    this.height = 220,
  });

  String _label(String key) {
    if (key == 'true') return 'Open Access';
    if (key == 'false') return 'Non-OA';
    if (key.length == 2 && key == key.toUpperCase()) return key;
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No distribution data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total <= 0) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No distribution data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: donut ? 48 : 0,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    color: AppColors.chartColors[i % AppColors.chartColors.length],
                    title: entries.length <= 5
                        ? '${((entries[i].value / total) * 100).round()}%'
                        : '',
                    radius: donut ? 56 : 64,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.chartColors[i % AppColors.chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_label(entries[i].key)} (${formatOpenAlexCount(entries[i].value)})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

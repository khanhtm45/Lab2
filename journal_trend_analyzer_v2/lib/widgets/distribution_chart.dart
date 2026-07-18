import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';

/// Pie / Donut chart cho phân bố type, language, OA
class DistributionChart extends StatefulWidget {
  final Map<String, int> data;
  final bool donut;
  final double height;

  const DistributionChart({
    super.key,
    required this.data,
    this.donut = false,
    this.height = 220,
  });

  @override
  State<DistributionChart> createState() => _DistributionChartState();
}

class _DistributionChartState extends State<DistributionChart> {
  int? _touchedIndex;

  String _label(String key) {
    final s = context.stringsOf;
    if (key == 'true') return s.openAccess;
    if (key == 'false') return s.nonOa;
    if (key.length == 2 && key == key.toUpperCase()) return key;
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            s.noDistributionData,
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      );
    }

    final entries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total <= 0) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            s.noDistributionData,
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      );
    }

    final colors = chartSeriesColors(palette);

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: widget.donut ? 48 : 0,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions) return;
                  setState(() {
                    final index = response?.touchedSection?.touchedSectionIndex;
                    _touchedIndex = resolvePieTouchIndex(index, _touchedIndex);
                  });
                },
              ),
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    color: colors[i % colors.length],
                    title: entries.length <= 5
                        ? '${((entries[i].value / total) * 100).round()}%'
                        : '',
                    radius: _touchedIndex == i ? (widget.donut ? 62 : 70) : (widget.donut ? 56 : 64),
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
        if (_touchedIndex != null &&
            _touchedIndex! >= 0 &&
            _touchedIndex! < entries.length)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${_label(entries[_touchedIndex!].key)}: ${formatOpenAlexCountFull(entries[_touchedIndex!].value)} (${((entries[_touchedIndex!].value / total) * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (var i = 0; i < entries.length; i++)
              GestureDetector(
                onTap: () => setState(() {
                  _touchedIndex = _touchedIndex == i ? null : i;
                }),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                        border: _touchedIndex == i
                            ? Border.all(color: palette.textPrimary, width: 1.5)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_label(entries[i].key)} (${formatOpenAlexCountFull(entries[i].value)})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _touchedIndex == i ? FontWeight.w700 : FontWeight.w400,
                        color: _touchedIndex == i
                            ? palette.textPrimary
                            : palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

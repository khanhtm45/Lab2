import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/openalex_ranked_entity.dart';
import '../theme/app_theme.dart';
import '../utils/chart_axis.dart';
import '../utils/count_format.dart';

/// Rút gọn tên quốc gia dài từ OpenAlex.
String shortCountryLabel(String name) {
  const aliases = {
    'United States of America': 'United States',
    'United Kingdom of Great Britain and Northern Ireland': 'United Kingdom',
    'Russian Federation': 'Russia',
    'Korea, Republic of': 'South Korea',
    "Korea, Democratic People's Republic of": 'North Korea',
    'Iran, Islamic Republic of': 'Iran',
    'Venezuela, Bolivarian Republic of': 'Venezuela',
    'Taiwan, Province of China': 'Taiwan',
  };
  if (aliases.containsKey(name)) return aliases[name]!;
  if (name.length <= 18) return name;
  if (name.length == 2 && name == name.toUpperCase()) return name;
  return name;
}

double _niceAxisMax(double rawMax) {
  if (rawMax <= 0) return 1;
  final padded = rawMax * 1.12;
  final magnitude = math.pow(10, (math.log(padded) / math.ln10).floor()).toDouble();
  final normalized = padded / magnitude;
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

double _niceAxisInterval(double max) {
  if (max <= 0) return 1;
  final raw = max / 4;
  final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
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

String _formatAxisTick(double value) {
  if (value.abs() < 1) return value.toStringAsFixed(1);
  return formatOpenAlexCount(value.round());
}

String _formatExactCount(double value) => formatOpenAlexCountFull(value.round());

/// Shared teal → navy (output) or teal → amber (citation) scale for country charts.
Color countryIntensityColor(
  AppPalette palette,
  double ratio, {
  bool citationMode = false,
}) {
  final high = citationMode ? palette.citation : palette.primary;
  return Color.lerp(palette.accent, high, ratio.clamp(0.0, 1.0)) ?? high;
}

int _scatterSpotIndex(
  ScatterSpot spot,
  List<ScatterPoint> points,
  double maxX,
  double maxY,
) {
  for (var i = 0; i < points.length; i++) {
    final x = points[i].x.clamp(0, maxX);
    final y = points[i].y.clamp(0, maxY);
    if ((spot.x - x).abs() < 0.01 && (spot.y - y).abs() < 0.01) return i;
  }
  return -1;
}

Widget _chartDetailCard({
  required BuildContext context,
  required String title,
  required List<(String, String)> rows,
}) {
  final palette = context.palette;
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: palette.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: palette.primary.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
                children: [
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _axisTickLabel(String text, {Color? color}) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: color ?? AppColors.textSecondary),
    ),
  );
}

class HorizontalRankChart extends StatefulWidget {
  final String title;
  final List<OpenAlexRankedEntity> items;
  final String? metricLabel;
  final int maxItems;

  const HorizontalRankChart({
    super.key,
    required this.title,
    required this.items,
    this.metricLabel,
    this.maxItems = 10,
  });

  @override
  State<HorizontalRankChart> createState() => _HorizontalRankChartState();
}

class _HorizontalRankChartState extends State<HorizontalRankChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    final metric = widget.metricLabel ?? s.count;
    if (widget.items.isEmpty) {
      return Text(
        s.noData,
        style: TextStyle(color: palette.textSecondary),
      );
    }

    final top = widget.items.take(widget.maxItems).toList();
    final maxValue = top.first.count.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...top.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final selected = _selectedIndex == index;
          final ratio = item.count / maxValue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() {
                  _selectedIndex = selected ? null : index;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected ? palette.textPrimary : palette.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: palette.surfaceMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: ratio.clamp(0.06, 1.0),
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: selected ? palette.accent : palette.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatOpenAlexCount(item.count),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: selected ? palette.accent : palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_selectedIndex != null)
          _chartDetailCard(
            context: context,
            title: top[_selectedIndex!].name,
            rows: [
              (metric, _formatExactCount(top[_selectedIndex!].count.toDouble())),
            ],
          ),
      ],
    );
  }
}

class AreaTrendChart extends StatelessWidget {
  final Map<int, int> yearlyData;

  const AreaTrendChart({super.key, required this.yearlyData});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final years = yearlyData.keys.toList()..sort();
    if (years.isEmpty) return const SizedBox(height: 200);

    final spots = [
      for (var i = 0; i < years.length; i++)
        FlSpot(i.toDouble(), yearlyData[years[i]]!.toDouble()),
    ];
    final maxY = yearlyData.values.reduce(math.max).toDouble() * 1.15;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= years.length) return null;
                  return LineTooltipItem(
                    '${years[index]}\n${_formatExactCount(spot.y)}',
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
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= years.length || i % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text('${years[i]}', style: TextStyle(fontSize: 10, color: palette.textSecondary));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: palette.secondary,
              barWidth: 2,
              belowBarData: BarAreaData(
                show: true,
                color: palette.accent.withValues(alpha: 0.35),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-series line chart — emerging keywords / topic evolution.
class MultiSeriesTrendChart extends StatelessWidget {
  final Map<String, Map<int, int>> series;
  final bool filled;

  const MultiSeriesTrendChart({
    super.key,
    required this.series,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (series.isEmpty) {
      return Text(
        s.notEnoughTimeSeries,
        style: TextStyle(color: palette.textSecondary, fontSize: 12),
      );
    }

    final allYears = <int>{};
    for (final trend in series.values) {
      allYears.addAll(trend.keys);
    }
    final years = allYears.toList()..sort();
    if (years.isEmpty) return const SizedBox(height: 200);

    final colors = chartSeriesColors(palette);

    double maxY = 1;
    final lineBars = <LineChartBarData>[];
    var colorIndex = 0;
    for (final entry in series.entries) {
      final spots = <FlSpot>[];
      for (var i = 0; i < years.length; i++) {
        final value = (entry.value[years[i]] ?? 0).toDouble();
        if (value > maxY) maxY = value;
        spots.add(FlSpot(i.toDouble(), value));
      }
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          belowBarData: BarAreaData(
            show: filled,
            color: color.withValues(alpha: filled ? 0.22 : 0),
          ),
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY * 1.15,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _niceAxisInterval(maxY),
                getDrawingHorizontalLine: (_) => FlLine(
                  color: palette.border.withValues(alpha: 0.35),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final yearIndex = spot.x.toInt();
                      final barIndex = spot.barIndex;
                      if (yearIndex < 0 ||
                          yearIndex >= years.length ||
                          barIndex < 0 ||
                          barIndex >= series.length) {
                        return null;
                      }
                      final label = series.keys.elementAt(barIndex);
                      return LineTooltipItem(
                        '$label · ${years[yearIndex]}\n${_formatExactCount(spot.y)}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= years.length || i % 2 != 0) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        '${years[i]}',
                        style: TextStyle(
                          fontSize: 10,
                          color: palette.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: lineBars,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: [
            for (var i = 0; i < series.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    series.keys.elementAt(i),
                    style: TextStyle(fontSize: 10, color: palette.textSecondary),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Country output vs collaboration intensity — scatter proxy for #20.
List<ScatterPoint> countryCollaborationScatter({
  required NetworkGraphData graph,
  required List<OpenAlexRankedEntity> countries,
}) {
  if (countries.isEmpty) return const [];

  final collabWeight = <String, double>{};
  for (final edge in graph.edges) {
    collabWeight[edge.from] = (collabWeight[edge.from] ?? 0) + edge.weight;
    collabWeight[edge.to] = (collabWeight[edge.to] ?? 0) + edge.weight;
  }

  return countries
      .map(
        (country) => ScatterPoint(
          label: shortCountryLabel(country.name),
          x: country.count.toDouble(),
          y: collabWeight[country.name] ?? collabWeight[shortCountryLabel(country.name)] ?? 0,
        ),
      )
      .where((p) => p.x > 0 || p.y > 0)
      .toList();
}

class ScatterAnalyticsChart extends StatefulWidget {
  final List<ScatterPoint> points;
  final String? xLabel;
  final String? yLabel;

  const ScatterAnalyticsChart({
    super.key,
    required this.points,
    this.xLabel,
    this.yLabel,
  });

  @override
  State<ScatterAnalyticsChart> createState() => _ScatterAnalyticsChartState();
}

class _ScatterAnalyticsChartState extends State<ScatterAnalyticsChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant ScatterAnalyticsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _selectedIndex = null;
    }
  }

  void _selectIndex(int? index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  String _shortPointLabel(String label) {
    if (label.length <= 20) return label;
    return '${label.substring(0, 19)}…';
  }

  ScatterTooltipItem? _tooltipForSpot(
    ScatterSpot spot,
    List<ScatterPoint> points,
    double chartMaxX,
    double chartMaxY,
    String xLabel,
    String yLabel,
  ) {
    final index = _scatterSpotIndex(spot, points, chartMaxX, chartMaxY);
    if (index < 0) return null;
    final point = points[index];
    return ScatterTooltipItem(
      '',
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      children: [
        TextSpan(
          text: '${_shortPointLabel(point.label)}\n',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        TextSpan(
          text: '$xLabel: ',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        TextSpan(
          text: '${_formatExactCount(point.x)}\n',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: '$yLabel: ',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        TextSpan(
          text: _formatExactCount(point.y),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    final xLabel = widget.xLabel ?? s.publicationsLabel;
    final yLabel = widget.yLabel ?? s.citations;
    final points = widget.points;
    if (points.isEmpty) {
      return Text(s.noScatterData, style: TextStyle(color: palette.textSecondary));
    }

    final rawMaxX = points.map((p) => p.x).reduce(math.max);
    final rawMaxY = points.map((p) => p.y).reduce(math.max);
    final chartMaxX = _niceAxisMax(rawMaxX);
    final chartMaxY = _niceAxisMax(rawMaxY);
    final xInterval = _niceAxisInterval(chartMaxX);
    final yInterval = _niceAxisInterval(chartMaxY);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: ScatterChart(
            ScatterChartData(
              minX: 0,
              maxX: chartMaxX,
              minY: 0,
              maxY: chartMaxY,
              clipData: const FlClipData.all(),
              borderData: FlBorderData(show: false),
              showingTooltipIndicators:
                  _selectedIndex != null ? [_selectedIndex!] : const [],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: palette.border,
                  strokeWidth: 1,
                ),
              ),
              scatterTouchData: ScatterTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchSpotThreshold: 22,
                touchTooltipData: ScatterTouchTooltipData(
                  getTooltipColor: (_) => palette.primary,
                  tooltipBorderRadius: BorderRadius.circular(8),
                  maxContentWidth: 180,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spot) =>
                      _tooltipForSpot(spot, points, chartMaxX, chartMaxY, xLabel, yLabel),
                ),
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) return;
                  final index = response?.touchedSpot?.spotIndex;
                  if (index == null) {
                    _selectIndex(null);
                    return;
                  }
                  _selectIndex(index);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    xLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                  axisNameSize: 22,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: xInterval,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value > chartMaxX + xInterval * 0.01) {
                        return const SizedBox.shrink();
                      }
                      final rem = (value / xInterval) % 1;
                      if (rem > 0.05 && rem < 0.95) return const SizedBox.shrink();
                      return _axisTickLabel(_formatAxisTick(value), color: palette.textSecondary);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    yLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                  axisNameSize: 28,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value > chartMaxY + yInterval * 0.01) {
                        return const SizedBox.shrink();
                      }
                      final rem = (value / yInterval) % 1;
                      if (rem > 0.05 && rem < 0.95) return const SizedBox.shrink();
                      return Text(
                        _formatAxisTick(value),
                        style: TextStyle(fontSize: 10, color: palette.textSecondary),
                      );
                    },
                  ),
                ),
              ),
              scatterSpots: [
                for (var i = 0; i < points.length; i++)
                  ScatterSpot(
                    points[i].x.clamp(0, chartMaxX),
                    points[i].y.clamp(0, chartMaxY),
                    dotPainter: FlDotCirclePainter(
                      radius: _selectedIndex == i ? 9 : 6,
                      color: _selectedIndex == i ? palette.accent : palette.primary,
                      strokeWidth: _selectedIndex == i ? 2.5 : 1.5,
                      strokeColor: palette.surface,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: points.take(6).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final selected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _selectIndex(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? palette.primary.withValues(alpha: 0.14)
                      : palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                  border: selected
                      ? Border.all(color: palette.primary.withValues(alpha: 0.5))
                      : null,
                ),
                child: Text(
                  '${_shortPointLabel(point.label)} · ${_formatExactCount(point.x)} / ${_formatExactCount(point.y)}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? palette.textPrimary : palette.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedIndex != null && _selectedIndex! < points.length)
          _chartDetailCard(
            context: context,
            title: points[_selectedIndex!].label,
            rows: [
              (xLabel, _formatExactCount(points[_selectedIndex!].x)),
              (yLabel, _formatExactCount(points[_selectedIndex!].y)),
            ],
          ),
      ],
    );
  }
}

class BubbleAnalyticsChart extends StatefulWidget {
  final List<BubblePoint> points;

  const BubbleAnalyticsChart({super.key, required this.points});

  @override
  State<BubbleAnalyticsChart> createState() => _BubbleAnalyticsChartState();
}

class _BubbleAnalyticsChartState extends State<BubbleAnalyticsChart> {
  int? _selectedIndex;

  bool _isInstitutionMode(List<BubblePoint> items) {
    return items.any((p) => p.y > 50 || p.x > 20);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (widget.points.isEmpty) {
      return Text(s.noBubbleData, style: TextStyle(color: palette.textSecondary));
    }

    final top = widget.points.take(8).toList();
    final institutionMode = _isInstitutionMode(top);
    final maxMagnitude = math.max(
      top
          .map((p) => math.max(math.max(p.size.abs(), p.y.abs()), 1.0))
          .reduce(math.max),
      1.0,
    );

    return Column(
      children: [
        ...top.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          final selected = _selectedIndex == index;
          final magnitude = math.max(math.max(point.size.abs(), point.y.abs()), 1.0);
          final ratio = (magnitude / maxMagnitude).clamp(0.0, 1.0);
          final bubbleSize = (44.0 + ratio * 20).clamp(40.0, 64.0);
          final fillAlpha = selected
              ? 0.45
              : (0.12 + ratio * 0.35).clamp(0.12, 0.85);
          final borderAlpha = selected
              ? 0.95
              : (0.35 + ratio * 0.45).clamp(0.35, 0.9);
          final valueLabel = institutionMode
              ? _formatAxisTick(point.y)
              : formatSignedPercent(point.y);
          final subtitle = institutionMode
              ? s.worksCitations(
                  _formatExactCount(point.x),
                  _formatExactCount(point.y),
                )
              : s.growthYoyValue(formatSignedPercent(point.y));

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() {
                  _selectedIndex = selected ? null : index;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: selected
                      ? BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: palette.primary.withValues(alpha: 0.35),
                          ),
                        )
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: bubbleSize,
                        height: bubbleSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: fillAlpha),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.primary.withValues(alpha: borderAlpha),
                            width: selected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Text(
                          valueLabel,
                          style: TextStyle(
                            fontSize: bubbleSize > 52 ? 10 : 8,
                            fontWeight: FontWeight.w700,
                            color: palette.primary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              point.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 10,
                                color: palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_selectedIndex != null)
          _chartDetailCard(
            context: context,
            title: top[_selectedIndex!].label,
            rows: institutionMode
                ? [
                    (s.works, _formatExactCount(top[_selectedIndex!].x)),
                    (s.citations, _formatExactCount(top[_selectedIndex!].y)),
                    (s.sizeIndex, _formatExactCount(top[_selectedIndex!].size)),
                  ]
                : [
                    (s.growthYoy, formatSignedPercent(top[_selectedIndex!].y)),
                    (s.volume, _formatExactCount(top[_selectedIndex!].x)),
                    (s.momentum, _formatExactCount(top[_selectedIndex!].size)),
                  ],
          ),
      ],
    );
  }
}

class SimpleTreemap extends StatelessWidget {
  final List<OpenAlexRankedEntity> items;

  const SimpleTreemap({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final palette = context.palette;
    final total = items.fold<int>(0, (s, e) => s + e.count);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: items.take(8).map((item) {
        final flex = (item.count / total * 100).clamp(12, 40);
        return Container(
          width: flex * 3.2,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.15 + flex / 100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.border),
          ),
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: palette.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SimpleHeatmapMatrix extends StatelessWidget {
  final List<String> rowLabels;
  final List<String> colLabels;
  final List<List<double>> values;

  const SimpleHeatmapMatrix({
    super.key,
    required this.rowLabels,
    required this.colLabels,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (values.isEmpty) {
      return Text(
        s.insufficientMatrixData,
        style: TextStyle(color: palette.textSecondary),
      );
    }

    final flatMax = values.expand((r) => r).fold<double>(0, math.max);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 80),
              ...colLabels.map(
                (c) => SizedBox(
                  width: 56,
                  child: Text(
                    c,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 8, color: palette.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          ...List.generate(values.length, (ri) {
            return Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    rowLabels[ri],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9, color: palette.textPrimary),
                  ),
                ),
                ...List.generate(colLabels.length, (ci) {
                  final v = values[ri][ci];
                  final intensity = flatMax > 0 ? v / flatMax : 0;
                  return Container(
                    width: 52,
                    height: 32,
                    margin: const EdgeInsets.all(2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.primary.withValues(alpha: 0.1 + intensity * 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      v > 0 ? v.toInt().toString() : '',
                      style: TextStyle(fontSize: 9, color: palette.textPrimary),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class KeywordHubNetworkView extends StatelessWidget {
  final String centerLabel;
  final List<String> keywords;
  final NetworkGraphData? cooccurrence;
  final double height;

  const KeywordHubNetworkView({
    super.key,
    required this.centerLabel,
    required this.keywords,
    this.cooccurrence,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (keywords.isEmpty) {
      return Text(
        s.searchTopicForKeywords,
        style: TextStyle(color: palette.textSecondary),
      );
    }

    final nodes = keywords.take(8).map((k) => _shortLabel(k, 16)).toList();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _KeywordHubPainter(
          palette: palette,
          centerLabel: _shortLabel(centerLabel, 14),
          keywords: nodes,
          extraEdges: cooccurrence?.edges ?? const [],
        ),
      ),
    );
  }

  String _shortLabel(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max - 1)}…';
  }
}

class _KeywordHubPainter extends CustomPainter {
  final AppPalette palette;
  final String centerLabel;
  final List<String> keywords;
  final List<NetworkEdge> extraEdges;

  _KeywordHubPainter({
    required this.palette,
    required this.centerLabel,
    required this.keywords,
    required this.extraEdges,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (keywords.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.34;
    final positions = <String, Offset>{centerLabel: center};

    for (var i = 0; i < keywords.length; i++) {
      final angle = (i / keywords.length) * 2 * math.pi - math.pi / 2;
      positions[keywords[i]] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }

    final hubPaint = Paint()
      ..color = palette.accent.withValues(alpha: 0.55)
      ..strokeWidth = 1.6;

    for (final keyword in keywords) {
      final end = positions[keyword];
      if (end == null) continue;
      canvas.drawLine(center, end, hubPaint);
    }

    for (final edge in extraEdges) {
      final from = positions[edge.from] ?? positions[_matchNode(edge.from)];
      final to = positions[edge.to] ?? positions[_matchNode(edge.to)];
      if (from == null || to == null || from == to) continue;
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = palette.secondary.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
    }

    for (final keyword in keywords) {
      final pos = positions[keyword]!;
      canvas.drawCircle(pos, 5, Paint()..color = palette.secondary);
      _drawNodeLabel(canvas, keyword, pos, below: pos.dy >= center.dy);
    }

    canvas.drawCircle(center, 7, Paint()..color = palette.primary);
    _drawNodeLabel(canvas, centerLabel, center, below: true, isCenter: true);
  }

  String? _matchNode(String name) {
    for (final keyword in keywords) {
      if (keyword.startsWith(name) || name.startsWith(keyword)) return keyword;
    }
    return null;
  }

  void _drawNodeLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    required bool below,
    bool isCenter = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isCenter ? palette.primary : palette.textSecondary,
          fontSize: isCenter ? 11 : 9,
          fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 88);

    final offset = below
        ? Offset(pos.dx - tp.width / 2, pos.dy + 10)
        : Offset(pos.dx - tp.width / 2, pos.dy - tp.height - 10);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _KeywordHubPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.centerLabel != centerLabel ||
        oldDelegate.keywords != keywords ||
        oldDelegate.extraEdges != extraEdges;
  }
}

class NetworkGraphView extends StatelessWidget {
  final NetworkGraphData graph;
  final double height;

  const NetworkGraphView({
    super.key,
    required this.graph,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (graph.isEmpty) {
      return Text(
        s.notEnoughNetworkData,
        style: TextStyle(color: palette.textSecondary, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _EdgeNetworkPainter(graph, palette),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: graph.nodes.take(8).map((n) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                n,
                style: TextStyle(fontSize: 9, color: palette.textSecondary),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CountryIntensityChart extends StatelessWidget {
  final List<OpenAlexRankedEntity> items;
  final String? metricLabel;
  final bool citationMode;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;

  const CountryIntensityChart({
    super.key,
    required this.items,
    this.metricLabel,
    this.citationMode = false,
    this.selectedIndex,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (items.isEmpty) {
      return Text(s.noCountryData, style: TextStyle(color: palette.textSecondary));
    }

    final top = items.take(10).toList();
    final maxValue = top.first.count.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          citationMode
              ? s.citationIntensityByCountry
              : s.researchOutputByCountry,
          style: TextStyle(fontSize: 11, color: palette.textSecondary),
        ),
        const SizedBox(height: 10),
        ...top.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final selected = selectedIndex == index;
          final ratio = item.count / maxValue;
          final color = countryIntensityColor(palette, ratio, citationMode: citationMode);
          final label = shortCountryLabel(item.name);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onItemTap == null ? null : () => onItemTap!(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                color: selected ? palette.textPrimary : palette.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatOpenAlexCount(item.count),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 10,
                              color: palette.surfaceMuted,
                            ),
                            FractionallySizedBox(
                              widthFactor: ratio.clamp(0.04, 1.0),
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withValues(alpha: selected ? 0.75 : 0.55),
                                      color,
                                    ],
                                  ),
                                  border: selected
                                      ? Border.all(color: palette.primary.withValues(alpha: 0.5))
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class SimpleSankeyView extends StatelessWidget {
  final List<SankeyFlow> flows;

  const SimpleSankeyView({super.key, required this.flows});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (flows.isEmpty) {
      return Text(
        s.notEnoughJournalMigration,
        style: TextStyle(color: palette.textSecondary),
      );
    }

    final years = flows.map((f) => f.source).toSet().toList()..sort();
    final maxFlow = flows.map((f) => f.value).reduce(math.max);
    final sankeyColors = chartSeriesColors(palette);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.yearJournalFlows,
          style: TextStyle(fontSize: 11, color: palette.textSecondary),
        ),
        const SizedBox(height: 10),
        ...years.map((year) {
          final yearFlows = flows.where((f) => f.source == year).toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final yearTotal = yearFlows.fold<double>(0, (s, f) => s + f.value);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(year, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: palette.textPrimary)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        for (final flow in yearFlows.take(4))
                          Expanded(
                            flex: (flow.value / yearTotal * 100).round().clamp(1, 100),
                            child: Container(
                              color: sankeyColors[flow.target.hashCode.abs() % sankeyColors.length],
                              alignment: Alignment.center,
                              child: flow.value / maxFlow > 0.15
                                  ? Text(
                                      flow.target,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 8, color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: yearFlows.take(4).map((f) {
                    return Text(
                      '${f.target}: ${f.value.toInt()}',
                      style: TextStyle(fontSize: 9, color: palette.textSecondary),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _EdgeNetworkPainter extends CustomPainter {
  final NetworkGraphData graph;
  final AppPalette palette;

  _EdgeNetworkPainter(this.graph, this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = graph.nodes;
    if (nodes.isEmpty) return;

    final positions = <String, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;

    for (var i = 0; i < nodes.length; i++) {
      final angle = (i / nodes.length) * 2 * math.pi - math.pi / 2;
      positions[nodes[i]] = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }

    final maxWeight = graph.edges.isEmpty
        ? 1.0
        : graph.edges.map((e) => e.weight).reduce(math.max);

    for (final edge in graph.edges) {
      final from = positions[edge.from];
      final to = positions[edge.to];
      if (from == null || to == null) continue;
      final stroke = 1.0 + (edge.weight / maxWeight) * 3;
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = palette.accent.withValues(alpha: 0.45)
          ..strokeWidth = stroke,
      );
    }

    for (final node in nodes) {
      final pos = positions[node]!;
      canvas.drawCircle(pos, 5, Paint()..color = palette.primary);
      final tp = TextPainter(
        text: TextSpan(
          text: node,
          style: TextStyle(fontSize: 8, color: palette.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 64);
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _EdgeNetworkPainter old) =>
      old.graph != graph || old.palette != palette;
}

class SimpleNetworkView extends StatelessWidget {
  final List<String> nodes;
  final double height;

  const SimpleNetworkView({super.key, required this.nodes, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    if (nodes.length < 2) {
      return Text(
        s.needMoreNetworkNodes,
        style: TextStyle(color: palette.textSecondary),
      );
    }

    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _NetworkPainter(nodes, palette),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final List<String> nodes;
  final AppPalette palette;

  _NetworkPainter(this.nodes, this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = palette.accent
      ..strokeWidth = 1.2;

    for (var i = 0; i < nodes.length; i++) {
      final angle = (i / nodes.length) * 2 * math.pi;
      final end = Offset(
        center.dx + 80 * math.cos(angle),
        center.dy + 60 * math.sin(angle),
      );
      canvas.drawLine(center, end, paint);
      canvas.drawCircle(end, 4, Paint()..color = palette.primary);
    }
    canvas.drawCircle(center, 6, Paint()..color = palette.secondary);
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) =>
      old.nodes != nodes || old.palette != palette;
}

class WorldCountryMapChart extends StatefulWidget {
  final List<OpenAlexRankedEntity> items;
  final bool citationMode;

  const WorldCountryMapChart({
    super.key,
    required this.items,
    this.citationMode = false,
  });

  @override
  State<WorldCountryMapChart> createState() => _WorldCountryMapChartState();
}

class _WorldCountryMapChartState extends State<WorldCountryMapChart> {
  int? _selectedIndex;

  static const _positions = {
    'US': Offset(0.22, 0.40),
    'United States': Offset(0.22, 0.40),
    'CN': Offset(0.78, 0.42),
    'China': Offset(0.78, 0.42),
    'GB': Offset(0.48, 0.30),
    'United Kingdom': Offset(0.48, 0.30),
    'DE': Offset(0.52, 0.32),
    'Germany': Offset(0.52, 0.32),
    'IN': Offset(0.70, 0.48),
    'India': Offset(0.70, 0.48),
    'JP': Offset(0.84, 0.40),
    'Japan': Offset(0.84, 0.40),
    'FR': Offset(0.49, 0.34),
    'France': Offset(0.49, 0.34),
    'CA': Offset(0.18, 0.28),
    'Canada': Offset(0.18, 0.28),
    'AU': Offset(0.84, 0.72),
    'Australia': Offset(0.84, 0.72),
    'BR': Offset(0.32, 0.68),
    'Brazil': Offset(0.32, 0.68),
    'KR': Offset(0.82, 0.40),
    'RU': Offset(0.62, 0.26),
    'IT': Offset(0.52, 0.36),
    'ES': Offset(0.46, 0.38),
    'NL': Offset(0.50, 0.30),
    'CH': Offset(0.51, 0.33),
    'SE': Offset(0.53, 0.24),
    'SG': Offset(0.76, 0.58),
    'VN': Offset(0.76, 0.52),
    'Vietnam': Offset(0.76, 0.52),
  };

  Offset _positionFor(String name) {
    return _positions[name] ??
        _positions[shortCountryLabel(name)] ??
        Offset(0.5 + (name.hashCode % 17) / 100, 0.45 + (name.hashCode % 13) / 100);
  }

  double _bubbleRadius(double count, double maxValue) {
    final ratio = (count / maxValue).clamp(0.08, 1.0);
    return 6.0 + ratio * 14;
  }

  int? _hitTest(Offset local, Size size, List<OpenAlexRankedEntity> top, double maxValue) {
    int? hit;
    var bestDist = double.infinity;
    for (var i = 0; i < top.length; i++) {
      final pos = _positionFor(top[i].name);
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      final touchRadius = _bubbleRadius(top[i].count.toDouble(), maxValue) + 10;
      final dist = (local - center).distance;
      if (dist <= touchRadius && dist < bestDist) {
        hit = i;
        bestDist = dist;
      }
    }
    return hit;
  }

  void _selectIndex(int? index) {
    setState(() => _selectedIndex = _selectedIndex == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    if (widget.items.isEmpty) {
      return Text(
        s.noCountryData,
        style: TextStyle(color: context.palette.textSecondary),
      );
    }

    final palette = context.palette;
    final top = widget.items.take(12).toList();
    final maxValue = top.first.count.toDouble().clamp(1.0, double.infinity);
    final metricLabel =
        widget.citationMode ? s.citations : s.publicationsLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.citationMode ? s.citationImpactMap : s.researchOutputMap,
          style: TextStyle(fontSize: 11, color: palette.textSecondary),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.65,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final hit = _hitTest(details.localPosition, mapSize, top, maxValue);
                  _selectIndex(hit);
                },
                child: CustomPaint(
                  size: mapSize,
                  painter: _WorldMapPainter(
                    items: top,
                    maxValue: maxValue,
                    citationMode: widget.citationMode,
                    positions: _positions,
                    palette: palette,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedIndex != null && _selectedIndex! < top.length)
          _chartDetailCard(
            context: context,
            title: shortCountryLabel(top[_selectedIndex!].name),
            rows: [
              (metricLabel, _formatExactCount(top[_selectedIndex!].count.toDouble())),
            ],
          ),
        const SizedBox(height: 10),
        CountryIntensityChart(
          items: top,
          citationMode: widget.citationMode,
          selectedIndex: _selectedIndex,
          onItemTap: _selectIndex,
        ),
      ],
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  final List<OpenAlexRankedEntity> items;
  final double maxValue;
  final bool citationMode;
  final Map<String, Offset> positions;
  final AppPalette palette;
  final int? selectedIndex;

  _WorldMapPainter({
    required this.items,
    required this.maxValue,
    required this.citationMode,
    required this.positions,
    required this.palette,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ocean = Paint()..color = palette.isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFE0F2FE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      ocean,
    );

    final land = Paint()
      ..color = palette.isDark
          ? const Color(0xFF334155).withValues(alpha: 0.55)
          : const Color(0xFFCBD5E1).withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.18, size.width * 0.35, size.height * 0.42),
      land,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.44, size.height * 0.16, size.width * 0.22, size.height * 0.38),
      land,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.20, size.width * 0.30, size.height * 0.45),
      land,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.58, size.width * 0.18, size.height * 0.22),
      land,
    );

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final key = item.name;
      final pos = positions[key] ??
          positions[shortCountryLabel(key)] ??
          Offset(0.5 + (key.hashCode % 17) / 100, 0.45 + (key.hashCode % 13) / 100);
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      final ratio = (item.count / maxValue).clamp(0.08, 1.0);
      final selected = selectedIndex == i;
      final radius = (6.0 + ratio * 14) * (selected ? 1.15 : 1.0);
      final color = countryIntensityColor(palette, ratio, citationMode: citationMode);
      canvas.drawCircle(
        center,
        radius + 3,
        Paint()..color = color.withValues(alpha: selected ? 0.28 : 0.2),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = color.withValues(alpha: selected ? 0.95 : 0.6 + ratio * 0.35),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = selected ? palette.textPrimary.withValues(alpha: 0.9) : color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.2 : 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter old) =>
      old.items != items ||
      old.maxValue != maxValue ||
      old.selectedIndex != selectedIndex;
}

Color statusColor(AnalyticsStatus s, [AppPalette? palette]) {
  final p = palette ?? AppPalette.light;
  switch (s) {
    case AnalyticsStatus.implemented:
      return p.primary;
    case AnalyticsStatus.partial:
      return p.citation;
    case AnalyticsStatus.planned:
      return p.textSecondary;
  }
}

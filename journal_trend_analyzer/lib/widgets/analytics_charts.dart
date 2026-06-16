import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/openalex_ranked_entity.dart';
import '../theme/app_theme.dart';
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

String _formatSignedPercent(double value, {int fractionDigits = 1}) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(fractionDigits)}%';
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

Widget _axisTickLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
    ),
  );
}

class HorizontalRankChart extends StatelessWidget {
  final String title;
  final List<OpenAlexRankedEntity> items;
  final String metricLabel;
  final int maxItems;

  const HorizontalRankChart({
    super.key,
    required this.title,
    required this.items,
    this.metricLabel = 'count',
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No data',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    final top = items.take(maxItems).toList();
    final maxValue = top.first.count.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...top.map((entry) {
          final ratio = entry.count / maxValue;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio.clamp(0.06, 1.0),
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  formatOpenAlexCount(entry.count),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class AreaTrendChart extends StatelessWidget {
  final Map<int, int> yearlyData;

  const AreaTrendChart({super.key, required this.yearlyData});

  @override
  Widget build(BuildContext context) {
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
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= years.length || i % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text('${years[i]}', style: const TextStyle(fontSize: 10));
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
              color: AppColors.secondary,
              barWidth: 2,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accent.withValues(alpha: 0.35),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class ScatterAnalyticsChart extends StatelessWidget {
  final List<ScatterPoint> points;
  final String xLabel;
  final String yLabel;

  const ScatterAnalyticsChart({
    super.key,
    required this.points,
    this.xLabel = 'Publications',
    this.yLabel = 'Citations',
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Text('No scatter data', style: TextStyle(color: AppColors.textSecondary));
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    xLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
                      return _axisTickLabel(_formatAxisTick(value));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    yLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
              ),
              scatterSpots: [
                for (final p in points)
                  ScatterSpot(
                    p.x.clamp(0, chartMaxX),
                    p.y.clamp(0, chartMaxY),
                    dotPainter: FlDotCirclePainter(
                      radius: 6,
                      color: AppColors.primary,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
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
          children: points.take(6).map((p) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_shortPointLabel(p.label)} · ${_formatAxisTick(p.x)} / ${_formatAxisTick(p.y)}',
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _shortPointLabel(String label) {
    if (label.length <= 20) return label;
    return '${label.substring(0, 19)}…';
  }
}

class BubbleAnalyticsChart extends StatelessWidget {
  final List<BubblePoint> points;

  const BubbleAnalyticsChart({super.key, required this.points});

  bool _isInstitutionMode(List<BubblePoint> items) {
    return items.any((p) => p.y > 50 || p.x > 20);
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Text('No bubble data', style: TextStyle(color: AppColors.textSecondary));
    }

    final top = points.take(8).toList();
    final institutionMode = _isInstitutionMode(top);
    final maxMagnitude = math.max(
      top
          .map((p) => math.max(math.max(p.size.abs(), p.y.abs()), 1.0))
          .reduce(math.max),
      1.0,
    );

    return Column(
      children: top.map((p) {
        final magnitude = math.max(math.max(p.size.abs(), p.y.abs()), 1.0);
        final ratio = (magnitude / maxMagnitude).clamp(0.0, 1.0);
        final bubbleSize = (44.0 + ratio * 20).clamp(40.0, 64.0);
        final fillAlpha = (0.12 + ratio * 0.35).clamp(0.12, 0.85);
        final borderAlpha = (0.35 + ratio * 0.45).clamp(0.35, 0.9);
        final valueLabel = institutionMode
            ? _formatAxisTick(p.y)
            : _formatSignedPercent(p.y);
        final subtitle = institutionMode
            ? 'Works ${_formatAxisTick(p.x)} · Citations ${_formatAxisTick(p.y)}'
            : 'Growth ${_formatSignedPercent(p.y)} YoY';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: bubbleSize,
                height: bubbleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: fillAlpha),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: borderAlpha),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    fontSize: bubbleSize > 52 ? 10 : 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                      p.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SimpleTreemap extends StatelessWidget {
  final List<OpenAlexRankedEntity> items;

  const SimpleTreemap({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
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
            color: AppColors.primary.withValues(alpha: 0.15 + flex / 100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
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
    if (values.isEmpty) {
      return const Text('Insufficient matrix data', style: TextStyle(color: AppColors.textSecondary));
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
                  child: Text(c, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8)),
                ),
              ),
            ],
          ),
          ...List.generate(values.length, (ri) {
            return Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(rowLabels[ri], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9)),
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
                      color: AppColors.primary.withValues(alpha: 0.1 + intensity * 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      v > 0 ? v.toInt().toString() : '',
                      style: const TextStyle(fontSize: 9),
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
    if (keywords.isEmpty) {
      return const Text(
        'Search a topic to see related keywords.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    final nodes = keywords.take(8).map((k) => _shortLabel(k, 16)).toList();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _KeywordHubPainter(
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
  final String centerLabel;
  final List<String> keywords;
  final List<NetworkEdge> extraEdges;

  _KeywordHubPainter({
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
      ..color = AppColors.accent.withValues(alpha: 0.55)
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
          ..color = AppColors.secondary.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
    }

    for (final keyword in keywords) {
      final pos = positions[keyword]!;
      canvas.drawCircle(pos, 5, Paint()..color = AppColors.secondary);
      _drawNodeLabel(canvas, keyword, pos, below: pos.dy >= center.dy);
    }

    canvas.drawCircle(center, 7, Paint()..color = AppColors.primary);
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
          color: isCenter ? AppColors.primary : AppColors.textSecondary,
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
    return oldDelegate.centerLabel != centerLabel ||
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
    if (graph.isEmpty) {
      return const Text(
        'Not enough network data from OpenAlex sample',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _EdgeNetworkPainter(graph),
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
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(n, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CountryIntensityChart extends StatelessWidget {
  final List<OpenAlexRankedEntity> items;
  final String metricLabel;
  final bool citationMode;

  const CountryIntensityChart({
    super.key,
    required this.items,
    this.metricLabel = 'papers',
    this.citationMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('No country data', style: TextStyle(color: AppColors.textSecondary));
    }

    final top = items.take(10).toList();
    final maxValue = top.first.count.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          citationMode
              ? 'Citation intensity by country'
              : 'Research output by country',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 10),
        ...top.map((entry) {
          final ratio = entry.count / maxValue;
          final color = Color.lerp(AppColors.accent, AppColors.primary, ratio) ?? AppColors.primary;
          final label = shortCountryLabel(entry.name);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatOpenAlexCount(entry.count),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.primary,
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
                        color: AppColors.surfaceMuted,
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio.clamp(0.04, 1.0),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.55),
                                color,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    if (flows.isEmpty) {
      return const Text(
        'Not enough journal migration data',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    final years = flows.map((f) => f.source).toSet().toList()..sort();
    final maxFlow = flows.map((f) => f.value).reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Year → Journal flows (OpenAlex sample, last 5 years)',
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
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
                Text(year, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
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
                              color: _sankeyColor(flow.target),
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
                      style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
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

  Color _sankeyColor(String label) {
    final hash = label.codeUnits.fold<int>(0, (h, c) => h + c);
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      const Color(0xFF6366F1),
      const Color(0xFF0891B2),
    ];
    return colors[hash % colors.length];
  }
}

class _EdgeNetworkPainter extends CustomPainter {
  final NetworkGraphData graph;
  _EdgeNetworkPainter(this.graph);

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
          ..color = AppColors.accent.withValues(alpha: 0.45)
          ..strokeWidth = stroke,
      );
    }

    for (final node in nodes) {
      final pos = positions[node]!;
      canvas.drawCircle(pos, 5, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgeNetworkPainter old) => old.graph != graph;
}

class SimpleNetworkView extends StatelessWidget {
  final List<String> nodes;
  final double height;

  const SimpleNetworkView({super.key, required this.nodes, this.height = 160});

  @override
  Widget build(BuildContext context) {
    if (nodes.length < 2) {
      return const Text('Need more nodes for network', style: TextStyle(color: AppColors.textSecondary));
    }

    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _NetworkPainter(nodes),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final List<String> nodes;
  _NetworkPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 1.2;

    for (var i = 0; i < nodes.length; i++) {
      final angle = (i / nodes.length) * 2 * math.pi;
      final end = Offset(
        center.dx + 80 * math.cos(angle),
        center.dy + 60 * math.sin(angle),
      );
      canvas.drawLine(center, end, paint);
      canvas.drawCircle(end, 4, Paint()..color = AppColors.primary);
    }
    canvas.drawCircle(center, 6, Paint()..color = AppColors.secondary);
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) => old.nodes != nodes;
}

String statusLabel(AnalyticsStatus s) {
  switch (s) {
    case AnalyticsStatus.implemented:
      return 'Live';
    case AnalyticsStatus.partial:
      return 'Partial';
    case AnalyticsStatus.planned:
      return 'Planned';
  }
}

Color statusColor(AnalyticsStatus s) {
  switch (s) {
    case AnalyticsStatus.implemented:
      return AppColors.primary;
    case AnalyticsStatus.partial:
      return AppColors.secondary;
    case AnalyticsStatus.planned:
      return AppColors.textTertiary;
  }
}

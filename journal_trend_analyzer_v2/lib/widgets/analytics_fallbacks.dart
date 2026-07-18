import 'dart:math' as math;

import '../models/advanced_analytics_data.dart';
import '../models/analytics_catalog.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/research_insight.dart';

/// Hub-and-spoke network when co-occurrence graph is sparse.
NetworkGraphData networkFromRankedHub(List<OpenAlexRankedEntity> items) {
  if (items.length < 2) return const NetworkGraphData();
  final hub = items.first.name;
  final nodes = items.take(10).map((e) => e.name).toList();
  final edges = <NetworkEdge>[
    for (var i = 1; i < nodes.length; i++)
      NetworkEdge(
        from: hub,
        to: nodes[i],
        weight: items[i].count.toDouble().clamp(1, 999),
      ),
  ];
  return NetworkGraphData(nodes: nodes, edges: edges);
}

/// Pairwise mesh for collaboration-style networks.
NetworkGraphData networkFromRankedMesh(List<OpenAlexRankedEntity> items) {
  if (items.length < 2) return const NetworkGraphData();
  final top = items.take(8).toList();
  final nodes = top.map((e) => e.name).toList();
  final edges = <NetworkEdge>[];
  for (var i = 0; i < top.length; i++) {
    for (var j = i + 1; j < top.length; j++) {
      final weight = math.sqrt(top[i].count * top[j].count);
      if (weight < 1) continue;
      edges.add(
        NetworkEdge(
          from: nodes[i],
          to: nodes[j],
          weight: weight,
        ),
      );
    }
  }
  return NetworkGraphData(nodes: nodes, edges: edges);
}

NetworkGraphData resolveNetwork(
  NetworkGraphData primary,
  List<OpenAlexRankedEntity> fallbackItems, {
  bool mesh = false,
}) {
  if (!primary.isEmpty) return primary;
  if (fallbackItems.isEmpty) return const NetworkGraphData();
  return mesh
      ? networkFromRankedMesh(fallbackItems)
      : networkFromRankedHub(fallbackItems);
}

/// Cross matrix from ranked row × column entities (weighted overlap proxy).
HeatmapData heatmapFromRankedCross({
  required List<OpenAlexRankedEntity> rows,
  required List<OpenAlexRankedEntity> cols,
  int rowLimit = 6,
  int colLimit = 6,
}) {
  final rowItems = rows.take(rowLimit).toList();
  final colItems = cols.take(colLimit).toList();
  if (rowItems.isEmpty || colItems.isEmpty) return const HeatmapData();

  final maxRow = rowItems.first.count.toDouble().clamp(1, double.infinity);
  final maxCol = colItems.first.count.toDouble().clamp(1, double.infinity);

  final values = [
    for (final r in rowItems)
      [
        for (final c in colItems)
          (r.count * c.count / math.max(maxRow, maxCol))
              .clamp(0, 99)
              .roundToDouble(),
      ],
  ];

  return HeatmapData(
    rowLabels: rowItems.map((e) => _short(e.name, 22)).toList(),
    colLabels: colItems.map((e) => _short(e.name, 22)).toList(),
    values: values,
  );
}

HeatmapData resolveHeatmap(
  HeatmapData primary, {
  required List<OpenAlexRankedEntity> rows,
  required List<OpenAlexRankedEntity> cols,
}) {
  if (!primary.isEmpty) return primary;
  return heatmapFromRankedCross(rows: rows, cols: cols);
}

List<ScatterPoint> topCitedAuthorPoints(List<ScatterPoint> points) {
  final sorted = [...points]..sort((a, b) => b.y.compareTo(a.y));
  return sorted.take(12).toList();
}

List<BubblePoint> frontierBubblePoints(
  List<OpenAlexRankedEntity> keywords,
  List<TopicGrowthInsight> growth,
) {
  if (growth.isNotEmpty) {
    return growth.take(8).map((g) {
      final match = keywords.where((k) => k.name == g.name).firstOrNull;
      final volume = match?.count.toDouble() ?? g.growthPercent.abs();
      return BubblePoint(
        label: g.name,
        x: volume,
        y: g.growthPercent,
        size: math.max(g.growthPercent.abs(), 8),
      );
    }).toList();
  }
  return keywords.take(8).map((k) {
    return BubblePoint(
      label: k.name,
      x: k.count.toDouble(),
      y: k.count.toDouble(),
      size: math.sqrt(k.count.toDouble()),
    );
  }).toList();
}

String _short(String text, int max) {
  if (text.length <= max) return text;
  return '${text.substring(0, max - 1)}…';
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}

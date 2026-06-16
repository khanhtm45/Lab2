import 'analytics_catalog.dart';
import 'openalex_ranked_entity.dart';

export 'analytics_catalog.dart' show BubblePoint;

class NetworkEdge {
  final String from;
  final String to;
  final double weight;

  const NetworkEdge({required this.from, required this.to, this.weight = 1});
}

class NetworkGraphData {
  final List<String> nodes;
  final List<NetworkEdge> edges;

  const NetworkGraphData({this.nodes = const [], this.edges = const []});

  bool get isEmpty => nodes.isEmpty || edges.isEmpty;
}

class HeatmapData {
  final List<String> rowLabels;
  final List<String> colLabels;
  final List<List<double>> values;

  const HeatmapData({
    this.rowLabels = const [],
    this.colLabels = const [],
    this.values = const [],
  });

  bool get isEmpty => rowLabels.isEmpty || colLabels.isEmpty || values.isEmpty;
}

class SankeyFlow {
  final String source;
  final String target;
  final double value;

  const SankeyFlow({required this.source, required this.target, required this.value});
}

class AdvancedAnalyticsData {
  final List<BubblePoint> institutionBubbles;
  final List<OpenAlexRankedEntity> countryByCitations;
  final Map<String, int> citationQuartiles;
  final NetworkGraphData citationNetwork;
  final NetworkGraphData authorCollaboration;
  final NetworkGraphData institutionCollaboration;
  final NetworkGraphData countryCollaboration;
  final NetworkGraphData keywordCooccurrence;
  final NetworkGraphData topicCooccurrence;
  final HeatmapData journalTopicMatrix;
  final HeatmapData authorTopicMatrix;
  final HeatmapData institutionTopicMatrix;
  final HeatmapData countryTopicMatrix;
  final List<SankeyFlow> journalMigrationFlows;

  const AdvancedAnalyticsData({
    this.institutionBubbles = const [],
    this.countryByCitations = const [],
    this.citationQuartiles = const {},
    this.citationNetwork = const NetworkGraphData(),
    this.authorCollaboration = const NetworkGraphData(),
    this.institutionCollaboration = const NetworkGraphData(),
    this.countryCollaboration = const NetworkGraphData(),
    this.keywordCooccurrence = const NetworkGraphData(),
    this.topicCooccurrence = const NetworkGraphData(),
    this.journalTopicMatrix = const HeatmapData(),
    this.authorTopicMatrix = const HeatmapData(),
    this.institutionTopicMatrix = const HeatmapData(),
    this.countryTopicMatrix = const HeatmapData(),
    this.journalMigrationFlows = const [],
  });

  static const empty = AdvancedAnalyticsData();
}

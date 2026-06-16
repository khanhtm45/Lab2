/// Loại biểu đồ theo spec BI
enum ChartDisplayType {
  lineChart,
  horizontalBar,
  areaChart,
  treemap,
  scatterPlot,
  bubbleChart,
  donutChart,
  networkGraph,
  mapChart,
  heatmap,
  sankey,
  dashboard,
}

enum AnalyticsStatus {
  implemented,
  partial,
  planned,
}

class AnalyticsCatalogItem {
  final int no;
  final String name;
  final String factTable;
  final String dimensionTable;
  final String description;
  final ChartDisplayType displayType;
  final AnalyticsStatus status;

  const AnalyticsCatalogItem({
    required this.no,
    required this.name,
    required this.factTable,
    required this.dimensionTable,
    required this.description,
    required this.displayType,
    required this.status,
  });
}

/// 30 analytics theo spec — mapped tới OpenAlex mobile client
const analyticsCatalog = <AnalyticsCatalogItem>[
  AnalyticsCatalogItem(
    no: 1,
    name: 'Publication Trend',
    factTable: 'Paper',
    dimensionTable: 'Time',
    description: 'Số lượng bài báo theo năm',
    displayType: ChartDisplayType.lineChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 2,
    name: 'Citation Trend',
    factTable: 'Paper',
    dimensionTable: 'Time',
    description: 'Tổng citation theo năm',
    displayType: ChartDisplayType.lineChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 3,
    name: 'Top Keywords',
    factTable: 'PaperKeyword',
    dimensionTable: 'Keyword',
    description: 'Keyword xuất hiện nhiều nhất',
    displayType: ChartDisplayType.horizontalBar,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 4,
    name: 'Emerging Keywords',
    factTable: 'PaperKeyword',
    dimensionTable: 'Keyword, Time',
    description: 'Keyword tăng trưởng nhanh nhất',
    displayType: ChartDisplayType.lineChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 5,
    name: 'Topic Evolution',
    factTable: 'PaperKeyword',
    dimensionTable: 'Topic, Time',
    description: 'Sự thay đổi của Topic theo thời gian',
    displayType: ChartDisplayType.areaChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 6,
    name: 'Research Landscape',
    factTable: 'PaperKeyword',
    dimensionTable: 'Domain, Field, Topic',
    description: 'Phân bố nghiên cứu theo các lĩnh vực',
    displayType: ChartDisplayType.treemap,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 7,
    name: 'Top Authors',
    factTable: 'PaperAuthor',
    dimensionTable: 'Author',
    description: 'Tác giả có nhiều công bố nhất',
    displayType: ChartDisplayType.horizontalBar,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 8,
    name: 'Author Impact',
    factTable: 'PaperAuthor',
    dimensionTable: 'Author',
    description: 'Tác giả có citation cao nhất',
    displayType: ChartDisplayType.scatterPlot,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 9,
    name: 'Author Productivity vs Impact',
    factTable: 'PaperAuthor',
    dimensionTable: 'Author',
    description: 'So sánh Productivity và Citation',
    displayType: ChartDisplayType.scatterPlot,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 10,
    name: 'Institution Ranking',
    factTable: 'AuthorInstitution',
    dimensionTable: 'Institution',
    description: 'Xếp hạng Institution theo số bài',
    displayType: ChartDisplayType.horizontalBar,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 11,
    name: 'Institution Impact',
    factTable: 'AuthorInstitution',
    dimensionTable: 'Institution',
    description: 'Quan hệ hợp tác giữa tổ chức',
    displayType: ChartDisplayType.bubbleChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 12,
    name: 'Country Research Output',
    factTable: 'Paper',
    dimensionTable: 'Country',
    description: 'Số lượng bài báo theo quốc gia',
    displayType: ChartDisplayType.mapChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 13,
    name: 'Country Citation Impact',
    factTable: 'Paper',
    dimensionTable: 'Country',
    description: 'Citation theo quốc gia',
    displayType: ChartDisplayType.mapChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 14,
    name: 'Journal Ranking',
    factTable: 'Paper',
    dimensionTable: 'Journal',
    description: 'Journal có nhiều bài báo nhất',
    displayType: ChartDisplayType.horizontalBar,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 15,
    name: 'Journal Impact Analysis',
    factTable: 'Paper',
    dimensionTable: 'Journal',
    description: 'Citation vs publications (proxy SJR/H-index)',
    displayType: ChartDisplayType.scatterPlot,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 16,
    name: 'Quartile Distribution',
    factTable: 'Paper',
    dimensionTable: 'Journal',
    description: 'Phân bố Q1–Q4 theo citation trong sample OpenAlex',
    displayType: ChartDisplayType.donutChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 17,
    name: 'Citation Network',
    factTable: 'Citation',
    dimensionTable: 'Paper',
    description: 'Quan hệ trích dẫn giữa các bài báo',
    displayType: ChartDisplayType.networkGraph,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 18,
    name: 'Author Collaboration',
    factTable: 'PaperAuthor',
    dimensionTable: 'Author',
    description: 'Quan hệ đồng tác giả',
    displayType: ChartDisplayType.networkGraph,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 19,
    name: 'Institution Collaboration',
    factTable: 'AuthorInstitution',
    dimensionTable: 'Institution',
    description: 'Mạng hợp tác giữa tổ chức',
    displayType: ChartDisplayType.networkGraph,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 20,
    name: 'Country Collaboration',
    factTable: 'AuthorInstitution',
    dimensionTable: 'Country',
    description: 'Quan hệ hợp tác giữa quốc gia',
    displayType: ChartDisplayType.networkGraph,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 21,
    name: 'Keyword Co-occurrence',
    factTable: 'PaperKeyword',
    dimensionTable: 'Keyword',
    description: 'Keyword thường xuất hiện cùng nhau',
    displayType: ChartDisplayType.networkGraph,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 22,
    name: 'Topic Co-occurrence',
    factTable: 'PaperKeyword',
    dimensionTable: 'Topic',
    description: 'Quan hệ giữa các topic nghiên cứu',
    displayType: ChartDisplayType.networkGraph,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 23,
    name: 'Journal-Topic Matrix',
    factTable: 'Paper',
    dimensionTable: 'Journal, Topic',
    description: 'Journal mạnh ở Topic nào',
    displayType: ChartDisplayType.heatmap,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 24,
    name: 'Author-Topic Matrix',
    factTable: 'PaperAuthor',
    dimensionTable: 'Author, Topic',
    description: 'Chuyên môn nghiên cứu của tác giả',
    displayType: ChartDisplayType.heatmap,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 25,
    name: 'Institution-Topic Matrix',
    factTable: 'AuthorInstitution',
    dimensionTable: 'Institution, Topic',
    description: 'Thế mạnh nghiên cứu của tổ chức',
    displayType: ChartDisplayType.heatmap,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 26,
    name: 'Country-Topic Matrix',
    factTable: 'Paper',
    dimensionTable: 'Country, Topic',
    description: 'Chủ đề nghiên cứu theo quốc gia',
    displayType: ChartDisplayType.heatmap,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 27,
    name: 'Research Frontier Detection',
    factTable: 'PaperKeyword',
    dimensionTable: 'Keyword, Time',
    description: 'Phát hiện chủ đề mới nổi',
    displayType: ChartDisplayType.bubbleChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 28,
    name: 'Citation Velocity',
    factTable: 'Paper',
    dimensionTable: 'Time, Keyword',
    description: 'Tốc độ tăng citation theo năm',
    displayType: ChartDisplayType.lineChart,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 29,
    name: 'Journal Migration',
    factTable: 'Paper',
    dimensionTable: 'Journal, Time',
    description: 'Chuyển dịch công bố giữa các Journal',
    displayType: ChartDisplayType.sankey,
    status: AnalyticsStatus.implemented,
  ),
  AnalyticsCatalogItem(
    no: 30,
    name: 'Research Ecosystem Overview',
    factTable: 'Paper',
    dimensionTable: 'Time, Journal, Author, Keyword, Country',
    description: 'Tổng quan hệ sinh thái nghiên cứu',
    displayType: ChartDisplayType.dashboard,
    status: AnalyticsStatus.implemented,
  ),
];

class ScatterPoint {
  final String label;
  final double x;
  final double y;

  const ScatterPoint({required this.label, required this.x, required this.y});
}

class BubblePoint {
  final String label;
  final double x;
  final double y;
  final double size;

  const BubblePoint({
    required this.label,
    required this.x,
    required this.y,
    required this.size,
  });
}

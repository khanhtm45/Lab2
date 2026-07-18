import '../models/analytics_catalog.dart';
import '../models/recent_search_entry.dart';
import '../models/research_insight.dart';
import '../models/search_filters.dart';
import 'app_strings.dart';

extension MomentumLevelL10n on MomentumLevel {
  String labelFor(AppStrings s) => switch (this) {
        MomentumLevel.high => s.momentumHigh,
        MomentumLevel.medium => s.momentumMedium,
        MomentumLevel.low => s.momentumLow,
        MomentumLevel.declining => s.momentumDeclining,
      };

  String insightTextFor(AppStrings s) => switch (this) {
        MomentumLevel.high => s.momentumStrongInsight,
        MomentumLevel.medium => s.momentumModerateInsight,
        MomentumLevel.low => s.momentumSlowedInsight,
        MomentumLevel.declining => s.momentumContractingInsight,
      };
}

extension SearchSortOptionL10n on SearchSortOption {
  String labelFor(AppStrings s) => switch (this) {
        SearchSortOption.relevance => s.sortRelevance,
        SearchSortOption.mostCited => s.sortMostCited,
        SearchSortOption.newest => s.sortNewest,
        SearchSortOption.oldest => s.sortOldest,
        SearchSortOption.alphabetical => s.sortAlphabetical,
      };
}

extension ChartDisplayTypeL10n on ChartDisplayType {
  String labelFor(AppStrings s) => switch (this) {
        ChartDisplayType.lineChart => s.chartLine,
        ChartDisplayType.horizontalBar => s.chartHorizontalBar,
        ChartDisplayType.areaChart => s.chartArea,
        ChartDisplayType.treemap => s.chartTreemap,
        ChartDisplayType.scatterPlot => s.chartScatter,
        ChartDisplayType.bubbleChart => s.chartBubble,
        ChartDisplayType.donutChart => s.chartDonut,
        ChartDisplayType.networkGraph => s.chartNetwork,
        ChartDisplayType.mapChart => s.chartMap,
        ChartDisplayType.heatmap => s.chartHeatmap,
        ChartDisplayType.sankey => s.chartSankey,
        ChartDisplayType.dashboard => s.chartDashboard,
      };
}

extension AnalyticsStatusL10n on AnalyticsStatus {
  String labelFor(AppStrings s) => switch (this) {
        AnalyticsStatus.implemented => s.statusLive,
        AnalyticsStatus.partial => s.statusPartial,
        AnalyticsStatus.planned => s.statusPlanned,
      };
}

extension AnalyticsCatalogItemL10n on AnalyticsCatalogItem {
  String localizedName(AppStrings s) => s.catalogName(no);
  String localizedDescription(AppStrings s) => s.catalogDescription(no);
  String localizedFactTable(AppStrings s) => s.catalogFactTable(factTable);
  String localizedDimensionTable(AppStrings s) =>
      s.catalogDimensionTable(dimensionTable);
}

extension RecentSearchEntryL10n on RecentSearchEntry {
  String relativeTimeLabelFor(AppStrings s) {
    final diff = DateTime.now().difference(searchedAt);
    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes.clamp(1, 59);
      return s.searchedMinutesAgo(minutes);
    }
    if (diff.inHours < 24) {
      return s.searchedHoursAgo(diff.inHours);
    }
    if (diff.inDays == 1) return s.searchedYesterday;
    if (diff.inDays < 7) return s.searchedDaysAgo(diff.inDays);
    return s.searchedOnDate(searchedAt);
  }
}

String publicationTypeLabel(AppStrings s, String? type) {
  if (type == null || type.isEmpty) return s.unknownType;
  return switch (type.toLowerCase()) {
    'article' => s.typeArticle,
    'review' => s.typeReview,
    'preprint' => s.typePreprint,
    'dataset' => s.typeDataset,
    'book-chapter' || 'book_chapter' => s.typeBookChapter,
    'book' => s.typeBook,
    'proceedings-article' => s.typeProceedings,
    _ => type,
  };
}

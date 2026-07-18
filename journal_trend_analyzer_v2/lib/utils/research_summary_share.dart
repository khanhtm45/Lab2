import '../l10n/app_strings.dart';
import '../providers/publication_provider.dart';
import '../utils/count_format.dart';

/// Builds a plain-text research summary for clipboard / lab reports.
String buildResearchSummaryText({
  required PublicationProvider provider,
  required AppStrings strings,
  int? yearFrom,
  int? yearTo,
}) {
  final topic = provider.isGlobalScope
      ? strings.globalResearch
      : provider.currentTopic;
  final trend = provider.yearlyTrendFromOpenAlex;
  final filteredTrend = (yearFrom != null && yearTo != null)
      ? Map.fromEntries(
          trend.entries.where(
            (e) => e.key >= yearFrom && e.key <= yearTo,
          ),
        )
      : trend;

  final buffer = StringBuffer()
    ..writeln('${strings.researchDashboard} — $topic')
    ..writeln('${strings.generatedBy} Journal Trend Analyzer')
    ..writeln('');

  buffer.writeln('${strings.totalPublications}: ${formatOpenAlexCount(provider.totalOnOpenAlex)}');
  buffer.writeln(
    '${strings.averageCitations}: ${provider.averageCitationOpenAlex.toStringAsFixed(1)}',
  );

  if (filteredTrend.isNotEmpty) {
    final peak = filteredTrend.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    buffer.writeln('${strings.mostActiveYear}: ${peak.key} (${formatOpenAlexCount(peak.value)})');
  }

  final growth = provider.landscapePulse.yoyGrowthPercent;
  final sign = growth >= 0 ? '+' : '';
  buffer.writeln('${strings.growthRate}: $sign${growth.toStringAsFixed(1)}%');

  final insight = provider.trendInsight;
  if (insight.headline.isNotEmpty) {
    buffer
      ..writeln('')
      ..writeln(strings.trendInsight)
      ..writeln(insight.headline);
    if (insight.summary.isNotEmpty) {
      buffer.writeln(insight.summary);
    }
  }

  if (provider.topJournalsOpenAlex.isNotEmpty) {
    buffer
      ..writeln('')
      ..writeln('${strings.topJournal}: ${provider.topJournalsOpenAlex.first.name}');
  }
  if (provider.topAuthorsOpenAlex.isNotEmpty) {
    buffer.writeln('${strings.topAuthor}: ${provider.topAuthorsOpenAlex.first.name}');
  }
  if (provider.topPapersOpenAlex.isNotEmpty) {
    final paper = provider.topPapersOpenAlex.first;
    buffer.writeln('${strings.mostInfluentialPaper}: ${paper.title} (${paper.citations} ${strings.citations})');
  }
  if (provider.topCountriesOpenAlex.isNotEmpty) {
    buffer.writeln('${strings.topCountry}: ${provider.topCountriesOpenAlex.first.name}');
  }

  buffer.writeln('');
  buffer.writeln(strings.shareFooter);

  return buffer.toString().trim();
}

import '../l10n/app_strings.dart';
import '../l10n/l10n_models.dart';
import '../models/research_insight.dart';
import '../models/openalex_ranked_entity.dart';
import '../models/publication.dart';
import 'count_format.dart';

class ResearchInsights {
  static TrendInsight analyzeTrend({
    required AppStrings strings,
    required Map<int, int> volumeByYear,
    Map<int, int>? citationsByYear,
    String? topicLabel,
  }) {
    if (volumeByYear.length < 2) return TrendInsight.emptyFor(strings);

    final years = volumeByYear.keys.toList()..sort();
    final startYear = years.first;
    final endYear = years.last;
    final startCount = volumeByYear[startYear] ?? 0;
    final endCount = volumeByYear[endYear] ?? 0;

    final periodGrowth = _percentChange(startCount, endCount);
    final yoyGrowth = years.length >= 2
        ? _percentChange(
            volumeByYear[years[years.length - 2]] ?? 0,
            volumeByYear[years.last] ?? 0,
          )
        : 0.0;

    final annualRates = <double>[];
    for (var i = 1; i < years.length; i++) {
      final prev = volumeByYear[years[i - 1]] ?? 0;
      final curr = volumeByYear[years[i]] ?? 0;
      if (prev > 0) annualRates.add(_percentChange(prev, curr));
    }
    final avgAnnual = annualRates.isEmpty
        ? 0.0
        : annualRates.reduce((a, b) => a + b) / annualRates.length;

    final peakEntry = volumeByYear.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    final momentum = _momentumFromRates(annualRates, periodGrowth);
    final label = topicLabel ?? strings.researchPublications;
    final headline = _headline(
      strings: strings,
      label: label,
      periodGrowth: periodGrowth,
      startYear: startYear,
      endYear: endYear,
    );
    final summary = _summary(
      strings: strings,
      periodGrowth: periodGrowth,
      startYear: startYear,
      endYear: endYear,
      peakYear: peakEntry.key,
      momentum: momentum,
    );

    final citationNote = _citationDivergenceNote(
      strings: strings,
      volumeByYear: volumeByYear,
      citationsByYear: citationsByYear,
      years: years,
    );

    return TrendInsight(
      periodGrowthPercent: periodGrowth,
      yoyGrowthPercent: yoyGrowth,
      avgAnnualGrowthPercent: avgAnnual,
      peakYear: peakEntry.key,
      startYear: startYear,
      endYear: endYear,
      momentum: momentum,
      headline: headline,
      summary: summary,
      citationNote: citationNote,
    );
  }

  static double computeConceptGrowth(Map<int, int> yearlyTrend) {
    if (yearlyTrend.length < 2) return 0;

    final years = yearlyTrend.keys.toList()..sort();
    if (years.length < 4) {
      final first = yearlyTrend[years.first] ?? 0;
      final last = yearlyTrend[years.last] ?? 0;
      return _percentChange(first, last);
    }

    final mid = years.length ~/ 2;
    final earlyYears = years.sublist(0, mid);
    final lateYears = years.sublist(mid);

    final earlySum = earlyYears.fold<int>(
      0,
      (sum, year) => sum + (yearlyTrend[year] ?? 0),
    );
    final lateSum = lateYears.fold<int>(
      0,
      (sum, year) => sum + (yearlyTrend[year] ?? 0),
    );

    return _percentChange(earlySum, lateSum);
  }

  static LandscapePulse buildLandscapePulse({
    required AppStrings strings,
    required int totalPublications,
    required Map<int, int> volumeByYear,
    required double averageCitations,
  }) {
    final insight = analyzeTrend(strings: strings, volumeByYear: volumeByYear);
    return LandscapePulse(
      totalPublications: totalPublications,
      yoyGrowthPercent: insight.yoyGrowthPercent,
      peakYear: insight.peakYear,
      averageCitations: averageCitations,
      summary: insight.summary,
    );
  }

  static TopicSnapshot buildTopicSnapshot({
    required AppStrings strings,
    required String topic,
    required int totalPublications,
    required Map<int, int> volumeByYear,
    required Map<int, int> citationsByYear,
    OpenAlexRankedEntity? topJournal,
  }) {
    final insight = analyzeTrend(
      strings: strings,
      volumeByYear: volumeByYear,
      citationsByYear: citationsByYear,
      topicLabel: topic,
    );

    return TopicSnapshot(
      topic: topic,
      totalPublications: totalPublications,
      growthPercent: insight.periodGrowthPercent,
      peakYear: insight.peakYear,
      topJournal: topJournal?.name,
      momentum: insight.momentum,
      insightLine: insight.headline,
    );
  }

  static String influentialPapersInsight(
    AppStrings strings,
    List<Publication> papers,
  ) {
    if (papers.isEmpty) return strings.influentialPapersLoading;
    final top = papers.first;
    if (top.citations >= 50000) {
      return strings.influentialPapersLandmark(
        formatOpenAlexCount(top.citations),
      );
    }
    return strings.influentialPapersJournal(top.journal);
  }

  static String researchLeadersInsight(
    AppStrings strings,
    List<OpenAlexRankedEntity> authors,
  ) {
    if (authors.isEmpty) return strings.researchLeadersLoading;
    final leader = authors.first;
    return strings.researchLeaderLeads(
      leader.name,
      formatOpenAlexCount(leader.count),
    );
  }

  static String journalPowerInsight(
    AppStrings strings,
    List<OpenAlexRankedEntity> journals,
  ) {
    if (journals.isEmpty) return strings.journalPowerLoading;
    if (journals.length == 1) {
      return strings.journalPowerDominant(journals.first.name);
    }
    return strings.journalPowerTopTwo(
      journals.first.name,
      journals[1].name,
    );
  }

  static String formatGrowth(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.round()}%';
  }

  static double _percentChange(int from, int to) {
    if (from <= 0) return to > 0 ? 100 : 0;
    return ((to - from) / from) * 100;
  }

  static MomentumLevel _momentumFromRates(
    List<double> annualRates,
    double periodGrowth,
  ) {
    if (annualRates.isEmpty) {
      if (periodGrowth >= 40) return MomentumLevel.high;
      if (periodGrowth >= 10) return MomentumLevel.medium;
      if (periodGrowth < 0) return MomentumLevel.declining;
      return MomentumLevel.low;
    }

    final recent = annualRates.length >= 3
        ? annualRates.sublist(annualRates.length - 3)
        : annualRates;
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;

    if (recentAvg >= 25 || periodGrowth >= 80) return MomentumLevel.high;
    if (recentAvg >= 5 || periodGrowth >= 20) return MomentumLevel.medium;
    if (recentAvg < -5 || periodGrowth < 0) return MomentumLevel.declining;
    return MomentumLevel.low;
  }

  static String _headline({
    required AppStrings strings,
    required String label,
    required double periodGrowth,
    required int startYear,
    required int endYear,
  }) {
    final growth = formatGrowth(periodGrowth);
    if (periodGrowth >= 50) {
      return strings.insightHeadlineStrongGrowth(
        label,
        growth,
        startYear,
        endYear,
      );
    }
    if (periodGrowth >= 0) {
      return strings.insightHeadlineSteadyGrowth(
        label,
        growth,
        startYear,
        endYear,
      );
    }
    return strings.insightHeadlineCooled(label, growth, startYear, endYear);
  }

  static String _summary({
    required AppStrings strings,
    required double periodGrowth,
    required int startYear,
    required int endYear,
    required int peakYear,
    required MomentumLevel momentum,
  }) {
    return strings.insightSummary(
      formatGrowth(periodGrowth),
      startYear,
      endYear,
      peakYear,
      momentum.insightTextFor(strings),
    );
  }

  static String? _citationDivergenceNote({
    required AppStrings strings,
    required Map<int, int> volumeByYear,
    Map<int, int>? citationsByYear,
    required List<int> years,
  }) {
    if (citationsByYear == null || citationsByYear.length < 2) return null;

    final volStart = volumeByYear[years.first] ?? 0;
    final volEnd = volumeByYear[years.last] ?? 0;
    final citeStart = citationsByYear[years.first] ?? 0;
    final citeEnd = citationsByYear[years.last] ?? 0;

    final volGrowth = _percentChange(volStart, volEnd);
    final citeGrowth = _percentChange(citeStart, citeEnd);

    if (volGrowth > 15 && citeGrowth < 0) {
      return strings.citationDivergenceVolumeUp;
    }
    if (volGrowth < 10 && citeGrowth > 25) {
      return strings.citationDivergenceQuality;
    }
    if (volGrowth > 20 && citeGrowth > 20) {
      return strings.citationDivergenceBothUp;
    }
    return null;
  }
}

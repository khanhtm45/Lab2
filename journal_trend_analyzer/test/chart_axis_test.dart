import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/utils/chart_axis.dart';

void main() {
  group('TrendChartLayout', () {
    test('computes axis bounds for yearly counts', () {
      final layout = TrendChartLayout.fromYearlyCounts({
        2020: 10,
        2021: 20,
        2022: 30,
      });

      expect(layout.years, [2020, 2021, 2022]);
      expect(layout.chartMinY, greaterThanOrEqualTo(0));
      expect(layout.chartMaxY, greaterThan(layout.chartMinY));
      expect(layout.yInterval, greaterThan(0));
      expect(layout.labelInterval, 1);
    });

    test('uses wider label interval for long series', () {
      final data = {for (var year = 2010; year <= 2025; year++) year: year - 2000};
      final layout = TrendChartLayout.fromYearlyCounts(data);

      expect(layout.labelInterval, greaterThan(1));
    });
  });

  group('niceChartInterval', () {
    test('returns 1 for non-positive range', () {
      expect(niceChartInterval(0), 1);
      expect(niceChartInterval(-5), 1);
    });

    test('returns rounded interval for positive range', () {
      expect(niceChartInterval(100), greaterThan(0));
    });
  });

  group('formatSignedPercent', () {
    test('adds plus prefix for positive values', () {
      expect(formatSignedPercent(12.3), '+12.3%');
    });

    test('keeps minus prefix for negative values', () {
      expect(formatSignedPercent(-4.5), '-4.5%');
    });
  });
}

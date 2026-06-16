import 'dart:math' as math;

class TrendChartLayout {
  const TrendChartLayout({
    required this.years,
    required this.chartMinY,
    required this.chartMaxY,
    required this.yInterval,
    required this.labelInterval,
  });

  final List<int> years;
  final double chartMinY;
  final double chartMaxY;
  final double yInterval;
  final int labelInterval;

  factory TrendChartLayout.fromYearlyCounts(Map<int, int> yearlyData) {
    final years = yearlyData.keys.toList()..sort();
    final values = yearlyData.values.map((v) => v.toDouble()).toList();
    final maxY = values.reduce(math.max);
    final minY = values.reduce(math.min);
    final range = maxY - minY;
    final padding = range > 0 ? range * 0.15 : math.max(1.0, maxY.abs() * 0.1);

    var chartMinY = minY - padding;
    var chartMaxY = maxY + padding;
    if (minY >= 0 && chartMinY < 0) chartMinY = 0;
    if (chartMaxY <= chartMinY) chartMaxY = chartMinY + 1;

    return TrendChartLayout(
      years: years,
      chartMinY: chartMinY,
      chartMaxY: chartMaxY,
      yInterval: niceChartInterval(chartMaxY - chartMinY),
      labelInterval: years.length <= 6 ? 1 : (years.length / 5).ceil(),
    );
  }
}

double niceChartInterval(double range) {
  if (range <= 0) return 1;
  final raw = range / 4;
  final magnitude =
      chartPow10(raw.floor().toString().length - 1).clamp(1, 1000000000);
  final normalized = raw / magnitude;
  final nice = normalized <= 1
      ? 1
      : normalized <= 2
          ? 2
          : normalized <= 5
              ? 5
              : 10;
  return (nice * magnitude).toDouble();
}

double chartPow10(int exponent) {
  var value = 1.0;
  for (var i = 0; i < exponent; i++) {
    value *= 10;
  }
  return value;
}

String formatSignedPercent(double value, {int fractionDigits = 1}) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(fractionDigits)}%';
}

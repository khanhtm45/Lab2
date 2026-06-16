import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/widgets/trend_chart.dart';

void main() {
  testWidgets('TrendChart shows empty message when no data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrendChart(yearlyData: {}),
        ),
      ),
    );

    expect(find.text('No trend data available'), findsOneWidget);
  });

  testWidgets('TrendChart renders chart for yearly data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrendChart(
            yearlyData: {2022: 10, 2023: 20, 2024: 30},
          ),
        ),
      ),
    );

    expect(find.byType(TrendChart), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/l10n/app_strings.dart';
import 'package:journal_trend_analyzer/services/app_preferences.dart';
import 'package:journal_trend_analyzer/theme/app_theme.dart';
import 'package:journal_trend_analyzer/widgets/distribution_chart.dart';

Widget _wrap(Widget child, {AppPreferences? prefs}) {
  final preferences = prefs ?? AppPreferences();
  return ChangeNotifierProvider<AppPreferences>.value(
    value: preferences,
    child: MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('resolvePieTouchIndex', () {
    test('returns null for negative index', () {
      expect(resolvePieTouchIndex(-1, 2), isNull);
    });
  });

  group('DistributionChart widget', () {
    testWidgets('shows localized open access legend in English', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DistributionChart(
            data: {'true': 60, 'false': 40},
            donut: true,
            height: 160,
          ),
        ),
      );

      expect(find.textContaining('Open Access'), findsWidgets);
      expect(find.textContaining('Non-OA'), findsWidgets);
    });

    testWidgets('legend tap shows exact count detail', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DistributionChart(
            data: {'true': 60, 'false': 40},
            donut: true,
            height: 160,
          ),
        ),
      );

      await tester.tap(find.textContaining('Open Access').last);
      await tester.pump();

      expect(find.textContaining('Open Access: 60'), findsOneWidget);
      expect(find.textContaining('40.0%'), findsNothing);
    });

    testWidgets('shows Vietnamese labels when language is vi', (tester) async {
      final prefs = AppPreferences()..language = AppLanguage.vietnamese;

      await tester.pumpWidget(
        _wrap(
          const DistributionChart(
            data: {'true': 10, 'false': 5},
            height: 160,
          ),
          prefs: prefs,
        ),
      );

      expect(find.textContaining('Truy cập mở'), findsWidgets);
      expect(find.textContaining('Không OA'), findsWidgets);
    });

    testWidgets('tapping legend twice clears detail', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DistributionChart(
            data: {'true': 60, 'false': 40},
            height: 160,
          ),
        ),
      );

      final legend = find.textContaining('Open Access').last;
      await tester.tap(legend);
      await tester.pump();
      expect(find.textContaining('Open Access: 60'), findsOneWidget);

      await tester.tap(legend);
      await tester.pump();
      expect(find.textContaining('Open Access: 60'), findsNothing);
    });
  });
}

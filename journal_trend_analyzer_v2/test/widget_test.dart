import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/theme/app_theme.dart';
import 'package:journal_trend_analyzer/providers/app_navigation_provider.dart';
import 'package:journal_trend_analyzer/providers/publication_provider.dart';
import 'package:journal_trend_analyzer/screens/main_shell.dart';
import 'package:journal_trend_analyzer/services/openalex_config.dart';

void main() {
  testWidgets('Journal Trend Analyzer shell smoke test', (WidgetTester tester) async {
    final config = OpenAlexConfig();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OpenAlexConfig>.value(value: config),
          ChangeNotifierProvider(
            create: (context) => PublicationProvider(
              config: context.read<OpenAlexConfig>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => AppNavigationProvider()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const MainShell(),
        ),
      ),
    );

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Journal Trend Analyzer'), findsOneWidget);
  });
}

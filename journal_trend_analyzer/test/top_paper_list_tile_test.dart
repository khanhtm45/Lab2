import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/widgets/top_paper_list_tile.dart';

void main() {
  testWidgets('TopPaperListTile shows title and citation count', (tester) async {
    final paper = Publication(
      id: 'W1',
      title: 'Deep Learning Survey',
      year: 2024,
      citations: 1200,
      journal: 'Nature AI',
      doi: '',
      authorEntries: const [],
      abstractText: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopPaperListTile(
            rank: 1,
            paper: paper,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Deep Learning Survey'), findsOneWidget);
    expect(find.text('1.2K\ncites'), findsOneWidget);
    expect(find.text('Year: 2024 · Journal: Nature AI'), findsOneWidget);
  });
}

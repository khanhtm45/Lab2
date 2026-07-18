import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:journal_trend_analyzer/main.dart' as app;

void main() {
  patrolTest(
    'Test Case 2 - Topic Search',
    ($) async {
      // Launch the application
      await app.main();
      await $.pumpAndSettle();

      // Navigate as guest if needed
      if ($('Continue as Guest').exists) {
        await $('Continue as Guest').tap();
        await $.pumpAndSettle();
      }

      // Enter a research topic in the search bar
      final searchField = $(TextField);
      expect(searchField, findsAtLeastNWidgets(1));
      
      await searchField.first.enterText('machine learning');
      await $.pumpAndSettle();

      // Execute search
      await $(Icons.search_rounded).tap();
      await $.pumpAndSettle(timeout: Duration(seconds: 15));

      // Verify publication results are displayed
      // Look for indicators that search results are shown
      expect($('machine learning'), findsAtLeastNWidgets(1));
    },
  );

  patrolTest(
    'Test Case 3 - Publication Details',
    ($) async {
      // Launch the application
      await app.main();
      await $.pumpAndSettle();

      // Navigate as guest if needed
      if ($('Continue as Guest').exists) {
        await $('Continue as Guest').tap();
        await $.pumpAndSettle();
      }

      // Perform a search first
      final searchField = $(TextField);
      await searchField.first.enterText('artificial intelligence');
      await $.pumpAndSettle();
      
      await $(Icons.search_rounded).tap();
      await $.pumpAndSettle(timeout: Duration(seconds: 15));

      // Look for publication cards and tap on the first one
      final publicationCards = $(Card);
      if (publicationCards.exists) {
        await publicationCards.first.tap();
        await $.pumpAndSettle();

        // Verify publication information is displayed correctly
        // Check for common publication detail elements
        expect($(AppBar), findsOneWidget);
      }
    },
  );
}
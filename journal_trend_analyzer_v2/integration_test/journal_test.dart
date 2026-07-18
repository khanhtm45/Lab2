import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:journal_trend_analyzer/main.dart' as app;

void main() {
  patrolTest(
    'Test Case 4 - Journals Navigation',
    ($) async {
      // Launch the application
      await app.main();
      await $.pumpAndSettle();

      // Navigate as guest if needed
      if ($('Continue as Guest').exists) {
        await $('Continue as Guest').tap();
        await $.pumpAndSettle();
      }

      // Navigate to the Journals tab
      final bottomNav = $(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);
      
      // Tap on Journals tab (index 1)
      await $('Journals').tap();
      await $.pumpAndSettle();

      // Verify journal statistics and journal list are displayed
      expect($('Search Journals'), findsOneWidget);
      expect($('Popular Journals'), findsOneWidget);
    },
  );

  patrolTest(
    'Test Case 5 - Journal Details',
    ($) async {
      // Launch the application
      await app.main();
      await $.pumpAndSettle();

      // Navigate as guest if needed
      if ($('Continue as Guest').exists) {
        await $('Continue as Guest').tap();
        await $.pumpAndSettle();
      }

      // Navigate to Journals tab
      await $('Journals').tap();
      await $.pumpAndSettle();

      // Search for a journal
      final searchField = $(TextField);
      await searchField.first.enterText('Nature');
      await $.pumpAndSettle();

      // Execute search
      await $(Icons.arrow_forward_rounded).tap();
      await $.pumpAndSettle(timeout: Duration(seconds: 15));

      // Open a journal from the journal list
      final journalCards = $(Card);
      if (journalCards.exists) {
        await journalCards.first.tap();
        await $.pumpAndSettle();

        // Verify journal details are displayed correctly
        expect($(AppBar), findsOneWidget);
        // Look for journal-specific information
        expect($('Publications'), findsAtLeastNWidgets(1));
      }
    },
  );
}
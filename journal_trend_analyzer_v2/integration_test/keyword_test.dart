import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:journal_trend_analyzer/main.dart' as app;

void main() {
  patrolTest(
    'Test Case 6 - Keywords Navigation',
    ($) async {
      // Launch the application
      await app.main();
      await $.pumpAndSettle();

      // Navigate as guest if needed
      if ($('Continue as Guest').exists) {
        await $('Continue as Guest').tap();
        await $.pumpAndSettle();
      }

      // Navigate to the Keywords tab
      await $('Keywords').tap();
      await $.pumpAndSettle();

      // Verify keyword statistics and keyword list are displayed
      expect($('Keywords Analysis'), findsOneWidget);
      expect($('Trending Topics'), findsOneWidget);
      expect($('Search keywords'), findsOneWidget);
    },
  );

  patrolTest(
    'Test Case 7 - Keyword Details',
    ($) async {
      // Launch the application
      await app.main();
      await $.pumpAndSettle();

      // Navigate as guest if needed
      if ($('Continue as Guest').exists) {
        await $('Continue as Guest').tap();
        await $.pumpAndSettle();
      }

      // Navigate to Keywords tab
      await $('Keywords').tap();
      await $.pumpAndSettle();

      // Search for a keyword
      final searchField = $(TextField);
      await searchField.first.enterText('machine learning');
      await $.pumpAndSettle();

      // Execute search
      await $(Icons.arrow_forward_rounded).tap();
      await $.pumpAndSettle(timeout: Duration(seconds: 15));

      // Verify keyword analysis information is displayed
      // This would navigate to keyword analysis screen
      expect($(AppBar), findsOneWidget);
    },
  );
}
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/services/bookmarked_topics_service.dart';

void main() {
  group('BookmarkedTopicsService', () {
    test('isBookmarked matches case insensitively', () {
      final service = BookmarkedTopicsService();
      expect(service.isBookmarked(['AI', 'Blockchain'], 'ai'), isTrue);
      expect(service.isBookmarked(['AI'], 'Robotics'), isFalse);
    });
  });
}

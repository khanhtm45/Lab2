import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/utils/count_format.dart';

void main() {
  group('formatOpenAlexCount', () {
    test('formats billions', () {
      expect(formatOpenAlexCount(2500000000), '2.5B');
    });

    test('formats millions', () {
      expect(formatOpenAlexCount(1200000), '1.2M');
    });

    test('formats thousands', () {
      expect(formatOpenAlexCount(1200), '1.2K');
    });

    test('returns plain number for small values', () {
      expect(formatOpenAlexCount(42), '42');
    });
  });

  group('formatOpenAlexCountFull', () {
    test('adds thousands separators', () {
      expect(formatOpenAlexCountFull(1234567), '1,234,567');
    });
  });
}

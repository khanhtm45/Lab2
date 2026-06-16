import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:journal_trend_analyzer/models/search_filters.dart';

void main() {
  test('SearchFilters.isActive is false by default', () {
    expect(const SearchFilters().isActive, isFalse);
  });

  test('SearchFilters.isActive detects year filter', () {
    expect(const SearchFilters(publicationYear: 2024).isActive, isTrue);
  });

  test('SearchSortOption exposes API sort values', () {
    expect(SearchSortOption.mostCited.apiValue, 'cited_by_count:desc');
    expect(SearchSortOption.newest.apiValue, 'publication_year:desc');
  });
}

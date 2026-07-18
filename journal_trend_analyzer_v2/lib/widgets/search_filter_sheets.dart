import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/search_filters.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';

Future<void> showSearchFilterSheet(BuildContext context) async {
  final provider = context.read<PublicationProvider>();
  var filters = provider.searchFilters;
  var yearFrom = filters.yearFrom ?? 2019;
  var yearTo = filters.yearTo ?? 2025;
  var sort = provider.searchSort;
  var openAccess = filters.openAccessOnly ?? true;
  var selectedTypes = Set<String>.from(filters.publicationTypes);
  if (selectedTypes.isEmpty) {
    selectedTypes = {'article', 'review'};
  }

  const typeOptionKeys = [
    'article',
    'review',
    'preprint',
    'dataset',
    'book-chapter',
  ];

  final years = List.generate(
    DateTime.now().year - 1999,
    (i) => 2000 + i,
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(ctx).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.filterPublications,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            yearFrom = 2019;
                            yearTo = 2025;
                            sort = SearchSortOption.mostCited;
                            openAccess = true;
                            selectedTypes = {'article', 'review'};
                          });
                        },
                        child: Text(
                          s.reset,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterLabel(s.publicationYear),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _YearDropdown(
                                label: s.fromYear,
                                value: yearFrom,
                                years: years,
                                onChanged: (v) =>
                                    setModalState(() => yearFrom = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _YearDropdown(
                                label: s.toYear,
                                value: yearTo,
                                years: years,
                                onChanged: (v) =>
                                    setModalState(() => yearTo = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _FilterLabel(s.sortBy),
                        const SizedBox(height: 10),
                        SegmentedButton<SearchSortOption>(
                          segments: [
                            ButtonSegment(
                              value: SearchSortOption.relevance,
                              label: Text(
                                SearchSortOption.relevance.labelFor(s),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            ButtonSegment(
                              value: SearchSortOption.mostCited,
                              label: Text(
                                SearchSortOption.mostCited.labelFor(s),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            ButtonSegment(
                              value: SearchSortOption.newest,
                              label: Text(
                                SearchSortOption.newest.labelFor(s),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                          selected: {sort},
                          onSelectionChanged: (values) {
                            setModalState(() => sort = values.first);
                          },
                        ),
                        const SizedBox(height: 22),
                        _FilterLabel(s.publicationType),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: typeOptionKeys.map((key) {
                            final label = publicationTypeLabel(s, key);
                            final selected = selectedTypes.contains(key);
                            return FilterChip(
                              label: Text(label),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor:
                                  AppColors.analyticsTeal.withValues(alpha: 0.18),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? AppColors.analyticsTeal
                                    : AppColors.textSecondary,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.analyticsTeal
                                    : AppColors.border,
                              ),
                              onSelected: (value) {
                                setModalState(() {
                                  if (value) {
                                    selectedTypes.add(key);
                                  } else {
                                    selectedTypes.remove(key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            s.showOpenAccessOnly,
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: openAccess,
                          activeTrackColor:
                              AppColors.secondary.withValues(alpha: 0.35),
                          activeThumbColor: AppColors.secondary,
                          onChanged: (v) =>
                              setModalState(() => openAccess = v),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        provider.updateSearchSort(sort);
                        provider.updateSearchFilters(
                          SearchFilters(
                            yearFrom: yearFrom,
                            yearTo: yearTo,
                            openAccessOnly: openAccess ? true : null,
                            publicationTypes: selectedTypes,
                          ),
                        );
                        Navigator.pop(ctx);
                        if (!provider.isGlobalScope) {
                          provider.searchPublications(provider.currentTopic);
                        }
                      },
                      child: Text(s.applyFilters),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showSearchSortSheet(BuildContext context) async {
  final provider = context.read<PublicationProvider>();

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.sortBy,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            ...SearchSortOption.values.map((option) {
              return RadioListTile<SearchSortOption>(
                title: Text(option.labelFor(s)),
                value: option,
                groupValue: provider.searchSort,
                activeColor: AppColors.secondary,
                onChanged: (value) {
                  if (value == null) return;
                  provider.updateSearchSort(value);
                  Navigator.pop(ctx);
                  if (!provider.isGlobalScope) {
                    provider.searchPublications(provider.currentTopic);
                  }
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

class _FilterLabel extends StatelessWidget {
  final String text;

  const _FilterLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.primary,
      ),
    );
  }
}

class _YearDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<int> years;
  final ValueChanged<int> onChanged;

  const _YearDropdown({
    required this.label,
    required this.value,
    required this.years,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          items: years
              .map(
                (y) => DropdownMenuItem(value: y, child: Text('$y')),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

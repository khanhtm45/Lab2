import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/search_filters.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';

Future<void> showSearchFilterSheet(BuildContext context) async {
  final provider = context.read<PublicationProvider>();
  var filters = provider.searchFilters;
  final yearController = TextEditingController(
    text: filters.publicationYear?.toString() ?? '',
  );
  final citationController = TextEditingController(
    text: filters.minCitations?.toString() ?? '',
  );
  var openAccess = filters.openAccessOnly ?? false;
  String? pubType = filters.publicationType;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;

      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Publications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Publication Year',
                      hintText: 'e.g. 2024',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: citationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Citation Count',
                      hintText: 'e.g. 50',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Open Access only'),
                    value: openAccess,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setModalState(() => openAccess = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: pubType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Publication Type',
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Any')),
                      DropdownMenuItem(value: 'article', child: Text('Article')),
                      DropdownMenuItem(value: 'review', child: Text('Review')),
                      DropdownMenuItem(value: 'book', child: Text('Book')),
                      DropdownMenuItem(value: 'dataset', child: Text('Dataset')),
                    ],
                    onChanged: (v) => setModalState(() => pubType = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.updateSearchFilters(const SearchFilters());
                          Navigator.pop(ctx);
                          if (!provider.isGlobalScope) {
                            provider.searchPublications(provider.currentTopic);
                          }
                        },
                        child: const Text('Clear'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          final year = int.tryParse(yearController.text.trim());
                          final citations =
                              int.tryParse(citationController.text.trim());
                          provider.updateSearchFilters(
                            SearchFilters(
                              publicationYear: year,
                              minCitations: citations,
                              openAccessOnly: openAccess ? true : null,
                              publicationType: pubType,
                            ),
                          );
                          Navigator.pop(ctx);
                          if (!provider.isGlobalScope) {
                            provider.searchPublications(provider.currentTopic);
                          }
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  yearController.dispose();
  citationController.dispose();
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
      return SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              ...SearchSortOption.values.map(
                (option) => ListTile(
                  title: Text(option.label),
                  trailing: provider.searchSort == option
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    provider.updateSearchSort(option);
                    Navigator.pop(ctx);
                    if (!provider.isGlobalScope) {
                      provider.searchPublications(provider.currentTopic);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

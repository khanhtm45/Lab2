import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_loading_view.dart';
import '../utils/count_format.dart';

class LoadMoreFooter extends StatelessWidget {
  final int loadedCount;
  final int totalCount;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const LoadMoreFooter({
    super.key,
    required this.loadedCount,
    required this.totalCount,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0 && !isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Showing ${formatOpenAlexCount(loadedCount)} of '
            '${formatOpenAlexCount(totalCount)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (hasMore) ...[
            const SizedBox(height: 8),
            if (isLoading)
              const AppLoadingIndicator(size: 32)
            else
              OutlinedButton(
                onPressed: onLoadMore,
                child: const Text('Load more'),
              ),
          ],
        ],
      ),
    );
  }
}

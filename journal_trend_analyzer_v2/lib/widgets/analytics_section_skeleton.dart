import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';

/// Placeholder while a single analytics section loads extra OpenAlex data.
class AnalyticsChartSkeleton extends StatelessWidget {
  final double height;

  const AnalyticsChartSkeleton({super.key, this.height = 180});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Inline retry when extra analytics data fails to load.
class AnalyticsSectionError extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const AnalyticsSectionError({
    super.key,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: palette.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            message ?? s.chartLoadFailed,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: palette.textSecondary),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(s.retry),
          ),
        ],
      ),
    );
  }
}

bool analyticsItemNeedsExtraData(int itemNo) {
  return const {
    3, 4, 5, 6, 8, 9, 11, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 29, 30,
  }.contains(itemNo);
}

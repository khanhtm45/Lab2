import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import 'trend_chart.dart';

class EntityStatCol extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;

  const EntityStatCol({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }
}

class TrendSectionCard extends StatelessWidget {
  final Map<int, int> yearlyData;
  final String emptyMessage;

  const TrendSectionCard({
    super.key,
    required this.yearlyData,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return Text(
        emptyMessage,
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }
    return TrendChart(yearlyData: yearlyData);
  }
}

class DetailRetryState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DetailRetryState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton(
            onPressed: onRetry,
            child: Text(s.retry),
          ),
        ],
      ),
    );
  }
}

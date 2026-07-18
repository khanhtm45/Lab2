import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

class OpenAlexInfoCard extends StatelessWidget {
  const OpenAlexInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s.apiKeyUsageInfo,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum OpenAlexConnectionState {
  unknown,
  testing,
  success,
  failed,
  notConfigured,
}

class OpenAlexConnectionCard extends StatelessWidget {
  final OpenAlexConnectionState state;
  final String? errorMessage;

  const OpenAlexConnectionCard({
    super.key,
    required this.state,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final (icon, color, title, subtitle) = switch (state) {
      OpenAlexConnectionState.testing => (
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          AppColors.secondary,
          s.testingConnection,
          s.verifyingOpenAlex,
        ),
      OpenAlexConnectionState.success => (
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.analyticsTeal,
            size: 24,
          ),
          AppColors.analyticsTeal,
          s.connectionSuccessful,
          s.openAlexReady,
        ),
      OpenAlexConnectionState.failed => (
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
          AppColors.error,
          s.connectionFailed,
          errorMessage ?? s.unableToReachOpenAlex,
        ),
      OpenAlexConnectionState.notConfigured => (
          const Icon(
            Icons.link_off_rounded,
            color: AppColors.textTertiary,
            size: 24,
          ),
          AppColors.textTertiary,
          s.noApiKeyConfigured,
          s.addKeyForRateLimits,
        ),
      OpenAlexConnectionState.unknown => (
          const Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.textTertiary,
            size: 24,
          ),
          AppColors.textTertiary,
          s.connectionNotTested,
          s.tapTestConnection,
        ),
    };

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 28, height: 28, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color == AppColors.textTertiary
                        ? AppColors.textPrimary
                        : color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

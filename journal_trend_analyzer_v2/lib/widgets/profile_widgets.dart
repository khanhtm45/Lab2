import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../services/app_preferences.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String version;

  const ProfileHeaderCard({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
      child: Column(
        children: [
          const JournalTrendLogo.full(size: 152),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: palette.accent.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              s.versionLabel(version),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: palette.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        PremiumCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class ProfileMenuRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;

  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (value != null) ...[
                    Text(
                      value!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 66,
            color: AppColors.border.withValues(alpha: 0.7),
          ),
      ],
    );
  }
}

Future<AppAppearance?> showAppearanceSheet(
  BuildContext context,
  AppAppearance current,
) {
  return showModalBottomSheet<AppAppearance>(
    context: context,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return _PreferenceSheet<AppAppearance>(
        title: s.appearance,
        options: AppAppearance.values,
        current: current,
        labelBuilder: (value) => switch (value) {
          AppAppearance.light => s.lightMode,
          AppAppearance.dark => s.darkMode,
          AppAppearance.system => s.systemDefault,
        },
      );
    },
  );
}

Future<AppLanguage?> showLanguageSheet(
  BuildContext context,
  AppLanguage current,
) {
  return showModalBottomSheet<AppLanguage>(
    context: context,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return _PreferenceSheet<AppLanguage>(
        title: s.languageSection,
        options: AppLanguage.values,
        current: current,
        labelBuilder: (value) => switch (value) {
          AppLanguage.english => s.english,
          AppLanguage.vietnamese => s.vietnamese,
        },
      );
    },
  );
}

Future<int?> showResultsPerPageSheet(BuildContext context, int current) {
  const options = [10, 20, 50];
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return _PreferenceSheet<int>(
        title: s.defaultResultsPerPage,
        options: options,
        current: current,
        labelBuilder: (value) => '$value',
      );
    },
  );
}

Future<AppTrendRange?> showTrendRangeSheet(
  BuildContext context,
  AppTrendRange current,
) {
  return showModalBottomSheet<AppTrendRange>(
    context: context,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final s = ctx.strings;
      return _PreferenceSheet<AppTrendRange>(
        title: s.defaultTrendRange,
        options: AppTrendRange.values,
        current: current,
        labelBuilder: (value) => switch (value) {
          AppTrendRange.fiveYears => s.fiveYears,
          AppTrendRange.sevenYears => s.sevenYears,
          AppTrendRange.allTime => s.allTime,
        },
      );
    },
  );
}

class _PreferenceSheet<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T current;
  final String Function(T value) labelBuilder;

  const _PreferenceSheet({
    required this.title,
    required this.options,
    required this.current,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ...options.map(
            (option) => RadioListTile<T>(
              title: Text(labelBuilder(option)),
              value: option,
              groupValue: current,
              activeColor: AppColors.secondary,
              onChanged: (v) => Navigator.pop(context, v),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/l10n_models.dart';
import '../l10n/strings_extension.dart';
import '../models/analytics_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'advanced_analytics_screen.dart';

/// Spec reference — 30 BI visualizations (Fact × Dimension × Chart type).
class AnalyticsCatalogScreen extends StatelessWidget {
  const AnalyticsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    final implemented = analyticsCatalog.length;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(s.biAnalyticsCatalog),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdvancedAnalyticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: Text(s.viewCharts),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.thirtyResearchVisualizations,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.catalogHeroSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SummaryChip(s.catalogComplete(implemented), palette.accent),
                    const SizedBox(width: 8),
                    _SummaryChip(s.openAlexLive, palette.primary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...analyticsCatalog.map(
            (item) => _CatalogRowCard(
              item: item,
              onOpenCharts: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdvancedAnalyticsScreen(
                      scrollToItemNo: item.no,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CatalogRowCard extends StatelessWidget {
  final AnalyticsCatalogItem item;
  final VoidCallback onOpenCharts;

  const _CatalogRowCard({
    required this.item,
    required this.onOpenCharts,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;
    final statusColor = switch (item.status) {
      AnalyticsStatus.implemented => palette.accent,
      AnalyticsStatus.partial => palette.citation,
      AnalyticsStatus.planned => palette.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        onTap: onOpenCharts,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.no}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: palette.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.localizedName(s),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.localizedDescription(s),
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MetaChip(
                  icon: Icons.table_rows_rounded,
                  label: item.localizedFactTable(s),
                  color: palette.primary,
                ),
                _MetaChip(
                  icon: Icons.category_outlined,
                  label: item.localizedDimensionTable(s),
                  color: palette.accent,
                ),
                _MetaChip(
                  icon: item.displayType.icon,
                  label: item.displayType.labelFor(s),
                  color: palette.secondary,
                ),
                _MetaChip(
                  icon: Icons.flag_outlined,
                  label: item.status.labelFor(s),
                  color: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceMuted.withValues(alpha: palette.isDark ? 0.5 : 1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';

/// Brand assets.
class BrandAssets {
  static const logo = 'assets/images/app_logo.png';
  static const loading = 'assets/images/loading.png';
}

enum JournalTrendLogoStyle {
  /// Icon mark only — for app bars and compact UI.
  icon,

  /// Full brand lockup — icon + title + tagline from asset.
  full,
}

/// Brand logo from `assets/images/app_logo.png`.
class JournalTrendLogo extends StatelessWidget {
  static const assetPath = BrandAssets.logo;

  final double size;
  final JournalTrendLogoStyle style;

  const JournalTrendLogo({
    super.key,
    this.size = 36,
    this.style = JournalTrendLogoStyle.icon,
  });

  const JournalTrendLogo.full({
    super.key,
    this.size = 200,
  }) : style = JournalTrendLogoStyle.full;

  @override
  Widget build(BuildContext context) {
    if (style == JournalTrendLogoStyle.full) {
      return Image.asset(
        assetPath,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => _LogoFallback(size: size, iconOnly: false),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(size * 0.22),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: AppDimens.cardShadow,
          ),
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.46,
              child: Image.asset(
                assetPath,
                width: size * 1.35,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) =>
                    _LogoFallback(size: size, iconOnly: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact icon mark for app bars — graphic only, no duplicate title text.
class JournalTrendIconMark extends StatelessWidget {
  final double size;

  const JournalTrendIconMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: palette.border.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        JournalTrendLogo.assetPath,
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.78),
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => Icon(
          Icons.menu_book_rounded,
          size: size * 0.5,
          color: palette.primary,
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final double size;
  final bool iconOnly;

  const _LogoFallback({required this.size, required this.iconOnly});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: iconOnly ? size : null,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: iconOnly ? size * 0.5 : size * 0.25,
        color: AppColors.primary,
      ),
    );
  }
}

@Deprecated('Use JournalTrendLogo')
typedef AppLogo = JournalTrendLogo;

class PremiumAppBar extends StatelessWidget {
  final bool showRefresh;
  final bool showBell;
  final String? title;
  final String? subtitle;

  const PremiumAppBar({
    super.key,
    this.showRefresh = false,
    this.showBell = false,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = showRefresh ? context.watch<PublicationProvider>() : null;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 14, 12, 8),
      child: Row(
        children: [
          const JournalTrendIconMark(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Journal Trend Analyzer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle ?? 'Explore • Analyze • Discover',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (showRefresh && provider != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              color: AppColors.primary,
              onPressed: provider.isLoading
                  ? null
                  : () => provider.refreshCurrentAnalysis(),
            )
          else if (showBell)
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 22),
              color: AppColors.textSecondary,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

@Deprecated('Use PremiumAppBar')
typedef JournalAiAppBar = PremiumAppBar;

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: palette.border.withValues(alpha: 0.8)),
        boxShadow: palette.cardShadow,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        child: card,
      ),
    );
  }
}

@Deprecated('Use PremiumCard')
typedef MockupCard = PremiumCard;

class GrowthBadge extends StatelessWidget {
  final double percent;

  const GrowthBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final sign = percent >= 0 ? '+' : '';
    final positive = percent >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: positive ? AppColors.analyticsTeal : AppColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$sign${percent.toStringAsFixed(1)}% YoY',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class LandscapeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const LandscapeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.navInactive,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final Color? valueColor;

  const StatColumn({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  color: valueColor,
                ),
          ),
          if (hint != null && hint!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: AppColors.navInactive,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

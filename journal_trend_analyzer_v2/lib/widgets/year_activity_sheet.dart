import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../models/year_activity_snapshot.dart';
import '../providers/publication_provider.dart';
import '../screens/detail_screen.dart';
import '../screens/year_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';

Future<void> showYearActivitySheet(
  BuildContext context,
  int year, {
  int? publicationCountHint,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _YearActivitySheet(
      year: year,
      publicationCountHint: publicationCountHint,
    ),
  );
}

class _YearActivitySheet extends StatefulWidget {
  final int year;
  final int? publicationCountHint;

  const _YearActivitySheet({
    required this.year,
    this.publicationCountHint,
  });

  @override
  State<_YearActivitySheet> createState() => _YearActivitySheetState();
}

class _YearActivitySheetState extends State<_YearActivitySheet> {
  YearActivitySnapshot? _snapshot;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final snapshot = await context
          .read<PublicationProvider>()
          .loadYearActivitySnapshot(widget.year);
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final countHint = widget.publicationCountHint;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                s.researchActivityYear(widget.year),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: AppLoadingView(
                    fillScreen: false,
                    size: 100,
                    message: s.loadingYearInsights,
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _load, child: Text(s.retry)),
                    ],
                  ),
                )
              else if (_snapshot != null)
                ..._buildContent(context, _snapshot!, countHint, s),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    YearActivitySnapshot snapshot,
    int? countHint,
    AppStrings s,
  ) {
    final count = snapshot.publicationCount > 0
        ? snapshot.publicationCount
        : (countHint ?? 0);
    final topPaper = snapshot.topPublication;

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatOpenAlexCount(count),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.analyticsTeal,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              s.publicationsLabel,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _StatRow(
        icon: Icons.format_quote_rounded,
        iconColor: AppColors.citationAmber,
        label: s.averageCitations,
        value: snapshot.averageCitations.toStringAsFixed(1),
      ),
      const SizedBox(height: 12),
      _StatRow(
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.primary,
        label: s.topJournal,
        value: snapshot.topJournal,
      ),
      const SizedBox(height: 12),
      _StatRow(
        icon: Icons.hub_rounded,
        iconColor: AppColors.analyticsTeal,
        label: s.topResearchArea,
        value: snapshot.topResearchArea,
      ),
      const SizedBox(height: 22),
      Text(
        s.topPublicationInYear(widget.year),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 10),
      if (topPaper != null)
        PremiumCard(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(publication: topPaper),
              ),
            );
          },
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topPaper.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                topPaper.journal,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.citationAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      size: 13,
                      color: AppColors.citationAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.citationCountLabel(formatOpenAlexCount(topPaper.citations)),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.citationAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      else
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            s.noPublicationDataYear,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      const SizedBox(height: 22),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            final provider = context.read<PublicationProvider>();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => YearDetailScreen(
                  year: widget.year,
                  provider: provider,
                ),
              ),
            );
          },
          child: Text(
            s.viewAllPublicationsFromYear(widget.year),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ];
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

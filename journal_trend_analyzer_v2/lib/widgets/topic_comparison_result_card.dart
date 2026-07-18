import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../models/search_filters.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';

/// Side-by-side metrics for two research topics.
class TopicComparisonResultCard extends StatelessWidget {
  final TopicComparisonResult result;

  const TopicComparisonResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${result.topicA} vs ${result.topicB}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _CompareHeader(topicA: result.topicA, topicB: result.topicB),
        const SizedBox(height: 8),
        _CompareRow(
          label: s.publicationsLabel,
          a: formatOpenAlexCount(result.publicationsA),
          b: formatOpenAlexCount(result.publicationsB),
          aWins: result.publicationsA >= result.publicationsB,
          bWins: result.publicationsB > result.publicationsA,
        ),
        _CompareRow(
          label: s.avgCitationsLabel,
          a: result.avgCitationsA.toStringAsFixed(1),
          b: result.avgCitationsB.toStringAsFixed(1),
          aWins: result.avgCitationsA >= result.avgCitationsB,
          bWins: result.avgCitationsB > result.avgCitationsA,
        ),
        _CompareRow(
          label: s.topAuthors,
          a: '${result.authorsA}',
          b: '${result.authorsB}',
          aWins: result.authorsA >= result.authorsB,
          bWins: result.authorsB > result.authorsA,
        ),
        _CompareRow(
          label: s.topJournals,
          a: '${result.journalsA}',
          b: '${result.journalsB}',
          aWins: result.journalsA >= result.journalsB,
          bWins: result.journalsB > result.journalsA,
        ),
        if (result.peakYearA > 0 || result.peakYearB > 0) ...[
          const SizedBox(height: 4),
          _CompareRow(
            label: s.peakPublicationYear,
            a: result.peakYearA > 0 ? '${result.peakYearA}' : s.na,
            b: result.peakYearB > 0 ? '${result.peakYearB}' : s.na,
          ),
        ],
        if (result.topJournalNameA.isNotEmpty &&
            result.topJournalNameB.isEmpty &&
            result.topCountryA.isEmpty &&
            result.topCountryB.isEmpty)
          const SizedBox.shrink()
        else ...[
          const SizedBox(height: 4),
          if (result.topCountryA.isNotEmpty || result.topCountryB.isNotEmpty)
            _CompareRow(
              label: s.topCountry,
              a: result.topCountryA.isEmpty ? s.na : result.topCountryA,
              b: result.topCountryB.isEmpty ? s.na : result.topCountryB,
            ),
          if (result.topJournalNameA.isNotEmpty ||
              result.topJournalNameB.isNotEmpty)
            _CompareRow(
              label: s.leadingJournal,
              a: result.topJournalNameA.isEmpty ? s.na : result.topJournalNameA,
              b: result.topJournalNameB.isEmpty ? s.na : result.topJournalNameB,
              multiline: true,
            ),
        ],
      ],
    );
  }
}

class _CompareHeader extends StatelessWidget {
  final String topicA;
  final String topicB;

  const _CompareHeader({required this.topicA, required this.topicB});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 2, child: SizedBox.shrink()),
        Expanded(
          child: Text(
            topicA.split(' ').first,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            topicB.split(' ').first,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String a;
  final String b;
  final bool aWins;
  final bool bWins;
  final bool multiline;

  const _CompareRow({
    required this.label,
    required this.a,
    required this.b,
    this.aWins = false,
    this.bWins = false,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyleA = TextStyle(
      fontWeight: aWins ? FontWeight.w700 : FontWeight.w600,
      fontSize: multiline ? 11 : 13,
      color: AppColors.primary,
    );
    final textStyleB = TextStyle(
      fontWeight: bWins ? FontWeight.w700 : FontWeight.w600,
      fontSize: multiline ? 11 : 13,
      color: AppColors.secondary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(a, textAlign: TextAlign.center, style: textStyleA),
          ),
          Expanded(
            child: Text(b, textAlign: TextAlign.center, style: textStyleB),
          ),
        ],
      ),
    );
  }
}

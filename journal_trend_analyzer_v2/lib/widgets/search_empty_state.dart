import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Magnifying glass over an empty academic document — navy & teal.
class EmptySearchIllustration extends StatelessWidget {
  final double size;

  const EmptySearchIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: size,
      height: size * 0.78,
      child: CustomPaint(
        painter: _EmptySearchIllustrationPainter(palette),
      ),
    );
  }
}

class _EmptySearchIllustrationPainter extends CustomPainter {
  final AppPalette palette;

  _EmptySearchIllustrationPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final docRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.08,
        size.width * 0.52,
        size.height * 0.72,
      ),
      const Radius.circular(12),
    );

    final docShadow = Paint()
      ..color = palette.primary.withValues(alpha: palette.isDark ? 0.2 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(docRect.shift(const Offset(0, 4)), docShadow);

    final docFill = Paint()..color = palette.surface;
    final docBorder = Paint()
      ..color = palette.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(docRect, docFill);
    canvas.drawRRect(docRect, docBorder);

    final fold = Path()
      ..moveTo(docRect.right - 22, docRect.top)
      ..lineTo(docRect.right - 22, docRect.top + 22)
      ..lineTo(docRect.right, docRect.top + 22);
    canvas.drawPath(
      fold,
      Paint()
        ..color = palette.surfaceMuted
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      fold,
      Paint()
        ..color = palette.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final linePaint = Paint()
      ..color = palette.border
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final lineLeft = docRect.left + 16;
    final lineRight = docRect.right - 28;
    for (var i = 0; i < 4; i++) {
      final y = docRect.top + 36 + i * 18;
      final widthFactor = i == 0 ? 0.72 : (i == 3 ? 0.45 : 0.9);
      canvas.drawLine(
        Offset(lineLeft, y),
        Offset(lineLeft + (lineRight - lineLeft) * widthFactor, y),
        linePaint..color = palette.border.withValues(alpha: i == 3 ? 0.45 : 0.75),
      );
    }

    final lensCenter = Offset(size.width * 0.62, size.height * 0.52);
    const lensRadius = 34.0;

    final lensGlow = Paint()
      ..color = palette.accent.withValues(alpha: palette.isDark ? 0.22 : 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(lensCenter, lensRadius + 6, lensGlow);

    final lensFill = Paint()
      ..color = palette.surface.withValues(alpha: palette.isDark ? 0.85 : 0.92);
    final lensStroke = Paint()
      ..color = palette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;
    canvas.drawCircle(lensCenter, lensRadius, lensFill);
    canvas.drawCircle(lensCenter, lensRadius, lensStroke);

    final handleAngle = math.pi * 0.28;
    final handleStart = Offset(
      lensCenter.dx + math.cos(handleAngle) * (lensRadius - 2),
      lensCenter.dy + math.sin(handleAngle) * (lensRadius - 2),
    );
    final handleEnd = Offset(
      lensCenter.dx + math.cos(handleAngle) * (lensRadius + 26),
      lensCenter.dy + math.sin(handleAngle) * (lensRadius + 26),
    );
    canvas.drawLine(
      handleStart,
      handleEnd,
      Paint()
        ..color = palette.accent
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      lensCenter,
      4,
      Paint()..color = palette.accent.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _EmptySearchIllustrationPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

/// Empty publication search results — calm academic mobile UI.
class SearchResultsEmptyView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClearFilters;
  final VoidCallback onBackToSearch;
  final ValueChanged<String> onTopicSelected;

  static const suggestedTopics = [
    'Artificial Intelligence',
    'Data Science',
    'Cybersecurity',
    'Blockchain',
  ];

  const SearchResultsEmptyView({
    super.key,
    required this.onBack,
    required this.onClearFilters,
    required this.onBackToSearch,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return ColoredBox(
      color: palette.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: palette.textPrimary,
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    s.searchResults,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  PremiumCard(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    child: Column(
                      children: [
                        const EmptySearchIllustration(),
                        const SizedBox(height: 24),
                        Text(
                          s.noPublicationsFound,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.emptySearchHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      s.suggestedTopics,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestedTopics.map((topic) {
                      return _SuggestionChip(
                        label: topic,
                        onTap: () => onTopicSelected(topic),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: onClearFilters,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.secondary,
                        foregroundColor: onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.clearFilters,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onBackToSearch,
                    child: Text(
                      s.backToSearch,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: palette.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.border),
            boxShadow: palette.cardShadow,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.primary,
            ),
          ),
        ),
      ),
    );
  }
}

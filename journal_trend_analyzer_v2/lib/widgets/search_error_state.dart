import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Disconnected cloud, research document, and subtle warning accent.
class OpenAlexErrorIllustration extends StatelessWidget {
  final double size;

  const OpenAlexErrorIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: size,
      height: size * 0.72,
      child: CustomPaint(
        painter: _OpenAlexErrorIllustrationPainter(palette),
      ),
    );
  }
}

class _OpenAlexErrorIllustrationPainter extends CustomPainter {
  final AppPalette palette;

  _OpenAlexErrorIllustrationPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final cloudLeft = Offset(size.width * 0.18, size.height * 0.18);
    final cloudRight = Offset(size.width * 0.72, size.height * 0.12);

    _drawCloud(
      canvas,
      cloudLeft,
      42,
      palette.primary.withValues(alpha: palette.isDark ? 0.28 : 0.18),
    );
    _drawCloud(
      canvas,
      cloudRight,
      36,
      palette.accent.withValues(alpha: palette.isDark ? 0.24 : 0.16),
    );

    final linePaint = Paint()
      ..color = palette.error.withValues(alpha: 0.55)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cloudLeft.dx + 34, cloudLeft.dy + 8),
      Offset(cloudRight.dx - 28, cloudRight.dy + 10),
      linePaint,
    );

    final breakCenter = Offset(size.width * 0.5, size.height * 0.2);
    canvas.drawLine(
      Offset(breakCenter.dx - 8, breakCenter.dy - 8),
      Offset(breakCenter.dx + 8, breakCenter.dy + 8),
      linePaint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(breakCenter.dx + 8, breakCenter.dy - 8),
      Offset(breakCenter.dx - 8, breakCenter.dy + 8),
      linePaint,
    );

    final docRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: 54,
        height: 68,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      docRect,
      Paint()..color = palette.surface,
    );
    canvas.drawRRect(
      docRect,
      Paint()
        ..color = palette.primary.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final docLine = Paint()
      ..color = palette.border
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = docRect.top + 18 + i * 12;
      canvas.drawLine(
        Offset(docRect.left + 10, y),
        Offset(docRect.right - 10 - (i == 2 ? 10 : 0), y),
        docLine,
      );
    }

    final warnCenter = Offset(size.width * 0.68, size.height * 0.48);
    final warnPath = Path()
      ..moveTo(warnCenter.dx, warnCenter.dy - 14)
      ..lineTo(warnCenter.dx + 14, warnCenter.dy + 10)
      ..lineTo(warnCenter.dx - 14, warnCenter.dy + 10)
      ..close();
    canvas.drawPath(
      warnPath,
      Paint()..color = palette.error.withValues(alpha: 0.16),
    );
    canvas.drawPath(
      warnPath,
      Paint()
        ..color = palette.error.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      Offset(warnCenter.dx, warnCenter.dy + 1),
      1.6,
      Paint()..color = palette.error,
    );
    canvas.drawLine(
      Offset(warnCenter.dx, warnCenter.dy - 6),
      Offset(warnCenter.dx, warnCenter.dy - 2),
      Paint()
        ..color = palette.error
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius * 0.55, paint);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.45, center.dy + 4),
      radius * 0.38,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.42, center.dy + 6),
      radius * 0.34,
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 10),
          width: radius * 1.35,
          height: radius * 0.55,
        ),
        Radius.circular(radius * 0.28),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OpenAlexErrorIllustrationPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

/// Parses HTTP status from provider state or error message text.
String? resolveOpenAlexErrorCode({
  int? statusCode,
  String? message,
}) {
  if (statusCode != null) return statusCode.toString();
  if (message == null) return null;
  final match = RegExp(r'HTTP\s*(\d{3})').firstMatch(message);
  return match?.group(1);
}

/// Full-screen error when OpenAlex publications cannot be loaded.
class SearchResultsErrorView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final VoidCallback onBackToHome;
  final int? errorStatusCode;
  final String? errorMessage;

  const SearchResultsErrorView({
    super.key,
    required this.onBack,
    required this.onRetry,
    required this.onBackToHome,
    this.errorStatusCode,
    this.errorMessage,
  });

  String _errorCodeLabel(AppStrings s) {
    final code = resolveOpenAlexErrorCode(
      statusCode: errorStatusCode,
      message: errorMessage,
    );
    return code ?? s.unavailable;
  }

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
                  const SizedBox(height: 8),
                  PremiumCard(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    child: Column(
                      children: [
                        const OpenAlexErrorIllustration(),
                        const SizedBox(height: 24),
                        Text(
                          s.unableToLoadPublications,
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
                          s.checkConnectionHint,
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
                  const SizedBox(height: 20),
                  _OpenAlexErrorDetailCard(
                    errorCode: _errorCodeLabel(s),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.secondary,
                        foregroundColor: onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.retry,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onBackToHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.textPrimary,
                        side: BorderSide(color: palette.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.backToHome,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

class _OpenAlexErrorDetailCard extends StatelessWidget {
  final String errorCode;

  const _OpenAlexErrorDetailCard({required this.errorCode});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.error.withValues(alpha: 0.32),
        ),
        boxShadow: palette.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: palette.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 18,
              color: palette.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.openAlexRequestFailed,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  () {
                    final parsed = int.tryParse(errorCode);
                    if (parsed != null) return s.errorCode(parsed);
                    return errorCode;
                  }(),
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.error.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
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

import 'package:flutter/material.dart';

import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Animated shimmer wrapper for skeleton placeholders.
class SkeletonShimmer extends StatefulWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 + slide, 0),
              end: Alignment(1 + slide, 0),
              colors: [
                palette.skeletonBase,
                palette.skeletonHighlight,
                palette.skeletonBase,
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonBox.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.palette.skeletonBase,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: shape,
      ),
    );
  }
}

class IndigoLoadingDots extends StatelessWidget {
  const IndigoLoadingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoadingDots();
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.palette.secondary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value + index * 0.2) % 1.0;
            final scale = 0.65 + (phase < 0.5 ? phase : 1 - phase) * 0.7;
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.45 + scale * 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class SkeletonAppBar extends StatelessWidget {
  const SkeletonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: const [
          SkeletonBox.circle(size: 36),
          SizedBox(width: 12),
          Expanded(
            child: SkeletonBox(height: 16, borderRadius: 8),
          ),
          SizedBox(width: 12),
          SkeletonBox.circle(size: 36),
          SizedBox(width: 4),
          SkeletonBox.circle(size: 36),
        ],
      ),
    );
  }
}

class SkeletonTopicHeader extends StatelessWidget {
  const SkeletonTopicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 180, height: 22, borderRadius: 10),
          SizedBox(height: 10),
          SkeletonBox(width: 140, height: 12, borderRadius: 6),
          SizedBox(height: 14),
          SkeletonBox(height: 38, borderRadius: 12),
        ],
      ),
    );
  }
}

class PublicationCardSkeleton extends StatelessWidget {
  const PublicationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox.circle(size: 44),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, borderRadius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 14, borderRadius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 200, height: 12, borderRadius: 6),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBox(width: 72, height: 22, borderRadius: 11),
                      SizedBox(width: 8),
                      SkeletonBox(width: 88, height: 22, borderRadius: 11),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading state for publication list searches.
class PublicationListLoadingView extends StatelessWidget {
  final String? message;
  final int cardCount;

  const PublicationListLoadingView({
    super.key,
    this.message,
    this.cardCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final displayMessage = message ?? context.strings.analyzingPublications;
    return ColoredBox(
      color: palette.background,
      child: Stack(
        children: [
          SkeletonShimmer(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const SkeletonAppBar(),
                const SkeletonTopicHeader(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(
                      cardCount,
                      (_) => const PublicationCardSkeleton(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.background.withValues(alpha: 0.05),
                      palette.background.withValues(alpha: 0.55),
                      palette.background.withValues(alpha: 0.88),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IndigoLoadingDots(),
                      const SizedBox(height: 14),
                      Text(
                        displayMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.primary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

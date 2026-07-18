import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Loading UI — animated `assets/images/loading.png`.
class AppLoadingView extends StatelessWidget {
  static const loadingAssetPath = BrandAssets.loading;

  final String? message;
  final bool fillScreen;
  final bool expand;
  final double size;
  final Color? backgroundColor;

  const AppLoadingView({
    super.key,
    this.message,
    this.fillScreen = true,
    this.expand = false,
    this.size = 240,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          loadingAssetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _LoadingFallback(size: size),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );

    if (fillScreen) {
      return ColoredBox(
        color: backgroundColor ?? AppColors.background,
        child: Center(child: content),
      );
    }

    if (expand) {
      return SizedBox.expand(
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

class AppLoadingIndicator extends StatelessWidget {
  final double size;

  const AppLoadingIndicator({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppLoadingView.loadingAssetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => SizedBox(
        width: size,
        height: size,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _LoadingFallback extends StatelessWidget {
  final double size;

  const _LoadingFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const JournalTrendLogo(size: 72),
        const SizedBox(height: 16),
        SizedBox(
          width: size * 0.15,
          height: size * 0.15,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

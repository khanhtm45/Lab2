import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Loading UI dùng `assets/images/loading.png`
class AppLoadingView extends StatelessWidget {
  final String? message;
  final bool fillScreen;
  /// Căn giữa trong vùng cha (Scaffold body, Expanded, v.v.)
  final bool expand;
  final double size;
  final Color? backgroundColor;

  const AppLoadingView({
    super.key,
    this.message,
    this.fillScreen = true,
    this.expand = false,
    this.size = 220,
    this.backgroundColor,
  });

  static const _assetPath = 'assets/images/loading.png';

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => SizedBox(
            width: size * 0.4,
            height: size * 0.4,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
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

/// Spinner nhỏ cho suffix button / load-more (dùng logo loading thu nhỏ).
class AppLoadingIndicator extends StatelessWidget {
  final double size;

  const AppLoadingIndicator({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppLoadingView._assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Padding(
          padding: EdgeInsets.all(size * 0.15),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

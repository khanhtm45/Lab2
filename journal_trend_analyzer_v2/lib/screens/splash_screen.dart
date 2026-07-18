import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings_extension.dart';
import '../providers/publication_provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_logo.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      // Initialize app data
      final provider = context.read<PublicationProvider>();
      await provider.loadDefaultDashboard();
      
      // Wait for a minimum splash duration
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      
      if (!mounted) return;

      // Check authentication status
      final authViewModel = context.read<AuthViewModel>();
      
      // Navigate based on authentication status
      if (authViewModel.isSignedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        // User can choose to sign in or continue as guest
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Handle initialization errors gracefully
      print('Splash initialization error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.65,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.14),
                    AppColors.primary.withValues(alpha: 0.07),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const JournalTrendLogo.full(size: 168),
                  const SizedBox(height: 28),
                  Text(
                    s.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.splashTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 52,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoadingIndicator(size: 28),
                const SizedBox(height: 14),
                Text(
                  s.poweredByOpenAlex,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        letterSpacing: 0.3,
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

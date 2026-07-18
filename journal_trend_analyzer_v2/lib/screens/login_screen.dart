import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings_extension.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../firebase/crashlytics_service.dart';
import 'main_shell.dart';

/// Login screen for Google Sign-In authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    CrashlyticsService.recordScreenView('LoginScreen');

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithGoogle();

    if (success && mounted) {
      // Navigate to main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = context.strings;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        palette.primary.withValues(alpha: 0.1),
                        palette.background,
                        palette.secondary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo and title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // App logo
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    palette.primary,
                                    palette.secondary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.primary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // App title
                            Text(
                              s.appTitle,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: palette.textPrimary,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              'Analyze research trends with OpenAlex API',
                              style: TextStyle(
                                fontSize: 16,
                                color: palette.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Sign-in content
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Welcome message
                              Text(
                                'Welcome to Academic Research',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: palette.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              Text(
                                'Sign in with Google to access personalized research insights and analytics',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: palette.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // Google Sign-In button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: authViewModel.isLoading ? null : _handleGoogleSignIn,
                                  icon: authViewModel.isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              palette.surface,
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/google_logo.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.login_rounded,
                                              color: palette.surface,
                                              size: 24,
                                            );
                                          },
                                        ),
                                  label: Text(
                                    authViewModel.isLoading
                                        ? 'Signing in...'
                                        : 'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: palette.surface,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: palette.primary,
                                    foregroundColor: palette.surface,
                                    elevation: 2,
                                    shadowColor: palette.primary.withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),

                              // Error message
                              if (authViewModel.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: palette.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: palette.error.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: palette.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authViewModel.error!,
                                          style: TextStyle(
                                            color: palette.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Continue as guest button (optional)
                              TextButton(
                                onPressed: () {
                                  // Navigate to app without authentication
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MainShell()),
                                  );
                                },
                                child: Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Footer
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Powered by OpenAlex API & Firebase',
                              style: TextStyle(
                                color: palette.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PRM393 - Lab 03',
                              style: TextStyle(
                                color: palette.textTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
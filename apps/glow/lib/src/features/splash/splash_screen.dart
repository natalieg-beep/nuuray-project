import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/constants/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import '../profile/providers/user_profile_provider.dart';

/// Splash-Screen: Prüft Auth-Status und leitet weiter
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Kurz warten für visuellen Effekt
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    final authService = ref.read(authServiceProvider);
    final isAuthenticated = authService.isAuthenticated;

    if (!isAuthenticated) {
      // Nicht eingeloggt → Login
      context.go('/login');
      return;
    }

    // Eingeloggt → Prüfe ob Profil vorhanden
    final profileService = ref.read(userProfileServiceProvider);
    final hasCompleted = await profileService.hasCompletedOnboarding();

    if (!mounted) return;

    if (hasCompleted) {
      // Profil vorhanden → Home
      context.go('/home');
    } else {
      // Kein Profil → Onboarding
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Icon(
              Icons.nightlight_round,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Nuuray Glow',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),

            // Loading Indicator
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

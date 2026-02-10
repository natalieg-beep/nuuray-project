import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/onboarding/screens/onboarding_flow_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/signature/screens/signature_screen.dart';
import '../../features/moon/screens/moon_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/edit_profile_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

/// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  // Auth State beobachten
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Auth & Onboarding Routes (ohne Bottom Nav)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // Settings & Profile Routes (ohne Bottom Nav, aber mit Back Button)
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Main App Routes (mit Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/signature',
            name: 'signature',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const SignatureScreen(),
            ),
          ),
          GoRoute(
            path: '/moon',
            name: 'moon',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const MoonScreen(),
            ),
          ),
          GoRoute(
            path: '/insights',
            name: 'insights',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const InsightsScreen(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';

      // Wenn nicht eingeloggt und versucht auf geschützte Route zuzugreifen
      if (!isAuthenticated && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }

      // Wenn eingeloggt und versucht auf Login/Signup zuzugreifen
      if (isAuthenticated && (isGoingToLogin || isGoingToSignup)) {
        return '/home';
      }

      // Onboarding-Redirect erfolgt im SignupScreen direkt
      // (nach erfolgreicher Registrierung → /onboarding)

      // Keine Weiterleitung nötig
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
  );
});

/// Helper-Klasse um Stream in Listenable zu konvertieren
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

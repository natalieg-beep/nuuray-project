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

/// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  // Auth State beobachten
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
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
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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

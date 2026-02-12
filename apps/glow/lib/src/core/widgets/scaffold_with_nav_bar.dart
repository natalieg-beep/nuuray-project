import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold mit Bottom Navigation Bar für die Haupt-Tabs
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    // Index basierend auf aktuellem Tab bestimmen
    int selectedIndex = 0;
    if (currentLocation.startsWith('/home')) {
      selectedIndex = 0;
    } else if (currentLocation.startsWith('/signature')) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith('/insights')) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith('/moon')) {
      selectedIndex = 3;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onTabTapped(context, index),
      backgroundColor: const Color(0xFFFFFBF5), // AppColors.background
      indicatorColor: const Color(0xFFD4AF37).withValues(alpha: 0.2), // AppColors.gold
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: 'Signatur',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: 'Insights',
        ),
        NavigationDestination(
          icon: Icon(Icons.nightlight_outlined),
          selectedIcon: Icon(Icons.nightlight),
          label: 'Mond',
        ),
      ],
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/signature');
        break;
      case 2:
        context.go('/insights');
        break;
      case 3:
        context.go('/moon');
        break;
    }
  }
}

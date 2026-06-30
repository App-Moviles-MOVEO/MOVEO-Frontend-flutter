import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';

/// Shell principal con la bottom navigation bar de 4 tabs.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Semantics(
        container: true,
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car_outlined),
              activeIcon: const Icon(Icons.directions_car),
              label: l10n.navFleet,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.route_outlined),
              activeIcon: const Icon(Icons.route),
              label: l10n.navRoutes,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

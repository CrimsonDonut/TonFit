import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';

/// The frame around the two main tabs: a top bar with the app name on the left
/// and Settings on the right, and a bottom bar to switch between Home and
/// History. Full-screen flows (choose program, add exercise, settings) are
/// pushed above this and cover it.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final index = navigationShell.currentIndex;

    return PopScope(
      // Back from History goes Home first; back from Home leaves the app.
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 26,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 10),
              Text(
                'TonFit',
                style: text.headlineLarge?.copyWith(fontSize: 22),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(),
          ),
        ),
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: NavigationBar(
            selectedIndex: index,
            // Tapping the tab you are already on returns to its first screen.
            onDestinationSelected: (i) =>
                navigationShell.goBranch(i, initialLocation: i == index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(location),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/agent');
              break;
            case 1:
              context.go('/episodes');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'SepsiScan',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Episódios',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/agent')) {
      return 0;
    }
    if (location.startsWith('/episodes')) {
      return 1;
    }
    if (location.startsWith('/settings')) {
      return 2;
    }
    return 0;
  }
}

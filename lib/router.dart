import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sepsis_agent_app/features/settings/settings_screen.dart';

import 'features/agent/agent_screen.dart';
import 'features/episodes/episodes_list_screen.dart';

final router = GoRouter(
  initialLocation: '/agent',
  routes: [
    GoRoute(
      path: '/agent',
      builder: (context, state) => const AgentScreen(),
    ),
    GoRoute(
      path: '/episodes',
      builder: (context, state) => const EpisodesListScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ConfigScreen(),
    ),
  ],
);

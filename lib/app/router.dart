import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/ahead/ahead_screen.dart';
import '../features/people/people_screen.dart';
import '../features/sees/sees_screen.dart';
import '../features/threads/threads_screen.dart';
import '../features/today/today_screen.dart';
import 'shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildMemoryRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MemoryShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/threads',
                builder: (context, state) => const ThreadsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/people',
                builder: (context, state) => const PeopleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ahead',
                builder: (context, state) => const AheadScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/sees',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SeesScreen(),
      ),
    ],
  );
}

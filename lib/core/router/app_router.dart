import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/emotion/presentation/home_page.dart';
import '../../features/recommend/presentation/recommend_page.dart';
import '../../features/record/presentation/record_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(
              navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'recommend',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const RecommendPage(),
                  ),
                  GoRoute(
                    path: 'record',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const RecordPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) =>
                    const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) =>
                    const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar(
      {super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation:
              index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              label: '今天'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: '日历'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: '历史'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '我的'),
        ],
      ),
    );
  }
}

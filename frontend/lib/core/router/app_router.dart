import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/settings_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: MainRoute.page,
      children: [
        AutoRoute(
          path: 'home',
          page: HomeRoute.page,
          initial: true,
        ),
        AutoRoute(
          path: 'search',
          page: SearchRoute.page,
        ),
        AutoRoute(
          path: 'history',
          page: HistoryRoute.page,
        ),
        AutoRoute(
          path: 'settings',
          page: SettingsRoute.page,
        ),
      ],
    ),
  ];
}

// Main shell route for bottom navigation
@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        SearchRoute(),
        HistoryRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        
        return Scaffold(
          body: child,
          bottomNavigationBar: _buildBottomNav(context, tabsRouter),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, TabsRouter tabsRouter) {
    // Import theme helpers
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final primaryColor = isDark ? const Color(0xFFFF8FA3) : const Color(0xFFFFB7C5);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFFB2BEC3);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, '홈', 0, tabsRouter, primaryColor, textMuted),
          _buildNavItem(Icons.search_rounded, '탐색', 1, tabsRouter, primaryColor, textMuted),
          _buildNavItem(Icons.history_rounded, '기록', 2, tabsRouter, primaryColor, textMuted),
          _buildNavItem(Icons.person_rounded, '내정보', 3, tabsRouter, primaryColor, textMuted),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    TabsRouter tabsRouter,
    Color primaryColor,
    Color textMuted,
  ) {
    final isActive = tabsRouter.activeIndex == index;

    return GestureDetector(
      onTap: () => tabsRouter.setActiveIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : textMuted,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for search route
@RoutePage()
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('검색 화면'),
      ),
    );
  }
}

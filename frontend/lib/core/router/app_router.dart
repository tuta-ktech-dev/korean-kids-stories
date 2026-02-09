import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation/components/navigation/app_bottom_nav.dart';
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
        AutoRoute(path: '', page: HomeRoute.page),
        AutoRoute(path: 'search', page: SearchRoute.page),
        AutoRoute(path: 'history', page: HistoryRoute.page),
        AutoRoute(path: 'settings', page: SettingsRoute.page),
      ],
    ),
  ];
}

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
          bottomNavigationBar: AppBottomNav(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }
}

@RoutePage()
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('검색 화면')),
    );
  }
}

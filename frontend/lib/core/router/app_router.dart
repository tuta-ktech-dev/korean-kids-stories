import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/components/navigation/app_bottom_nav.dart';
import '../../presentation/screens/landing_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/library_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/otp_verification_screen.dart';
import '../../presentation/cubits/auth_cubit/auth_cubit.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Landing screen (initial - no auth required)
    AutoRoute(path: '/', page: LandingRoute.page, initial: true),
    
    // Auth routes
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/verify-otp', page: OtpVerificationRoute.page),
    
    // Search (standalone)
    AutoRoute(path: '/search', page: SearchRoute.page),
    
    // Main app - accessible to guests too
    AutoRoute(
      path: '/main',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'history', page: HistoryRoute.page),
        AutoRoute(path: 'library', page: LibraryRoute.page),
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is Authenticated;
        
        return AutoTabsRouter(
          routes: [
            const HomeRoute(),
            const SearchRoute(),
            const HistoryRoute(),
            if (isAuthenticated) const LibraryRoute(),
            if (isAuthenticated) const SettingsRoute(),
          ],
          builder: (context, child) {
            final tabsRouter = AutoTabsRouter.of(context);
            
            return Scaffold(
              body: child,
              bottomNavigationBar: AppBottomNav(
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
                isAuthenticated: isAuthenticated,
              ),
            );
          },
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

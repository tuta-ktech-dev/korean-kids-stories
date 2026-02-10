import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/components/navigation/app_bottom_nav.dart';
import '../../presentation/screens/landing/landing_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/story_detail/story_detail_screen.dart';
import '../../presentation/screens/reader/reader_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/content_page/content_page_screen.dart';
import '../../presentation/screens/library/library_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/register/register_screen.dart';
import '../../presentation/screens/otp_verification/otp_verification_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/stickers/stickers_screen.dart';
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
    AutoRoute(path: '/profile', page: ProfileRoute.page),
    AutoRoute(path: '/stickers', page: StickersRoute.page),
    AutoRoute(path: '/content/:slug', page: ContentRouteRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/verify-otp', page: OtpVerificationRoute.page),

    // Search (standalone)
    AutoRoute(path: '/search', page: SearchRoute.page),

    // Story Detail
    AutoRoute(path: '/story/:id', page: StoryDetailRoute.page),

    // Reader
    AutoRoute(path: '/reader/:storyId/:chapterId', page: ReaderRoute.page),

    // Main app - accessible to guests too
    AutoRoute(
      path: '/main',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'search', page: SearchRoute.page),
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
          key: ValueKey(isAuthenticated),
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

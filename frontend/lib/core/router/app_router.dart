import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation/components/navigation/app_bottom_nav.dart';
import '../../presentation/widgets/responsive_padding.dart';
import '../../presentation/screens/landing/landing_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/story_detail/story_detail_screen.dart';
import '../../presentation/screens/reader/reader_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/content_page/content_page_screen.dart';
import '../../presentation/screens/library/library_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/register/register_screen.dart';
import '../../presentation/screens/otp_verification/otp_verification_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/stickers/stickers_screen.dart';
import '../../presentation/screens/parent_zone/parent_zone_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Landing screen (initial - guest-only flow)
    AutoRoute(path: '/', page: LandingRoute.page, initial: true),
    AutoRoute(path: '/onboarding', page: OnboardingRoute.page),

    // Content & Search
    AutoRoute(path: '/stickers', page: StickersRoute.page),
    AutoRoute(path: '/content/:slug', page: ContentRouteRoute.page),
    AutoRoute(path: '/verify-otp', page: OtpVerificationRoute.page),
    AutoRoute(path: '/search', page: SearchRoute.page),
    AutoRoute(path: '/story/:id', page: StoryDetailRoute.page),
    AutoRoute(path: '/reader/:storyId/:chapterId', page: ReaderRoute.page),

    // Main app - Guest-only, no login
    AutoRoute(
      path: '/main',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'stickers', page: StickersRoute.page),
        AutoRoute(path: 'history', page: HistoryRoute.page),
        AutoRoute(path: 'settings', page: ParentZoneRoute.page),
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
        StickersRoute(),
        HistoryRoute(),
        ParentZoneRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: ResponsivePadding(child: child),
          bottomNavigationBar: SafeArea(
            child: ResponsivePadding(
              horizontalPadding: 16,
              child: AppBottomNav(
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
              ),
            ),
          ),
        );
      },
    );
  }
}

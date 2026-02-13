import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/components/navigation/app_bottom_nav.dart';
import '../../presentation/cubits/bookmark_cubit/bookmark_cubit.dart';
import '../../presentation/cubits/favorite_cubit/favorite_cubit.dart';
import '../../presentation/cubits/history_cubit/history_cubit.dart';
import '../../presentation/cubits/note_cubit/note_cubit.dart';
import '../../presentation/screens/landing/landing_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/story_detail/story_detail_screen.dart';
import '../../presentation/screens/reader/reader_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/content_page/content_page_screen.dart';
import '../../presentation/screens/library/library_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/stickers/stickers_screen.dart';
import '../../presentation/screens/parent_zone/parent_zone_screen.dart';
import '../../presentation/screens/quiz/quiz_screen.dart';

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
    AutoRoute(path: '/library', page: LibraryRoute.page),
    AutoRoute(path: '/search', page: SearchRoute.page),
    AutoRoute(path: '/story/:id', page: StoryDetailRoute.page),
    AutoRoute(path: '/reader/:storyId/:chapterId', page: ReaderRoute.page),
    AutoRoute(path: '/quiz', page: QuizRoute.page),

    // Main app - Kids app, no login
    AutoRoute(
      path: '/main',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'stickers', page: StickersRoute.page),
        AutoRoute(path: 'library', page: LibraryRoute.page),
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
        LibraryRoute(),
        HistoryRoute(),
        ParentZoneRoute(),
      ],
      builder: (context, child) {
        return _MainScaffold(child: child);
      },
    );
  }
}

/// Refreshes local-data cubits when user switches to Library or History tab.
class _MainScaffold extends StatefulWidget {
  const _MainScaffold({required this.child});

  final Widget child;

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _lastActiveIndex = -1;

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    return Builder(
        builder: (context) {
          final activeIndex = tabsRouter.activeIndex;
          if (activeIndex != _lastActiveIndex) {
            _lastActiveIndex = activeIndex;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              switch (activeIndex) {
                case 2: // Library
                  context.read<FavoriteCubit>().loadFavoriteStories();
                  context.read<BookmarkCubit>().loadBookmarkedStories();
                  context.read<NoteCubit>().loadNotes();
                  break;
                case 3: // History
                  context.read<HistoryCubit>().loadHistory();
                  break;
              }
            });
          }

          return Scaffold(
            body: widget.child,
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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

// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ContentPageScreen]
class ContentRouteRoute extends PageRouteInfo<ContentRouteRouteArgs> {
  ContentRouteRoute({
    Key? key,
    required String slug,
    List<PageRouteInfo>? children,
  }) : super(
         ContentRouteRoute.name,
         args: ContentRouteRouteArgs(key: key, slug: slug),
         initialChildren: children,
       );

  static const String name = 'ContentRouteRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentRouteRouteArgs>();
      return ContentPageScreen(key: args.key, slug: args.slug);
    },
  );
}

class ContentRouteRouteArgs {
  const ContentRouteRouteArgs({this.key, required this.slug});

  final Key? key;

  final String slug;

  @override
  String toString() {
    return 'ContentRouteRouteArgs{key: $key, slug: $slug}';
  }
}

/// generated route for
/// [HistoryScreen]
class HistoryRoute extends PageRouteInfo<void> {
  const HistoryRoute({List<PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HistoryScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LandingScreen]
class LandingRoute extends PageRouteInfo<void> {
  const LandingRoute({List<PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LandingScreen();
    },
  );
}

/// generated route for
/// [LibraryScreen]
class LibraryRoute extends PageRouteInfo<void> {
  const LibraryRoute({List<PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LibraryScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [ParentZoneScreen]
class ParentZoneRoute extends PageRouteInfo<void> {
  const ParentZoneRoute({List<PageRouteInfo>? children})
    : super(ParentZoneRoute.name, initialChildren: children);

  static const String name = 'ParentZoneRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ParentZoneScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [QuizScreen]
class QuizRoute extends PageRouteInfo<QuizRouteArgs> {
  QuizRoute({
    Key? key,
    String? storyId,
    String? chapterId,
    String? nextStoryId,
    String? nextChapterId,
    List<PageRouteInfo>? children,
  }) : super(
         QuizRoute.name,
         args: QuizRouteArgs(
           key: key,
           storyId: storyId,
           chapterId: chapterId,
           nextStoryId: nextStoryId,
           nextChapterId: nextChapterId,
         ),
         initialChildren: children,
       );

  static const String name = 'QuizRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuizRouteArgs>(
        orElse: () => const QuizRouteArgs(),
      );
      return QuizScreen(
        key: args.key,
        storyId: args.storyId,
        chapterId: args.chapterId,
        nextStoryId: args.nextStoryId,
        nextChapterId: args.nextChapterId,
      );
    },
  );
}

class QuizRouteArgs {
  const QuizRouteArgs({
    this.key,
    this.storyId,
    this.chapterId,
    this.nextStoryId,
    this.nextChapterId,
  });

  final Key? key;

  final String? storyId;

  final String? chapterId;

  final String? nextStoryId;

  final String? nextChapterId;

  @override
  String toString() {
    return 'QuizRouteArgs{key: $key, storyId: $storyId, chapterId: $chapterId, nextStoryId: $nextStoryId, nextChapterId: $nextChapterId}';
  }
}

/// generated route for
/// [ReaderScreen]
class ReaderRoute extends PageRouteInfo<ReaderRouteArgs> {
  ReaderRoute({
    Key? key,
    required String storyId,
    required String chapterId,
    List<PageRouteInfo>? children,
  }) : super(
         ReaderRoute.name,
         args: ReaderRouteArgs(
           key: key,
           storyId: storyId,
           chapterId: chapterId,
         ),
         rawPathParams: {'storyId': storyId, 'chapterId': chapterId},
         initialChildren: children,
       );

  static const String name = 'ReaderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReaderRouteArgs>(
        orElse: () => ReaderRouteArgs(
          storyId: pathParams.getString('storyId'),
          chapterId: pathParams.getString('chapterId'),
        ),
      );
      return ReaderScreen(
        key: args.key,
        storyId: args.storyId,
        chapterId: args.chapterId,
      );
    },
  );
}

class ReaderRouteArgs {
  const ReaderRouteArgs({
    this.key,
    required this.storyId,
    required this.chapterId,
  });

  final Key? key;

  final String storyId;

  final String chapterId;

  @override
  String toString() {
    return 'ReaderRouteArgs{key: $key, storyId: $storyId, chapterId: $chapterId}';
  }
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [StickersScreen]
class StickersRoute extends PageRouteInfo<void> {
  const StickersRoute({List<PageRouteInfo>? children})
    : super(StickersRoute.name, initialChildren: children);

  static const String name = 'StickersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StickersScreen();
    },
  );
}

/// generated route for
/// [StoryDetailScreen]
class StoryDetailRoute extends PageRouteInfo<StoryDetailRouteArgs> {
  StoryDetailRoute({
    Key? key,
    required String storyId,
    List<PageRouteInfo>? children,
  }) : super(
         StoryDetailRoute.name,
         args: StoryDetailRouteArgs(key: key, storyId: storyId),
         rawPathParams: {'id': storyId},
         initialChildren: children,
       );

  static const String name = 'StoryDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StoryDetailRouteArgs>(
        orElse: () => StoryDetailRouteArgs(storyId: pathParams.getString('id')),
      );
      return StoryDetailScreen(key: args.key, storyId: args.storyId);
    },
  );
}

class StoryDetailRouteArgs {
  const StoryDetailRouteArgs({this.key, required this.storyId});

  final Key? key;

  final String storyId;

  @override
  String toString() {
    return 'StoryDetailRouteArgs{key: $key, storyId: $storyId}';
  }
}

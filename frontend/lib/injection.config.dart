// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'data/repositories/app_config_repository.dart' as _i83;
import 'data/repositories/auth_repository.dart' as _i593;
import 'data/repositories/bookmark_repository.dart' as _i318;
import 'data/repositories/content_page_repository.dart' as _i96;
import 'data/repositories/favorite_repository.dart' as _i266;
import 'data/repositories/local_bookmark_repository.dart' as _i504;
import 'data/repositories/local_favorite_repository.dart' as _i252;
import 'data/repositories/local_note_repository.dart' as _i657;
import 'data/repositories/local_progress_repository.dart' as _i825;
import 'data/repositories/note_repository.dart' as _i627;
import 'data/repositories/progress_repository.dart' as _i369;
import 'data/repositories/reading_history_repository.dart' as _i821;
import 'data/repositories/report_repository.dart' as _i726;
import 'data/repositories/review_repository.dart' as _i1049;
import 'data/repositories/sticker_repository.dart' as _i577;
import 'data/repositories/story_repository.dart' as _i691;
import 'data/repositories/user_preferences_repository.dart' as _i195;
import 'data/repositories/user_stats_repository.dart' as _i1058;
import 'data/services/pocketbase_service.dart' as _i700;
import 'data/services/premium_service.dart' as _i526;
import 'data/services/tracking_service.dart' as _i194;
import 'injection_module.dart' as _i212;
import 'presentation/cubits/auth_cubit/auth_cubit.dart' as _i519;
import 'presentation/cubits/bookmark_cubit/bookmark_cubit.dart' as _i686;
import 'presentation/cubits/favorite_cubit/favorite_cubit.dart' as _i739;
import 'presentation/cubits/history_cubit/history_cubit.dart' as _i476;
import 'presentation/cubits/home_cubit/home_cubit.dart' as _i712;
import 'presentation/cubits/note_cubit/note_cubit.dart' as _i764;
import 'presentation/cubits/progress_cubit/progress_cubit.dart' as _i1000;
import 'presentation/cubits/reader_cubit/reader_cubit.dart' as _i433;
import 'presentation/cubits/search_cubit/search_cubit.dart' as _i349;
import 'presentation/cubits/settings_cubit/settings_cubit.dart' as _i1055;
import 'presentation/cubits/stats_cubit/stats_cubit.dart' as _i859;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectionModule = _$InjectionModule();
    gh.factory<_i825.LocalProgressRepository>(
      () => _i825.LocalProgressRepository(),
    );
    gh.lazySingleton<_i700.PocketbaseService>(
      () => injectionModule.pocketbaseService,
    );
    gh.lazySingleton<_i194.TrackingService>(
      () => injectionModule.trackingService,
    );
    gh.lazySingleton<_i1055.SettingsCubit>(() => _i1055.SettingsCubit());
    gh.lazySingleton<_i657.LocalNoteRepository>(
      () => _i657.LocalNoteRepository(),
    );
    gh.lazySingleton<_i252.LocalFavoriteRepository>(
      () => _i252.LocalFavoriteRepository(),
    );
    gh.lazySingleton<_i504.LocalBookmarkRepository>(
      () => _i504.LocalBookmarkRepository(),
    );
    gh.lazySingleton<_i739.FavoriteCubit>(
      () => _i739.FavoriteCubit(
        favoriteRepository: gh<_i266.FavoriteRepository>(),
      ),
    );
    gh.factory<_i593.AuthRepository>(
      () => _i593.AuthRepository(pbService: gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i96.ContentPageRepository>(
      () => _i96.ContentPageRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i1049.ReviewRepository>(
      () => _i1049.ReviewRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i726.ReportRepository>(
      () => _i726.ReportRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i821.ReadingHistoryRepository>(
      () => _i821.ReadingHistoryRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i577.StickerRepository>(
      () => _i577.StickerRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i691.StoryRepository>(
      () => _i691.StoryRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i195.UserPreferencesRepository>(
      () => _i195.UserPreferencesRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i83.AppConfigRepository>(
      () => _i83.AppConfigRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i526.PremiumService>(
      () => _i526.PremiumService(gh<_i700.PocketbaseService>()),
    );
    gh.lazySingleton<_i712.HomeCubit>(
      () => _i712.HomeCubit(
        storyRepository: gh<_i691.StoryRepository>(),
        progressRepository: gh<_i369.ProgressRepository>(),
      ),
    );
    gh.factory<_i266.FavoriteRepository>(
      () => _i266.FavoriteRepository(
        gh<_i252.LocalFavoriteRepository>(),
        gh<_i691.StoryRepository>(),
      ),
    );
    gh.factory<_i859.StatsCubit>(
      () => _i859.StatsCubit(
        userStatsRepo: gh<_i1058.UserStatsRepository>(),
        stickerRepo: gh<_i577.StickerRepository>(),
      ),
    );
    gh.lazySingleton<_i1000.ProgressCubit>(
      () => _i1000.ProgressCubit(
        progressRepository: gh<_i369.ProgressRepository>(),
        readingHistoryRepository: gh<_i821.ReadingHistoryRepository>(),
      ),
    );
    gh.lazySingleton<_i476.HistoryCubit>(
      () => _i476.HistoryCubit(
        progressRepository: gh<_i369.ProgressRepository>(),
        storyRepository: gh<_i691.StoryRepository>(),
      ),
    );
    gh.factory<_i627.NoteRepository>(
      () => _i627.NoteRepository(gh<_i657.LocalNoteRepository>()),
    );
    gh.lazySingleton<_i686.BookmarkCubit>(
      () => _i686.BookmarkCubit(
        bookmarkRepository: gh<_i318.BookmarkRepository>(),
      ),
    );
    gh.factory<_i369.ProgressRepository>(
      () => _i369.ProgressRepository(
        gh<_i700.PocketbaseService>(),
        gh<_i825.LocalProgressRepository>(),
      ),
    );
    gh.factory<_i433.ReaderCubit>(
      () => _i433.ReaderCubit(
        storyRepository: gh<_i691.StoryRepository>(),
        progressRepository: gh<_i369.ProgressRepository>(),
        readingHistoryRepository: gh<_i821.ReadingHistoryRepository>(),
      ),
    );
    gh.factory<_i318.BookmarkRepository>(
      () => _i318.BookmarkRepository(
        gh<_i504.LocalBookmarkRepository>(),
        gh<_i691.StoryRepository>(),
      ),
    );
    gh.lazySingleton<_i764.NoteCubit>(
      () => _i764.NoteCubit(noteRepository: gh<_i627.NoteRepository>()),
    );
    gh.lazySingleton<_i349.SearchCubit>(
      () => _i349.SearchCubit(
        storyRepository: gh<_i691.StoryRepository>(),
        pocketbaseService: gh<_i700.PocketbaseService>(),
      ),
    );
    gh.lazySingleton<_i519.AuthCubit>(
      () => _i519.AuthCubit(authRepository: gh<_i593.AuthRepository>()),
    );
    gh.factory<_i1058.UserStatsRepository>(
      () => _i1058.UserStatsRepository(
        gh<_i700.PocketbaseService>(),
        gh<_i369.ProgressRepository>(),
        gh<_i691.StoryRepository>(),
      ),
    );
    return this;
  }
}

class _$InjectionModule extends _i212.InjectionModule {}

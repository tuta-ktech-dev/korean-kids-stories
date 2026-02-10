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

import 'data/repositories/auth_repository.dart' as _i593;
import 'data/repositories/favorite_repository.dart' as _i266;
import 'data/repositories/progress_repository.dart' as _i369;
import 'data/repositories/story_repository.dart' as _i691;
import 'data/services/pocketbase_service.dart' as _i700;
import 'data/services/tracking_service.dart' as _i194;
import 'injection_module.dart' as _i212;
import 'presentation/cubits/auth_cubit/auth_cubit.dart' as _i519;
import 'presentation/cubits/favorite_cubit/favorite_cubit.dart' as _i739;
import 'presentation/cubits/history_cubit/history_cubit.dart' as _i476;
import 'presentation/cubits/home_cubit/home_cubit.dart' as _i712;
import 'presentation/cubits/progress_cubit/progress_cubit.dart' as _i1000;
import 'presentation/cubits/reader_cubit/reader_cubit.dart' as _i433;
import 'presentation/cubits/search_cubit/search_cubit.dart' as _i349;
import 'presentation/cubits/settings_cubit/settings_cubit.dart' as _i1055;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectionModule = _$InjectionModule();
    gh.lazySingleton<_i700.PocketbaseService>(
      () => injectionModule.pocketbaseService,
    );
    gh.lazySingleton<_i194.TrackingService>(
      () => injectionModule.trackingService,
    );
    gh.lazySingleton<_i1055.SettingsCubit>(() => _i1055.SettingsCubit());
    gh.factory<_i593.AuthRepository>(
      () => _i593.AuthRepository(pbService: gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i369.ProgressRepository>(
      () => _i369.ProgressRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i691.StoryRepository>(
      () => _i691.StoryRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i266.FavoriteRepository>(
      () => _i266.FavoriteRepository(gh<_i700.PocketbaseService>()),
    );
    gh.factory<_i433.ReaderCubit>(
      () => _i433.ReaderCubit(
        storyRepository: gh<_i691.StoryRepository>(),
        progressRepository: gh<_i369.ProgressRepository>(),
      ),
    );
    gh.lazySingleton<_i712.HomeCubit>(
      () => _i712.HomeCubit(storyRepository: gh<_i691.StoryRepository>()),
    );
    gh.lazySingleton<_i476.HistoryCubit>(
      () => _i476.HistoryCubit(
        progressRepository: gh<_i369.ProgressRepository>(),
        storyRepository: gh<_i691.StoryRepository>(),
      ),
    );
    gh.lazySingleton<_i739.FavoriteCubit>(
      () => _i739.FavoriteCubit(
        favoriteRepository: gh<_i266.FavoriteRepository>(),
        pocketbaseService: gh<_i700.PocketbaseService>(),
      ),
    );
    gh.lazySingleton<_i349.SearchCubit>(
      () => _i349.SearchCubit(
        storyRepository: gh<_i691.StoryRepository>(),
        pocketbaseService: gh<_i700.PocketbaseService>(),
      ),
    );
    gh.lazySingleton<_i1000.ProgressCubit>(
      () => _i1000.ProgressCubit(
        progressRepository: gh<_i369.ProgressRepository>(),
      ),
    );
    gh.lazySingleton<_i519.AuthCubit>(
      () => _i519.AuthCubit(authRepository: gh<_i593.AuthRepository>()),
    );
    return this;
  }
}

class _$InjectionModule extends _i212.InjectionModule {}

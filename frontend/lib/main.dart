import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/iap_service.dart';
import 'data/services/pocketbase_service.dart';
import 'data/services/tracking_service.dart';
import 'injection.dart';
import 'l10n/gen/app_localizations.dart';
import 'presentation/cubits/bookmark_cubit/bookmark_cubit.dart';
import 'presentation/cubits/favorite_cubit/favorite_cubit.dart';
import 'presentation/cubits/history_cubit/history_cubit.dart';
import 'presentation/cubits/home_cubit/home_cubit.dart';
import 'presentation/cubits/note_cubit/note_cubit.dart';
import 'presentation/cubits/progress_cubit/progress_cubit.dart';
import 'presentation/cubits/search_cubit/search_cubit.dart';
import 'presentation/cubits/audio_player_cubit/audio_player_cubit.dart';
import 'presentation/cubits/settings_cubit/settings_cubit.dart';
import 'presentation/cubits/stats_cubit/stats_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  configureDependencies();

  // Initialize services
  await getIt<PocketbaseService>().initialize();
  getIt<TrackingService>().startSession(null);
  getIt<IapService>().initialize();

  runApp(KoreanKidsStoriesApp());
}

class KoreanKidsStoriesApp extends StatelessWidget {
  KoreanKidsStoriesApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<FavoriteCubit>()..loadFavorites()),
        BlocProvider(create: (_) => getIt<BookmarkCubit>()..loadBookmarks()),
        BlocProvider(create: (_) => getIt<NoteCubit>()..loadNotes()),
        BlocProvider(create: (_) => getIt<HomeCubit>()),
        BlocProvider(create: (_) => getIt<ProgressCubit>()),
        BlocProvider(create: (_) => getIt<HistoryCubit>()),
        BlocProvider(create: (_) => getIt<SearchCubit>()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()..loadSettings()),
        BlocProvider(create: (_) => getIt<StatsCubit>()),
        BlocProvider(create: (_) => getIt<AudioPlayerCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _appRouter.config(),
            builder: (context, child) => child ?? const SizedBox.shrink(),
            locale: state is SettingsLoaded ? state.locale : null,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('vi'), Locale('ko')],
          );
        },
      ),
    );
  }
}

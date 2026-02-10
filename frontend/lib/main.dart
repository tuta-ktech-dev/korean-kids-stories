import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/pocketbase_service.dart';
import 'data/services/tracking_service.dart';
import 'l10n/gen/app_localizations.dart';
import 'presentation/cubits/auth_cubit/auth_cubit.dart';
import 'presentation/cubits/favorite_cubit/favorite_cubit.dart';
import 'presentation/cubits/history_cubit/history_cubit.dart';
import 'presentation/cubits/home_cubit/home_cubit.dart';
import 'presentation/cubits/progress_cubit/progress_cubit.dart';
import 'presentation/cubits/search_cubit/search_cubit.dart';
import 'presentation/cubits/settings_cubit/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await PocketbaseService().initialize();
  TrackingService().startSession(null);

  runApp(KoreanKidsStoriesApp());
}

class KoreanKidsStoriesApp extends StatelessWidget {
  KoreanKidsStoriesApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => FavoriteCubit()),
        BlocProvider(create: (_) => ProgressCubit()),
        BlocProvider(create: (_) => HistoryCubit()),
        BlocProvider(create: (_) => SearchCubit()),
        BlocProvider(create: (_) => SettingsCubit()..loadSettings()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (p, c) => p.runtimeType != c.runtimeType,
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<FavoriteCubit>().loadFavorites();
          } else if (state is Unauthenticated) {
            context.read<FavoriteCubit>().clearFavorites();
          }
          // Don't clear on AuthLoading/AuthInitial - only on explicit logout
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return MaterialApp.router(
            title: '꼬마 한동화',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _appRouter.config(),
            locale: state is SettingsLoaded ? state.locale : null,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('vi'), // Vietnamese
              Locale('ko'), // Korean
            ],
          );
        },
        ),
      ),
    );
  }
}

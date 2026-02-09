import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/pocketbase_service.dart';
import 'data/services/tracking_service.dart';
import 'presentation/cubits/auth_cubit/auth_cubit.dart';
import 'presentation/cubits/home_cubit/home_cubit.dart';

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
      ],
      child: MaterialApp.router(
        title: '꼬마 한동화',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/services/pocketbase_service.dart';
import 'presentation/cubits/stories_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Pocketbase
  await PocketbaseService().initialize();
  
  runApp(const KoreanKidsStoriesApp());
}

class KoreanKidsStoriesApp extends StatelessWidget {
  const KoreanKidsStoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StoriesCubit()..loadStories()),
      ],
      child: MaterialApp(
        title: '한국 동화 - Korean Kids Stories',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KoreanKidsStoriesApp());
}

class KoreanKidsStoriesApp extends StatelessWidget {
  const KoreanKidsStoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한국 동화 - Korean Kids Stories',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

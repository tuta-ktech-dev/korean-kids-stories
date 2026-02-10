import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Provides category-based colors for story detail screen
class StoryDetailTheme {
  final Color color;

  const StoryDetailTheme({required this.color});

  static StoryDetailTheme of(BuildContext context, String? category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (category) {
      case 'folktale':
        return StoryDetailTheme(
          color: isDark ? AppTheme.darkPrimaryPink : AppTheme.primaryPink,
        );
      case 'history':
        return StoryDetailTheme(
          color: isDark ? AppTheme.darkPrimarySky : AppTheme.primarySky,
        );
      case 'legend':
        return StoryDetailTheme(
          color: isDark ? AppTheme.darkPrimaryMint : AppTheme.primaryMint,
        );
      default:
        return StoryDetailTheme(
          color: isDark ? AppTheme.darkPrimaryCoral : AppTheme.primaryCoral,
        );
    }
  }
}

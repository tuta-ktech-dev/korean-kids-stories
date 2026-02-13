part of 'settings_cubit.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final Locale locale;
  final int minCharsPerSecond;
  /// Daily goal: stories (0=off, 1,2,3)
  final int dailyGoalStories;
  /// Daily goal: chapters (0=off, 3,5,10)
  final int dailyGoalChapters;

  const SettingsLoaded({
    required this.locale,
    this.minCharsPerSecond = 0,
    this.dailyGoalStories = 0,
    this.dailyGoalChapters = 0,
  });

  SettingsLoaded copyWith({
    Locale? locale,
    int? minCharsPerSecond,
    int? dailyGoalStories,
    int? dailyGoalChapters,
  }) {
    return SettingsLoaded(
      locale: locale ?? this.locale,
      minCharsPerSecond: minCharsPerSecond ?? this.minCharsPerSecond,
      dailyGoalStories: dailyGoalStories ?? this.dailyGoalStories,
      dailyGoalChapters: dailyGoalChapters ?? this.dailyGoalChapters,
    );
  }
}

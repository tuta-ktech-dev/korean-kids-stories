import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsInitial());

  static const String _localeKey = 'app_locale';
  static const String _minCharsPerSecondKey = 'min_next_chapter_chars_per_second';
  static const String _dailyGoalStoriesKey = 'daily_goal_stories';
  static const String _dailyGoalChaptersKey = 'daily_goal_chapters';

  /// Min chars per second = reading speed. 0 = no restriction.
  /// min_seconds = chapter_content.length / charsPerSecond
  static const int defaultMinCharsPerSecond = 10;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      final cps = prefs.getInt(_minCharsPerSecondKey) ?? defaultMinCharsPerSecond;
      final goalStories = prefs.getInt(_dailyGoalStoriesKey) ?? 0;
      final goalChapters = prefs.getInt(_dailyGoalChaptersKey) ?? 0;

      emit(SettingsLoaded(
        locale: localeCode != null ? Locale(localeCode) : const Locale('ko'),
        minCharsPerSecond: cps,
        dailyGoalStories: goalStories,
        dailyGoalChapters: goalChapters,
      ));
    } catch (e) {
      emit(const SettingsLoaded(locale: Locale('ko')));
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      if (state is SettingsLoaded) {
        emit((state as SettingsLoaded).copyWith(locale: locale));
      } else {
        emit(SettingsLoaded(locale: locale));
      }
    } catch (e) {}
  }

  Future<void> setMinCharsPerSecond(int charsPerSecond) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_minCharsPerSecondKey, charsPerSecond.clamp(0, 50));
      if (state is SettingsLoaded) {
        emit((state as SettingsLoaded).copyWith(minCharsPerSecond: charsPerSecond));
      }
    } catch (e) {}
  }

  Future<void> setDailyGoalStories(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyGoalStoriesKey, count.clamp(0, 10));
      if (state is SettingsLoaded) {
        emit((state as SettingsLoaded).copyWith(dailyGoalStories: count));
      }
    } catch (e) {}
  }

  Future<void> setDailyGoalChapters(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyGoalChaptersKey, count.clamp(0, 20));
      if (state is SettingsLoaded) {
        emit((state as SettingsLoaded).copyWith(dailyGoalChapters: count));
      }
    } catch (e) {}
  }
}

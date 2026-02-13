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

  /// Min chars per second = reading speed. 0 = no restriction.
  /// min_seconds = chapter_content.length / charsPerSecond
  static const int defaultMinCharsPerSecond = 0;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      final cps = prefs.getInt(_minCharsPerSecondKey) ?? defaultMinCharsPerSecond;

      emit(SettingsLoaded(
        locale: localeCode != null ? Locale(localeCode) : const Locale('ko'),
        minCharsPerSecond: cps,
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
}

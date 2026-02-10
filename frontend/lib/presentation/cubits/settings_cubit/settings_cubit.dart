import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsInitial());

  static const String _localeKey = 'app_locale';

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null) {
        emit(SettingsLoaded(locale: Locale(localeCode)));
      } else {
        // Default to system locale or English if not set
        emit(const SettingsLoaded(locale: Locale('ko')));
      }
    } catch (e) {
      // Fallback to Korean if error
      emit(const SettingsLoaded(locale: Locale('ko')));
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      emit(SettingsLoaded(locale: locale));
    } catch (e) {
      // Find a way to handle error, maybe emit error state or just log
    }
  }
}

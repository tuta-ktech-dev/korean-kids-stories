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

  const SettingsLoaded({
    required this.locale,
    this.minCharsPerSecond = 0,
  });

  SettingsLoaded copyWith({Locale? locale, int? minCharsPerSecond}) {
    return SettingsLoaded(
      locale: locale ?? this.locale,
      minCharsPerSecond: minCharsPerSecond ?? this.minCharsPerSecond,
    );
  }
}

part of 'settings_cubit.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final Locale locale;

  const SettingsLoaded({required this.locale});
}

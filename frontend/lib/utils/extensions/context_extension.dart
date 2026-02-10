import 'package:flutter/material.dart';
import 'package:korean_kids_stories/l10n/gen/app_localizations.dart';

extension ContextExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  AppLocalizations get l10n => AppLocalizations.of(this);

  double get width => MediaQuery.of(this).size.width;

  double get height => MediaQuery.of(this).size.height;

  double get paddingTop => MediaQuery.of(this).padding.top;

  double get paddingBottom => MediaQuery.of(this).padding.bottom;

  double get paddingLeft => MediaQuery.of(this).padding.left;

  double get paddingRight => MediaQuery.of(this).padding.right;

  bool get isPhoneSize => width < 600;

  bool get isTabletSize => width >= 600 && width < 1024;

  bool get isDesktopSize => width >= 1024;
}

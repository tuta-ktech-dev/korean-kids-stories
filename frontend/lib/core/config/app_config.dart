import 'package:flutter/foundation.dart';

class AppConfig {
  /// Use http://10.0.2.2:8090 for Android Emulator (direct to PocketBase)
  /// Use http://localhost:8090 for iOS Simulator
  static const String _devBaseUrl = 'http://trananhtu.vn:8090';
  /// Production: HTTPS via Apache proxy /api -> 127.0.0.1:8090
  static const String _prodBaseUrl = 'https://trananhtu.vn';

  static String get baseUrl => kDebugMode ? _devBaseUrl : _prodBaseUrl;
}

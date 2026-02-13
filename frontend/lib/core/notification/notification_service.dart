import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys for reminder settings (must match reminder_task.dart)
const String _reminderEnabledKey = 'reminder_enabled';
const String _reminderHourKey = 'reminder_hour';
const String _reminderMinuteKey = 'reminder_minute';
const String _lastReadDateKey = 'last_read_date';

/// Service for daily reading reminder notifications.
/// Only shows when user hasn't read today (no streak).
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'reading_reminder',
    'Reading Reminder',
    description: 'Reminds to read when end of day with no streak',
    importance: Importance.defaultImportance,
  );

  static const int _reminderNotificationId = 1001;

  /// Initialize and request permission. Call from main().
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create channel (Android 8+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Request permission Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // User tapped notification - app will open, no extra navigation needed
  }

  /// Register the periodic WorkManager task. Call after WorkManager.initialize().
  Future<void> registerReminderTask() async {
    // WorkManager is initialized in reminder_task.dart - we just need to
    // ensure the task is registered when app starts / settings change.
    // The actual registration happens in main() via ReminderTask.init()
  }

  /// Save last read date. Call from ProgressCubit when user reads.
  static Future<void> markReadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    await prefs.setString(_lastReadDateKey, today);
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get/set reminder settings
  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  static Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
  }

  static Future<int> getReminderHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderHourKey) ?? 20; // 8 PM default
  }

  static Future<int> getReminderMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderMinuteKey) ?? 0;
  }

  static Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, hour.clamp(0, 23));
    await prefs.setInt(_reminderMinuteKey, minute.clamp(0, 59));
  }

  /// Show the reminder notification (used by background task).
  /// Exposed for the WorkManager callback.
  static Future<void> showReminderNotification({
    required String title,
    required String body,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();
    const android = AndroidNotificationDetails(
      'reading_reminder',
      'Reading Reminder',
      channelDescription: 'Reminds to read when end of day with no streak',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await plugin.show(_reminderNotificationId, title, body, details);
  }
}

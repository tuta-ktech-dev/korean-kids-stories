import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';

/// Task name passed to callback (platform-agnostic).
const String _reminderTaskName = 'reading_reminder_check';

/// iOS requires this exact identifier in Info.plist & AppDelegate.
/// Must match com.hbstore.koreankids.reading_reminder (Info.plist, AppDelegate).
const String _reminderTaskId = 'com.hbstore.koreankids.reading_reminder';

/// Top-level callback for WorkManager - MUST be top-level, not nested.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // iOS sends taskId, Android sends taskName (_reminderTaskName)
    if (taskName != _reminderTaskName && taskName != _reminderTaskId) return true;

    try {
      await ReminderTask.checkAndNotify();
    } catch (e) {
      debugPrint('ReminderTask error: $e');
    }
    return true;
  });
}

/// Background task: check if end of day, no read today -> show notification.
class ReminderTask {
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _lastReadDateKey = 'last_read_date';
  static const String _reminderShownDateKey = 'reminder_shown_date';

  /// Initialize WorkManager and register periodic task. Call from main().
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      _reminderTaskId,
      _reminderTaskName,
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 5),
    );
  }

  /// Cancel the reminder task (when user disables reminder).
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_reminderTaskId);
  }

  /// Run the check: if reminder time passed, no read today -> show notification.
  static Future<void> checkAndNotify() async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool(_reminderEnabledKey) ?? false;
    if (!enabled) return;

    final reminderHour = prefs.getInt(_reminderHourKey) ?? 20;
    final reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final reminderMinutes = reminderHour * 60 + reminderMinute;

    // Only run if we're at or past the reminder time
    if (currentMinutes < reminderMinutes) return;

    final today = _todayString();
    final lastReadDate = prefs.getString(_lastReadDateKey) ?? '';
    if (lastReadDate == today) return; // Already read today

    final shownDate = prefs.getString(_reminderShownDateKey) ?? '';
    if (shownDate == today) return; // Already shown today

    // Show notification - use localized strings, fallback to default
    const title = '동화 속으로';
    const body =
        'Đã cuối ngày rồi! Đọc truyện để giữ streak nhé 📚';

    await NotificationService.showReminderNotification(
      title: title,
      body: body,
    );

    await prefs.setString(_reminderShownDateKey, today);
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

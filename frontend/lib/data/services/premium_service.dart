import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Free daily audio limit: 15 minutes
const int freeDailySeconds = 15 * 60; // 900

const String _keyIsPremium = 'premium_is_purchased';
const String _keyDailySecondsUsed = 'premium_daily_seconds_used';
const String _keyDailyDate = 'premium_daily_date';

/// Premium service - local only (no account).
/// Uses EncryptedSharedPreferences to reduce tampering.
/// Free: 15 min audio/day. Premium: unlimited via IAP.
@injectable
class PremiumService {
  PremiumService() : _prefs = EncryptedSharedPreferences();

  final EncryptedSharedPreferences _prefs;

  /// User has purchased premium (stored locally after IAP).
  Future<bool> checkIsPremium() async {
    final raw = await _prefs.getString(_keyIsPremium);
    return raw == '1' || raw == 'true';
  }

  /// Sync get for UI - not available (EncryptedSharedPreferences is async-only).
  bool get isPremiumSync => false;

  /// Called when IAP purchase completes. Persists premium status.
  Future<void> setPremiumPurchased() async {
    await _prefs.setString(_keyIsPremium, '1');
  }

  /// Remaining free seconds for today. Resets at midnight.
  Future<int> getRemainingFreeSecondsToday() async {
    if (await checkIsPremium()) return freeDailySeconds; // Unlimited
    final today = _todayString();
    final storedDate = await _prefs.getString(_keyDailyDate);
    if (storedDate != today) return freeDailySeconds; // New day
    final raw = await _prefs.getString(_keyDailySecondsUsed);
    final used = int.tryParse(raw) ?? 0;
    return (freeDailySeconds - used).clamp(0, freeDailySeconds);
  }

  /// Can user play audio? Premium or has remaining quota.
  Future<bool> canPlayAudio() async {
    if (await checkIsPremium()) return true;
    return (await getRemainingFreeSecondsToday()) > 0;
  }

  /// Add seconds of playback to daily usage. Call when playing.
  Future<void> addAudioSecondsUsed(int seconds) async {
    if (await checkIsPremium()) return;
    final today = _todayString();
    final storedDate = await _prefs.getString(_keyDailyDate);
    int used = (storedDate == today)
        ? (int.tryParse(await _prefs.getString(_keyDailySecondsUsed)) ?? 0)
        : 0;
    used += seconds;
    await _prefs.setString(_keyDailyDate, today);
    await _prefs.setString(_keyDailySecondsUsed, used.toString());
  }

  /// Today's used seconds (for UI).
  Future<int> getTodayUsedSeconds() async {
    final today = _todayString();
    final storedDate = await _prefs.getString(_keyDailyDate);
    if (storedDate != today) return 0;
    return int.tryParse(await _prefs.getString(_keyDailySecondsUsed)) ?? 0;
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

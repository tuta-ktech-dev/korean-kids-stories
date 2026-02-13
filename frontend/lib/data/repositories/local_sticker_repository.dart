import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

const String _storageKey = 'local_unlocked_stickers';

/// Lưu danh sách sticker đã unlock local (app kids không đăng nhập).
@injectable
class LocalStickerRepository {
  LocalStickerRepository() : _prefs = EncryptedSharedPreferences();

  final EncryptedSharedPreferences _prefs;

  Future<List<LocalUnlockedSticker>> getAll() async {
    try {
      final raw = await _prefs.getString(_storageKey);
      if (raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .where((e) => e is Map && e['sticker_id'] != null)
          .map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return LocalUnlockedSticker(
          stickerId: m['sticker_id'] as String,
          unlockSource: m['unlock_source'] as String? ?? 'story_complete',
          unlockedAt: _parseDateTime(m['unlocked_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('LocalStickerRepository.getAll error: $e');
      return [];
    }
  }

  Future<bool> unlockSticker({
    required String stickerId,
    String unlockSource = 'story_complete',
  }) async {
    try {
      final list = await getAll();
      if (list.any((x) => x.stickerId == stickerId)) return true;
      list.add(LocalUnlockedSticker(
        stickerId: stickerId,
        unlockSource: unlockSource,
        unlockedAt: DateTime.now(),
      ));
      final encoded = list.map((x) => {
            'sticker_id': x.stickerId,
            'unlock_source': x.unlockSource,
            'unlocked_at': x.unlockedAt?.toIso8601String(),
          }).toList();
      await _prefs.setString(_storageKey, jsonEncode(encoded));
      return true;
    } catch (e) {
      debugPrint('LocalStickerRepository.unlockSticker error: $e');
      return false;
    }
  }

  Future<bool> isUnlocked(String stickerId) async {
    final list = await getAll();
    return list.any((x) => x.stickerId == stickerId);
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class LocalUnlockedSticker {
  final String stickerId;
  final String unlockSource;
  final DateTime? unlockedAt;

  LocalUnlockedSticker({
    required this.stickerId,
    required this.unlockSource,
    this.unlockedAt,
  });
}

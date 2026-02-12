import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../models/reading_progress.dart';

const String _storageKey = 'local_reading_progress';

/// Lưu progress local dùng EncryptedSharedPreferences (cho guest).
/// Dữ liệu được mã hóa khi lưu.
@injectable
class LocalProgressRepository {
  LocalProgressRepository() : _prefs = EncryptedSharedPreferences();

  final EncryptedSharedPreferences _prefs;

  Future<ReadingProgress?> getProgress(String chapterId) async {
    try {
      final allJson = await _getAllMap();
      final data = allJson[chapterId];
      if (data == null || data is! Map) return null;
      return _progressFromMap(chapterId, data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('LocalProgressRepository.getProgress error: $e');
      return null;
    }
  }

  Future<List<ReadingProgress>> getAllProgress() async {
    try {
      final allJson = await _getAllMap();
      final list = <ReadingProgress>[];
      for (final e in allJson.entries) {
        if (e.value is Map) {
          final p = _progressFromMap(e.key, e.value as Map<String, dynamic>);
          list.add(p);
        }
      }
      list.sort((a, b) {
        final aAt = a.lastReadAt ?? DateTime(0);
        final bAt = b.lastReadAt ?? DateTime(0);
        return bAt.compareTo(aAt);
      });
      return list;
    } catch (e) {
      debugPrint('LocalProgressRepository.getAllProgress error: $e');
      return [];
    }
  }

  Future<ReadingProgress?> saveProgress({
    required String chapterId,
    required double percentRead,
    double? lastPosition,
    bool? isCompleted,
  }) async {
    try {
      final all = await _getAllMap();
      final existing = all[chapterId];
      Map<String, dynamic> data;
      if (existing is Map) {
        data = Map<String, dynamic>.from(existing);
      } else {
        data = {};
      }

      final safePercent = percentRead.isNaN || percentRead.isInfinite
          ? 0.0
          : percentRead.clamp(0.0, 100.0);

      data['chapter'] = chapterId;
      data['percent_read'] = safePercent;
      data['last_read_at'] = DateTime.now().toIso8601String();

      if (lastPosition != null) {
        data['last_position'] = lastPosition;
      }
      // Never overwrite is_completed from true → false: once completed, stays completed.
      if (isCompleted == true) {
        data['is_completed'] = true;
      } else if (isCompleted == false && data['is_completed'] != true) {
        data['is_completed'] = false;
      }

      all[chapterId] = data;
      await _saveAllMap(all);

      return _progressFromMap(chapterId, data);
    } catch (e) {
      debugPrint('LocalProgressRepository.saveProgress error: $e');
      return null;
    }
  }

  Future<ReadingProgress?> addBookmark({
    required String chapterId,
    required double position,
    String? note,
  }) async {
    try {
      final all = await _getAllMap();
      final existing = all[chapterId];
      Map<String, dynamic> data;
      if (existing is Map) {
        data = Map<String, dynamic>.from(existing);
      } else {
        data = {
          'chapter': chapterId,
          'percent_read': 0.0,
          'is_completed': false,
          'bookmarks': [],
        };
      }

      final bookmarks = List<Map<String, dynamic>>.from(
        (data['bookmarks'] as List?)?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}) ?? [],
      );
      bookmarks.add({
        'position': position,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });
      data['bookmarks'] = bookmarks;
      data['last_read_at'] = DateTime.now().toIso8601String();

      all[chapterId] = data;
      await _saveAllMap(all);

      return _progressFromMap(chapterId, data);
    } catch (e) {
      debugPrint('LocalProgressRepository.addBookmark error: $e');
      return null;
    }
  }

  Future<ReadingProgress?> removeBookmark({
    required String chapterId,
    required double position,
  }) async {
    try {
      final existing = await getProgress(chapterId);
      if (existing == null) return null;

      final all = await _getAllMap();
      final data = Map<String, dynamic>.from(all[chapterId] as Map? ?? {});

      final bookmarks = existing.bookmarks
          .where((b) => (b.position - position).abs() > 1.0)
          .map((b) => b.toJson())
          .toList();

      data['bookmarks'] = bookmarks;
      all[chapterId] = data;
      await _saveAllMap(all);

      return _progressFromMap(chapterId, data);
    } catch (e) {
      debugPrint('LocalProgressRepository.removeBookmark error: $e');
      return null;
    }
  }

  Future<ReadingProgress?> markCompleted(String chapterId) async {
    return saveProgress(chapterId: chapterId, percentRead: 100.0, isCompleted: true);
  }

  Future<bool> deleteProgress(String progressId) async {
    try {
      final chapterId = progressId.startsWith('local_') ? progressId.replaceFirst('local_', '') : progressId;
      final all = await _getAllMap();
      if (all.containsKey(chapterId)) {
        all.remove(chapterId);
        await _saveAllMap(all);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('LocalProgressRepository.deleteProgress error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _getAllMap() async {
    final raw = await _prefs.getString(_storageKey);
    if (raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveAllMap(Map<String, dynamic> map) async {
    await _prefs.setString(_storageKey, jsonEncode(map));
  }

  ReadingProgress _progressFromMap(String chapterId, Map<String, dynamic> data) {
    List<Bookmark> bookmarks = [];
    final bookmarksData = data['bookmarks'];
    if (bookmarksData is List) {
      bookmarks = bookmarksData
          .map((b) => Bookmark.fromJson(b is Map ? Map<String, dynamic>.from(b) : <String, dynamic>{}))
          .toList();
    }

    return ReadingProgress(
      id: 'local_$chapterId',
      userId: 'guest',
      chapterId: chapterId,
      percentRead: (data['percent_read'] as num?)?.toDouble() ?? 0.0,
      lastPosition: (data['last_position'] as num?)?.toDouble() ?? 0.0,
      isCompleted: data['is_completed'] == true,
      bookmarks: bookmarks,
      lastReadAt: _parseDateTime(data['last_read_at']),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

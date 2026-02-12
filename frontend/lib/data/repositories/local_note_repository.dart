import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'note_repository.dart';

const String _storageKey = 'local_notes';

/// Local storage for notes (kids app - no login).
@lazySingleton
class LocalNoteRepository {
  LocalNoteRepository() : _prefs = EncryptedSharedPreferences();

  final EncryptedSharedPreferences _prefs;

  Future<List<Map<String, dynamic>>> _getAll() async {
    final raw = await _prefs.getString(_storageKey);
    if (raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveAll(List<Map<String, dynamic>> notes) async {
    await _prefs.setString(_storageKey, jsonEncode(notes));
  }

  static StoryNote _mapToNote(Map<String, dynamic> m) {
    return StoryNote(
      id:
          m['id']?.toString() ??
          'local_${m['storyId']}_${m['chapterId'] ?? 'story'}',
      storyId: m['storyId']?.toString() ?? '',
      note: m['note']?.toString() ?? '',
      chapterId: m['chapterId']?.toString(),
      position: (m['position'] as num?)?.toDouble(),
      createdAt:
          DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
      storyTitle: m['storyTitle']?.toString(),
      chapterTitle: m['chapterTitle']?.toString(),
    );
  }

  Future<List<StoryNote>> getNotes() async {
    final list = await _getAll();
    return list.map(_mapToNote).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<StoryNote>> getNotesByStory(String storyId) async {
    final list = await _getAll();
    return list.where((m) => m['storyId'] == storyId).map(_mapToNote).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<StoryNote?> addStoryNote({
    required String storyId,
    required String note,
  }) async {
    try {
      final notes = await _getAll();
      final idx = notes.indexWhere(
        (m) =>
            m['storyId'] == storyId &&
            (m['chapterId'] == null || m['chapterId'].toString().isEmpty),
      );
      final id =
          'local_${storyId}_story_${DateTime.now().millisecondsSinceEpoch}';
      final item = {
        'id': id,
        'storyId': storyId,
        'note': note.trim(),
        'chapterId': null,
        'position': null,
        'createdAt': DateTime.now().toIso8601String(),
      };
      if (idx >= 0) {
        notes[idx] = item;
      } else {
        notes.add(item);
      }
      notes.sort((a, b) {
        final aAt = a['createdAt']?.toString() ?? '';
        final bAt = b['createdAt']?.toString() ?? '';
        return bAt.compareTo(aAt);
      });
      await _saveAll(notes);
      return _mapToNote(item);
    } catch (e) {
      debugPrint('LocalNoteRepository.addStoryNote error: $e');
      return null;
    }
  }

  Future<StoryNote?> addChapterNote({
    required String storyId,
    required String chapterId,
    required String note,
    double? position,
  }) async {
    try {
      final notes = await _getAll();
      final idx = notes.indexWhere((m) => m['chapterId'] == chapterId);
      final id = 'local_${chapterId}_${DateTime.now().millisecondsSinceEpoch}';
      final item = {
        'id': id,
        'storyId': storyId,
        'chapterId': chapterId,
        'note': note.trim(),
        'position': position,
        'createdAt': DateTime.now().toIso8601String(),
      };
      if (idx >= 0) {
        notes[idx] = item;
      } else {
        notes.add(item);
      }
      notes.sort((a, b) {
        final aAt = a['createdAt']?.toString() ?? '';
        final bAt = b['createdAt']?.toString() ?? '';
        return bAt.compareTo(aAt);
      });
      await _saveAll(notes);
      return _mapToNote(item);
    } catch (e) {
      debugPrint('LocalNoteRepository.addChapterNote error: $e');
      return null;
    }
  }

  Future<StoryNote?> getChapterNote(String chapterId) async {
    final notes = await _getAll();
    for (final m in notes) {
      if (m['chapterId'] == chapterId) return _mapToNote(m);
    }
    return null;
  }

  Future<StoryNote?> getStoryNote(String storyId) async {
    final notes = await _getAll();
    for (final m in notes) {
      if (m['storyId'] == storyId &&
          (m['chapterId'] == null || m['chapterId'].toString().isEmpty)) {
        return _mapToNote(m);
      }
    }
    return null;
  }

  Future<bool> updateNote(String noteId, String note) async {
    try {
      final notes = await _getAll();
      final idx = notes.indexWhere((m) => m['id'] == noteId);
      if (idx < 0) return false;
      notes[idx]['note'] = note.trim();
      notes[idx]['createdAt'] = DateTime.now().toIso8601String();
      await _saveAll(notes);
      return true;
    } catch (e) {
      debugPrint('LocalNoteRepository.updateNote error: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      final notes = await _getAll();
      notes.removeWhere((m) => m['id'] == noteId);
      await _saveAll(notes);
      return true;
    } catch (e) {
      debugPrint('LocalNoteRepository.deleteNote error: $e');
      return false;
    }
  }
}

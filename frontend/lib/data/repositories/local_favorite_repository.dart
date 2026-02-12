import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

const String _storageKey = 'local_favorites';

/// Local storage for favorites (kids app - no login).
@lazySingleton
class LocalFavoriteRepository {
  LocalFavoriteRepository() : _prefs = EncryptedSharedPreferences();

  final EncryptedSharedPreferences _prefs;

  Future<Set<String>> _getIds() async {
    final raw = await _prefs.getString(_storageKey);
    if (raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list.map((e) => e.toString()).where((s) => s.isNotEmpty).toSet();
      }
    } catch (_) {}
    return {};
  }

  Future<void> _saveIds(Set<String> ids) async {
    await _prefs.setString(_storageKey, jsonEncode(ids.toList()));
  }

  Future<bool> isFavorite(String storyId) async {
    final ids = await _getIds();
    return ids.contains(storyId);
  }

  Future<Set<String>> getFavoriteIds() async {
    return _getIds();
  }

  Future<bool> addFavorite(String storyId) async {
    try {
      final ids = await _getIds();
      ids.add(storyId);
      await _saveIds(ids);
      return true;
    } catch (e) {
      debugPrint('LocalFavoriteRepository.addFavorite error: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String storyId) async {
    try {
      final ids = await _getIds();
      ids.remove(storyId);
      await _saveIds(ids);
      return true;
    } catch (e) {
      debugPrint('LocalFavoriteRepository.removeFavorite error: $e');
      return false;
    }
  }
}

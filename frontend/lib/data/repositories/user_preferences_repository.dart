import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

@injectable
class UserPreferencesRepository {
  UserPreferencesRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get user preferences (theme, notifications). Creates default if not exists.
  Future<UserPreferences?> getPreferences() async {
    try {
      if (!_pbService.isAuthenticated) return null;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final result = await _pb.collection('user_preferences').getList(
            filter: 'user="$userId"',
            perPage: 1,
          );
      if (result.items.isNotEmpty) {
        return UserPreferences.fromRecord(result.items.first);
      }
      return null;
    } catch (e) {
      debugPrint('UserPreferencesRepository.getPreferences error: $e');
      return null;
    }
  }

  /// Create or update preferences
  Future<UserPreferences?> savePreferences({
    String? theme,
    bool? notificationsEnabled,
  }) async {
    try {
      if (!_pbService.isAuthenticated) return null;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final existing = await _pb.collection('user_preferences').getList(
            filter: 'user="$userId"',
            perPage: 1,
          );

      final body = <String, dynamic>{'user': userId};
      if (theme != null) body['theme'] = theme;
      if (notificationsEnabled != null) body['notifications_enabled'] = notificationsEnabled;

      if (existing.items.isNotEmpty) {
        final record = await _pb
            .collection('user_preferences')
            .update(existing.items.first.id, body: body);
        return UserPreferences.fromRecord(record);
      } else {
        body['theme'] = body['theme'] ?? 'system';
        body['notifications_enabled'] = body['notifications_enabled'] ?? false;
        final record = await _pb.collection('user_preferences').create(body: body);
        return UserPreferences.fromRecord(record);
      }
    } catch (e) {
      debugPrint('UserPreferencesRepository.savePreferences error: $e');
      return null;
    }
  }
}

class UserPreferences {
  final String id;
  final String theme;
  final bool notificationsEnabled;

  UserPreferences({
    required this.id,
    this.theme = 'system',
    this.notificationsEnabled = false,
  });

  factory UserPreferences.fromRecord(dynamic record) {
    return UserPreferences(
      id: record.id,
      theme: record.data['theme']?.toString() ?? 'system',
      notificationsEnabled: record.data['notifications_enabled'] == true,
    );
  }
}

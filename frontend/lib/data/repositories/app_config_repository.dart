import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

@injectable
class AppConfigRepository {
  AppConfigRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get all app config as map of key to value
  Future<Map<String, String>> getAll() async {
    try {
      final result = await _pb.collection('app_config').getFullList();
      final map = <String, String>{};
      for (final r in result) {
        final k = r.data['key']?.toString();
        final v = r.data['value']?.toString();
        if (k != null && k.isNotEmpty) {
          map[k] = v ?? '';
        }
      }
      return map;
    } catch (e) {
      debugPrint('AppConfigRepository.getAll error: $e');
      return {};
    }
  }

  /// Get single config value by key
  Future<String?> get(String key) async {
    try {
      final result = await _pb.collection('app_config').getList(
            filter: 'key="$key"',
            perPage: 1,
          );
      if (result.items.isEmpty) return null;
      return result.items.first.data['value']?.toString();
    } catch (e) {
      debugPrint('AppConfigRepository.get error: $e');
      return null;
    }
  }
}

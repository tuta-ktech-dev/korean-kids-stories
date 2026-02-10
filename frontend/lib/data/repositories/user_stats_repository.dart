import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/user_stats.dart';
import '../services/pocketbase_service.dart';

@injectable
class UserStatsRepository {
  UserStatsRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get user stats for current user
  Future<UserStats?> getMyStats() async {
    try {
      if (!_pbService.isAuthenticated) return null;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final result = await _pb.collection('user_stats').getList(
            filter: 'user="$userId"',
            perPage: 1,
          );

      if (result.items.isEmpty) return null;
      return UserStats.fromRecord(result.items.first);
    } catch (e) {
      debugPrint('UserStatsRepository.getMyStats error: $e');
      return null;
    }
  }
}

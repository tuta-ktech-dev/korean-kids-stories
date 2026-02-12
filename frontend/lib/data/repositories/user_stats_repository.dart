import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/constants/sticker_constants.dart';
import '../models/user_stats.dart';
import '../services/pocketbase_service.dart';
import 'progress_repository.dart';
import 'story_repository.dart';

@injectable
class UserStatsRepository {
  UserStatsRepository(
    this._pbService,
    this._progressRepo,
    this._storyRepo,
  );
  final PocketbaseService _pbService;
  final ProgressRepository _progressRepo;
  final StoryRepository _storyRepo;

  PocketBase get _pb => _pbService.pb;

  /// Get user stats. Khi guest: tự tính từ progress local.
  Future<UserStats?> getMyStats() async {
    if (!_pbService.isAuthenticated) {
      return _computeLocalStats();
    }

    try {
      final userId = _pbService.currentUser?.id;
      if (userId == null) return _computeLocalStats();

      final result = await _pb.collection('user_stats').getList(
            filter: 'user="$userId"',
            perPage: 1,
          );

      if (result.items.isEmpty) return _computeLocalStats();
      return UserStats.fromRecord(result.items.first);
    } catch (e) {
      debugPrint('UserStatsRepository.getMyStats error: $e');
      return _computeLocalStats();
    }
  }

  /// Tính stats local từ progress (chapters completed, stories completed)
  Future<UserStats> _computeLocalStats() async {
    try {
      await _storyRepo.initialize();
      final allProgress = await _progressRepo.getAllProgress();
      final completed = allProgress.where((p) => p.isCompleted).toList();
      final chaptersRead = completed.length;
      const chaptersListened = 0; // Guest: không có listening_sessions
      double totalXp = (chaptersRead * xpChapterRead).toDouble();

      // Đếm stories completed: tất cả chapters của story đã xong
      final Map<String, Set<String>> storyToCompleted = {};
      for (final p in completed) {
        final chapter = await _storyRepo.getChapter(p.chapterId);
        if (chapter != null) {
          storyToCompleted
              .putIfAbsent(chapter.storyId, () => {})
              .add(p.chapterId);
        }
      }

      int storiesCompleted = 0;
      for (final entry in storyToCompleted.entries) {
        final storyChapters = await _storyRepo.getChapters(entry.key);
        if (storyChapters.isNotEmpty &&
            entry.value.length >= storyChapters.length) {
          storiesCompleted++;
        }
      }

      totalXp += (storiesCompleted * xpStoryBonus).toDouble();

      final lastRead = completed.isNotEmpty
          ? completed
              .map((p) => p.lastReadAt)
              .whereType<DateTime>()
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null;
      final lastActivityDate =
          lastRead?.toIso8601String().split('T').first;

      return UserStats.fromLocal(
        totalXp: totalXp,
        chaptersRead: chaptersRead,
        chaptersListened: chaptersListened,
        storiesCompleted: storiesCompleted,
        streakDays: 0, // Có thể tính từ lastActivityDate nếu cần
        lastActivityDate: lastActivityDate,
      );
    } catch (e) {
      debugPrint('UserStatsRepository._computeLocalStats error: $e');
      return UserStats.fromLocal(totalXp: 0, chaptersRead: 0);
    }
  }
}

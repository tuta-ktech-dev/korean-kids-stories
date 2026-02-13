import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/reading_progress.dart';
import '../services/pocketbase_service.dart';
import 'local_progress_repository.dart';

export '../models/reading_progress.dart';

/// Repository cho reading progress operations.
/// Khi đã đăng nhập: dùng PocketBase.
/// Khi guest: dùng LocalProgressRepository (EncryptedSharedPreferences).
@injectable
class ProgressRepository {
  ProgressRepository(this._pbService, this._localRepo);
  final PocketbaseService _pbService;
  final LocalProgressRepository _localRepo;

  PocketBase get _pb => _pbService.pb;

  /// Kids app: always use local storage (no login)
  bool get _useLocal => true;

  /// Lấy progress của user cho chapter cụ thể
  Future<ReadingProgress?> getProgress(String chapterId) async {
    if (_useLocal) return _localRepo.getProgress(chapterId);

    try {
      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final result = await _pb.collection('reading_progress').getList(
            filter: 'user="$userId" && chapter="$chapterId"',
            page: 1,
            perPage: 1,
          );

      if (result.items.isEmpty) return null;
      return ReadingProgress.fromRecord(result.items.first);
    } catch (e) {
      debugPrint('ProgressRepository.getProgress error: $e');
      return null;
    }
  }

  /// Lấy tất cả progress của user
  Future<List<ReadingProgress>> getAllProgress() async {
    if (_useLocal) return _localRepo.getAllProgress();

    try {
      final userId = _pbService.currentUser?.id;
      if (userId == null) return [];

      final result = await _pb.collection('reading_progress').getFullList(
            filter: 'user="$userId"',
            sort: '-updated',
          );

      return result.map((r) => ReadingProgress.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('ProgressRepository.getAllProgress error: $e');
      return [];
    }
  }

  /// Cập nhật hoặc tạo mới progress
  Future<ReadingProgress?> saveProgress({
    required String chapterId,
    required double percentRead,
    double? lastPosition,
    bool? isCompleted,
    int? durationSeconds,
  }) async {
    if (_useLocal) {
      return _localRepo.saveProgress(
        chapterId: chapterId,
        percentRead: percentRead,
        lastPosition: lastPosition,
        isCompleted: isCompleted,
        durationSeconds: durationSeconds,
      );
    }

    try {
      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      // Kiểm tra xem đã có record chưa
      final existing = await getProgress(chapterId);

      // Ensure percent_read is never NaN/null (PocketBase validation requires it)
      final safePercent = percentRead.isNaN || percentRead.isInfinite
          ? 0.0
          : percentRead.clamp(0.0, 100.0);

      final data = <String, dynamic>{
        'user': userId,
        'chapter': chapterId,
        'percent_read': safePercent,
      };

      if (lastPosition != null) {
        data['last_position'] = lastPosition;
      }
      // Never overwrite is_completed from true → false: once completed, stays completed.
      // This avoids "double XP" when user replays a completed chapter.
      if (isCompleted == true) {
        data['is_completed'] = true;
      } else if (isCompleted == false && (existing?.isCompleted != true)) {
        data['is_completed'] = false;
      }

      RecordModel record;
      if (existing != null) {
        // Update existing
        record = await _pb.collection('reading_progress').update(
              existing.id,
              body: data,
            );
      } else {
        // Create new
        record = await _pb.collection('reading_progress').create(body: data);
      }

      return ReadingProgress.fromRecord(record);
    } catch (e) {
      debugPrint('ProgressRepository.saveProgress error: $e');
      return null;
    }
  }

  /// Thêm bookmark
  Future<ReadingProgress?> addBookmark({
    required String chapterId,
    required double position,
    String? note,
  }) async {
    if (_useLocal) {
      return _localRepo.addBookmark(chapterId: chapterId, position: position, note: note);
    }

    try {
      final existing = await getProgress(chapterId);

      if (existing != null) {
        // Update existing với bookmark mới
        final bookmarks = [...existing.bookmarks];
        bookmarks.add(Bookmark(position: position, note: note));

        final record = await _pb.collection('reading_progress').update(
              existing.id,
              body: {
                'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
              },
            );
        return ReadingProgress.fromRecord(record);
      } else {
        // Tạo mới với bookmark
        if (!_pbService.isAuthenticated) return null;
        final userId = _pbService.currentUser?.id;
        if (userId == null) return null;

        // percent_read required; position could be NaN if progress*100 when progress invalid
        final safePosition = position.isNaN || position.isInfinite ? 0.0 : position.clamp(0.0, 100.0);
        final record = await _pb.collection('reading_progress').create(
              body: {
                'user': userId,
                'chapter': chapterId,
                'percent_read': 0.0,
                'is_completed': false,
                'last_position': safePosition,
                'bookmarks': [Bookmark(position: safePosition, note: note).toJson()],
              },
            );
        return ReadingProgress.fromRecord(record);
      }
    } catch (e) {
      debugPrint('ProgressRepository.addBookmark error: $e');
      return null;
    }
  }

  /// Xóa bookmark
  Future<ReadingProgress?> removeBookmark({
    required String chapterId,
    required double position,
  }) async {
    if (_useLocal) {
      return _localRepo.removeBookmark(chapterId: chapterId, position: position);
    }

    try {
      final existing = await getProgress(chapterId);
      if (existing == null) return null;

      final bookmarks = existing.bookmarks
          .where((b) => (b.position - position).abs() > 1.0) // tolerance 1ms
          .toList();

      final record = await _pb.collection('reading_progress').update(
            existing.id,
            body: {
              'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
            },
          );
      return ReadingProgress.fromRecord(record);
    } catch (e) {
      debugPrint('ProgressRepository.removeBookmark error: $e');
      return null;
    }
  }

  /// Đánh dấu chapter đã hoàn thành
  Future<ReadingProgress?> markCompleted(String chapterId) async {
    return saveProgress(
      chapterId: chapterId,
      percentRead: 100.0,
      isCompleted: true,
    );
  }

  /// Xóa progress
  Future<bool> deleteProgress(String progressId) async {
    if (_useLocal) return _localRepo.deleteProgress(progressId);

    try {
      await _pb.collection('reading_progress').delete(progressId);
      return true;
    } catch (e) {
      debugPrint('ProgressRepository.deleteProgress error: $e');
      return false;
    }
  }

  /// Lấy tổng số chapter đã hoàn thành
  Future<int> getCompletedCount() async {
    final all = await getAllProgress();
    return all.where((p) => p.isCompleted).length;
  }

  /// Lấy Set các storyId mà user đã đọc (có ít nhất 1 chapter completed).
  /// Dùng để loại trừ truyện đã đọc khỏi recommended list.
  Future<Set<String>> getReadStoryIds() async {
    final all = await getAllProgress();
    final completedChapterIds = all
        .where((p) => p.isCompleted)
        .map((p) => p.chapterId)
        .toSet()
        .toList();
    if (completedChapterIds.isEmpty) return {};
    final chapters = await _pbService.getChaptersByIds(completedChapterIds);
    return chapters.map((c) => c.storyId).toSet();
  }

  /// Số chương đã đọc hôm nay (lastReadAt date = today)
  Future<int> getChaptersReadToday() async {
    final all = await getAllProgress();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return all.where((p) {
      final at = p.lastReadAt;
      if (at == null) return false;
      final d = DateTime(at.year, at.month, at.day);
      return d == todayDate;
    }).length;
  }

  /// Số truyện (distinct story) đã đọc hôm nay
  Future<int> getStoriesReadToday() async {
    final readIds = await getReadStoryIds();
    if (readIds.isEmpty) return 0;
    final all = await getAllProgress();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final chapterIdsToday = all
        .where((p) {
          final at = p.lastReadAt;
          if (at == null) return false;
          return DateTime(at.year, at.month, at.day) == todayDate;
        })
        .map((p) => p.chapterId)
        .toSet();
    if (chapterIdsToday.isEmpty) return 0;
    final chapters = await _pbService.getChaptersByIds(chapterIdsToday.toList());
    return chapters.map((c) => c.storyId).toSet().length;
  }

  /// Lấy tổng thời gian đọc (duration_seconds khi có, else ước tính)
  Future<Duration> getTotalReadingTime() async {
    final all = await getAllProgress();
    var totalSeconds = 0;
    for (final p in all) {
      if (p.durationSeconds > 0) {
        totalSeconds += p.durationSeconds;
      } else {
        totalSeconds += ((p.percentRead / 100) * 300).round(); // 5 min per chapter
      }
    }
    return Duration(seconds: totalSeconds);
  }
}

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

/// Model đại diện cho reading progress
class ReadingProgress {
  final String id;
  final String userId;
  final String chapterId;
  final double percentRead;
  final double lastPosition; // vị trí trong audio (ms)
  final bool isCompleted;
  final List<Bookmark> bookmarks;
  final DateTime? lastReadAt;

  ReadingProgress({
    required this.id,
    required this.userId,
    required this.chapterId,
    this.percentRead = 0.0,
    this.lastPosition = 0.0,
    this.isCompleted = false,
    this.bookmarks = const [],
    this.lastReadAt,
  });

  factory ReadingProgress.fromRecord(RecordModel record) {
    List<Bookmark> bookmarks = [];
    final bookmarksData = record.data['bookmarks'];
    if (bookmarksData is List) {
      bookmarks = bookmarksData
          .map((b) => Bookmark.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    return ReadingProgress(
      id: record.id,
      userId: record.getStringValue('user'),
      chapterId: record.getStringValue('chapter'),
      percentRead: record.getDoubleValue('percent_read'),
      lastPosition: record.getDoubleValue('last_position'),
      isCompleted: record.getBoolValue('is_completed'),
      bookmarks: bookmarks,
      lastReadAt: DateTime.tryParse(record.getStringValue('last_read_at')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'chapter': chapterId,
      'percent_read': percentRead,
      'last_position': lastPosition,
      'is_completed': isCompleted,
      'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
    };
  }

  ReadingProgress copyWith({
    String? id,
    String? userId,
    String? chapterId,
    double? percentRead,
    double? lastPosition,
    bool? isCompleted,
    List<Bookmark>? bookmarks,
    DateTime? lastReadAt,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      chapterId: chapterId ?? this.chapterId,
      percentRead: percentRead ?? this.percentRead,
      lastPosition: lastPosition ?? this.lastPosition,
      isCompleted: isCompleted ?? this.isCompleted,
      bookmarks: bookmarks ?? this.bookmarks,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}

/// Bookmark model
class Bookmark {
  final double position;
  final String? note;
  final DateTime createdAt;

  Bookmark({
    required this.position,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      position: (json['position'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Repository cho reading progress operations
@injectable
class ProgressRepository {
  ProgressRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Lấy progress của user cho chapter cụ thể
  Future<ReadingProgress?> getProgress(String chapterId) async {
    try {
      if (!_pbService.isAuthenticated) return null;

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
    try {
      if (!_pbService.isAuthenticated) return [];

      final userId = _pbService.currentUser?.id;
      if (userId == null) return [];

      final result = await _pb.collection('reading_progress').getFullList(
            filter: 'user="$userId"',
            sort: '-last_read_at',
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
  }) async {
    try {
      if (!_pbService.isAuthenticated) return null;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      // Kiểm tra xem đã có record chưa
      final existing = await getProgress(chapterId);

      final data = {
        'user': userId,
        'chapter': chapterId,
        'percent_read': percentRead.clamp(0.0, 100.0),
        'last_read_at': DateTime.now().toIso8601String(),
      };

      if (lastPosition != null) {
        data['last_position'] = lastPosition;
      }
      if (isCompleted != null) {
        data['is_completed'] = isCompleted;
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
        return saveProgress(
          chapterId: chapterId,
          percentRead: 0,
          lastPosition: position,
        );
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

  /// Lấy tổng thờ gian đọc (ước tính từ percent_read * audio_duration)
  Future<Duration> getTotalReadingTime() async {
    // Note: Cần fetch chapters để tính chính xác
    // Hiện tại trả về estimate
    final all = await getAllProgress();
    final totalMinutes = all.fold<double>(
      0,
      (sum, p) => sum + (p.percentRead / 100 * 5), // estimate 5 min per chapter
    );
    return Duration(minutes: totalMinutes.round());
  }
}

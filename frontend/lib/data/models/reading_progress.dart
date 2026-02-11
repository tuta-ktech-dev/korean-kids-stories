import 'package:pocketbase/pocketbase.dart';

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
      lastReadAt: _parseProgressDateTime(record.data['updated']),
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

DateTime? _parseProgressDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

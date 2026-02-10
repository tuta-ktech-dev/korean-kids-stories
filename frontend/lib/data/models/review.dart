import 'package:pocketbase/pocketbase.dart';

class Review {
  final String id;
  final String userId;
  final String storyId;
  final int rating;
  final String? comment;
  final String? userName;
  final DateTime created;
  final DateTime updated;

  Review({
    required this.id,
    required this.userId,
    required this.storyId,
    required this.rating,
    this.comment,
    this.userName,
    required this.created,
    required this.updated,
  });

  factory Review.fromRecord(RecordModel record) {
    String? userName;
    final expand = record.data['expand'];
    if (expand != null && expand is Map) {
      final userData = expand['user'];
      if (userData is Map) {
        userName = userData['name'] as String? ?? userData['email'] as String?;
      }
    }
    final commentRaw = record.data['comment'];
    String? comment;
    if (commentRaw != null && commentRaw is String && commentRaw.trim().isNotEmpty) {
      comment = commentRaw;
    }
    return Review(
      id: record.id,
      userId: record.getStringValue('user'),
      storyId: record.getStringValue('story'),
      rating: ((record.data['rating'] as num?)?.toInt() ?? 1).clamp(1, 5),
      comment: comment,
      userName: userName,
      created: _parseDateTime(record.data['created']),
      updated: _parseDateTime(record.data['updated']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

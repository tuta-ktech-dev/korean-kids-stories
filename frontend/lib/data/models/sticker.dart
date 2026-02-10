import 'package:pocketbase/pocketbase.dart';

class Sticker {
  final String id;
  final String type; // 'level' | 'story'
  final String key;
  final String nameKo;
  final String? descriptionKo;
  final String? imageUrl;
  final double? level; // for type=level
  final String? rankKo;
  final String? storyId; // for type=story
  final int sortOrder;

  Sticker({
    required this.id,
    required this.type,
    required this.key,
    required this.nameKo,
    this.descriptionKo,
    this.imageUrl,
    this.level,
    this.rankKo,
    this.storyId,
    this.sortOrder = 0,
  });

  factory Sticker.fromRecord(RecordModel record, {required PocketBase pb}) {
    final imageData = record.data['image'];
    String? imageFilename;
    if (imageData is String && imageData.isNotEmpty) {
      imageFilename = imageData;
    } else if (imageData is List && imageData.isNotEmpty) {
      imageFilename = imageData.first.toString();
    }

    String? imageUrl;
    if (imageFilename != null && imageFilename.isNotEmpty) {
      imageUrl = pb.files.getUrl(record, imageFilename).toString();
    }

    return Sticker(
      id: record.id,
      type: record.getStringValue('type'),
      key: record.getStringValue('key'),
      nameKo: record.getStringValue('name_ko'),
      descriptionKo: record.data['description_ko']?.toString(),
      imageUrl: imageUrl,
      level: (record.data['level'] as num?)?.toDouble(),
      rankKo: record.data['rank_ko']?.toString(),
      storyId: record.data['story']?.toString(),
      sortOrder: (record.data['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

import 'package:pocketbase/pocketbase.dart';

/// Represents a word timing entry for audio-text synchronization
class WordTiming {
  final String word;
  final double startTime;
  final double endTime;

  WordTiming({
    required this.word,
    required this.startTime,
    required this.endTime,
  });

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word'] as String? ?? '',
      startTime: (json['start_time'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['end_time'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// One chapter can have multiple audio versions (different narrators/voices)
class ChapterAudio {
  final String id;
  final String chapterId;
  final String? narrator;
  final String? audioUrl;
  final double audioDuration;
  final List<WordTiming> wordTimings;
  final DateTime created;
  final DateTime updated;

  ChapterAudio({
    required this.id,
    required this.chapterId,
    this.narrator,
    this.audioUrl,
    this.audioDuration = 0.0,
    this.wordTimings = const [],
    required this.created,
    required this.updated,
  });

  factory ChapterAudio.fromRecord(RecordModel record,
      {String baseUrl = '', String? authToken}) {
    final audioFile = record.getStringValue('audio_file');
    List<WordTiming> timings = [];
    final wordTimingsData = record.data['word_timings'];
    if (wordTimingsData != null && wordTimingsData is List) {
      timings = wordTimingsData
          .whereType<Map<String, dynamic>>()
          .map((json) => WordTiming.fromJson(json))
          .toList();
    }

    String? audioUrl;
    if (audioFile.isNotEmpty) {
      audioUrl = '$baseUrl/api/files/${record.collectionId}/${record.id}/$audioFile';
      if (authToken != null && authToken.isNotEmpty) {
        audioUrl = '${audioUrl}${audioUrl.contains('?') ? '&' : '?'}token=$authToken';
      }
    }

    return ChapterAudio(
      id: record.id,
      chapterId: record.getStringValue('chapter'),
      narrator: record.getStringValue('narrator').isNotEmpty
          ? record.getStringValue('narrator')
          : null,
      audioUrl: audioUrl,
      audioDuration: record.getDoubleValue('audio_duration'),
      wordTimings: timings,
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }
}

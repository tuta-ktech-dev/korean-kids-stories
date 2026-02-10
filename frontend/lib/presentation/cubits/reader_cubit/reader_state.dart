import 'package:equatable/equatable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {
  const ReaderInitial();
}

class ReaderLoading extends ReaderState {
  const ReaderLoading();
}

class ReaderLoaded extends ReaderState {
  final Chapter chapter;
  /// Multiple audio versions (different voices). Empty if no audio.
  final List<ChapterAudio> audios;
  /// Selected voice for playback. First item if audios not empty.
  final ChapterAudio? selectedAudio;
  final double fontSize;
  final bool isDarkMode;
  final double progress;
  final bool isPlaying;

  const ReaderLoaded({
    required this.chapter,
    this.audios = const [],
    this.selectedAudio,
    this.fontSize = 18,
    this.isDarkMode = false,
    this.progress = 0.0,
    this.isPlaying = false,
  });

  bool get hasAudio => audios.isNotEmpty;

  ReaderLoaded copyWith({
    Chapter? chapter,
    List<ChapterAudio>? audios,
    ChapterAudio? selectedAudio,
    double? fontSize,
    bool? isDarkMode,
    double? progress,
    bool? isPlaying,
  }) {
    return ReaderLoaded(
      chapter: chapter ?? this.chapter,
      audios: audios ?? this.audios,
      selectedAudio: selectedAudio ?? this.selectedAudio,
      fontSize: fontSize ?? this.fontSize,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [chapter, audios, selectedAudio, fontSize, isDarkMode, progress, isPlaying];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}

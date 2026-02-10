import 'package:equatable/equatable.dart';
import '../../../data/models/chapter.dart';

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
  final double fontSize;
  final bool isDarkMode;

  const ReaderLoaded({
    required this.chapter,
    this.fontSize = 18,
    this.isDarkMode = false,
  });

  ReaderLoaded copyWith({
    Chapter? chapter,
    double? fontSize,
    bool? isDarkMode,
  }) {
    return ReaderLoaded(
      chapter: chapter ?? this.chapter,
      fontSize: fontSize ?? this.fontSize,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [chapter, fontSize, isDarkMode];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

import '../../../data/repositories/note_repository.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteLoaded extends NoteState {
  final List<StoryNote> notes;

  const NoteLoaded({required this.notes});

  @override
  List<Object?> get props => [notes];
}

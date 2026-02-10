import 'package:equatable/equatable.dart';
import '../../../data/repositories/progress_repository.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoaded extends ProgressState {
  final ReadingProgress? progress;

  const ProgressLoaded({this.progress});

  @override
  List<Object?> get props => [progress];
}

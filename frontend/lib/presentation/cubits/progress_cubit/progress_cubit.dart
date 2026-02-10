import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/progress_repository.dart';
import 'progress_state.dart';

/// Global cubit for reading progress persistence.
/// Used by Reader (save on scroll/dispose), History, Library, etc.
class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository _repo = ProgressRepository();

  ProgressCubit() : super(const ProgressInitial());

  /// Get progress for a chapter (for initial load, History, etc.)
  Future<ReadingProgress?> getProgress(String chapterId) async {
    return _repo.getProgress(chapterId);
  }

  /// Persist progress. No emit - Reader gets progress from scroll.
  Future<void> saveProgress({
    required String chapterId,
    required double percentRead,
    double? lastPosition,
    bool? isCompleted,
  }) async {
    await _repo.saveProgress(
      chapterId: chapterId,
      percentRead: percentRead,
      lastPosition: lastPosition,
      isCompleted: isCompleted,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/pocketbase_service.dart';
import 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final PocketbaseService _pbService = PocketbaseService();

  ReaderCubit() : super(const ReaderInitial());

  Future<void> loadChapter(String chapterId) async {
    emit(const ReaderLoading());

    try {
      final chapter = await _pbService.getChapter(chapterId);

      if (chapter != null) {
        emit(ReaderLoaded(chapter: chapter));
      } else {
        emit(const ReaderError('Chapter not found'));
      }
    } catch (e) {
      emit(ReaderError('Failed to load chapter: ${e.toString()}'));
    }
  }

  void updateSettings({double? fontSize, bool? isDarkMode}) {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(fontSize: fontSize, isDarkMode: isDarkMode));
    }
  }
}

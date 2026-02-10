import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import 'search_state.dart';
export 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    StoryRepository? storyRepository,
    PocketbaseService? pocketbaseService,
  })  : _storyRepository = storyRepository ?? StoryRepository(),
        _pbService = pocketbaseService ?? PocketbaseService(),
        super(const SearchInitial());

  final StoryRepository _storyRepository;
  final PocketbaseService _pbService;
  List<String> _popularCache = _fallbackPopular;
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;
  static const List<String> _fallbackPopular = [
    '흥부와 놀부',
    '선녀와 나무꾼',
    '이순신',
    '거북선',
    '토끼',
  ];

  // Load search suggestions (history from local + popular from API)
  Future<void> loadSearchHistory() async {
    try {
      await _pbService.initialize();
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      final popular = await _pbService.getPopularSearches();
      _popularCache = popular.isNotEmpty ? popular : _fallbackPopular;
      emit(SearchSuggestionsLoaded(history: history, popular: _popularCache));
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      emit(SearchSuggestionsLoaded(history: history, popular: _popularCache));
    }
  }

  // Save search query to history
  Future<void> _saveToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];

      // Remove if already exists (to move to top)
      history.remove(query);
      // Add to beginning
      history.insert(0, query);
      // Keep only max items
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }

      await prefs.setStringList(_historyKey, history);
    } catch (e) {
      // Ignore errors
    }
  }

  // Remove item from history
  Future<void> removeFromHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];
      history.remove(query);
      await prefs.setStringList(_historyKey, history);
      emit(SearchSuggestionsLoaded(history: history, popular: _popularCache));
    } catch (e) {
      // Ignore errors
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      emit(SearchSuggestionsLoaded(history: [], popular: _popularCache));
    } catch (e) {
      // Ignore errors
    }
  }

  // Search stories
  Future<void> search({
    required String query,
    String? category,
    int? minAge,
    int? maxAge,
  }) async {
    if (query.trim().isEmpty && category == null) {
      loadSearchHistory();
      return;
    }

    emit(const SearchLoading());

    try {
      await _storyRepository.initialize();

      final stories = await _storyRepository.getStories(
        search: query.trim().isNotEmpty ? query.trim() : null,
        category: category,
        minAge: minAge,
        maxAge: maxAge,
      );

      // Save to history
      await _saveToHistory(query);

      emit(
        SearchLoaded(
          results: stories,
          query: query,
          category: category,
          minAge: minAge,
          maxAge: maxAge,
        ),
      );
    } on PocketbaseException catch (e) {
      emit(SearchError('검색 실패: ${e.message}'));
    } catch (e) {
      emit(SearchError('검색 실패: $e'));
    }
  }

  // Quick search by category
  Future<void> searchByCategory(String category) async {
    await search(query: '', category: category);
  }

  // Search by age range
  Future<void> searchByAgeRange(int minAge, int maxAge) async {
    await search(query: '', minAge: minAge, maxAge: maxAge);
  }

}

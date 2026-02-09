import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/story.dart';
import '../../../data/services/pocketbase_service.dart';
import 'search_state.dart';
export 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial());

  final _pbService = PocketbaseService();
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;

  // Load search history from local storage
  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      emit(SearchHistoryLoaded(history));
    } catch (e) {
      emit(const SearchHistoryLoaded([]));
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
      emit(SearchHistoryLoaded(history));
    } catch (e) {
      // Ignore errors
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      emit(const SearchHistoryLoaded([]));
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
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    try {
      await _pbService.initialize();

      // Build filter
      final filters = <String>[];
      filters.add('is_published=true');

      // Text search on title
      if (query.trim().isNotEmpty) {
        filters.add('title~"${query.trim()}"');
      }

      // Category filter
      if (category != null && category.isNotEmpty) {
        filters.add('category="$category"');
      }

      // Age range filter
      if (minAge != null) {
        filters.add('age_min>=$minAge');
      }
      if (maxAge != null) {
        filters.add('age_max<=$maxAge');
      }

      final filterString = filters.join(' && ');

      final result = await _pbService.pb.collection('stories').getList(
        page: 1,
        perPage: 50,
        filter: filterString,
        sort: '-created',
      );

      final stories = result.items.map((r) => Story.fromRecord(r, baseUrl: _pbService.pb.baseUrl)).toList();

      // Save to history
      await _saveToHistory(query);

      emit(SearchLoaded(
        results: stories,
        query: query,
        category: category,
        minAge: minAge,
        maxAge: maxAge,
      ));
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

  // Get popular searches (mock - in real app, this would come from backend)
  List<String> getPopularSearches() {
    return [
      '흥부와 놀부',
      '선녀와 나무꾼',
      '이순신',
      '거북선',
      '토끼',
    ];
  }
}

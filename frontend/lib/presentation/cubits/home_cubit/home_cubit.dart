import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/story.dart';
import '../../../data/services/pocketbase_service.dart';
import 'home_state.dart';
export 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial()) {
    initialize();
  }

  final _pbService = PocketbaseService();

  Future<void> initialize() async {
    emit(const HomeLoading());

    try {
      await _pbService.initialize();

      // Fetch categories, stories and sections in parallel
      final results = await Future.wait([
        _fetchCategories(),
        _fetchStories(),
        _fetchSections(),
      ]);

      final categories = results[0] as List<Category>;
      final stories = results[1] as List<HomeStory>;
      final sections = results[2] as StorySections;

      emit(
        HomeLoaded(
          categories: categories,
          stories: stories,
          sections: sections,
          selectedCategoryId: categories.isNotEmpty
              ? categories.first.id
              : null,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
      debugPrint('HomeCubit initialization error: $e');
    }
  }

  Future<List<Category>> _fetchCategories() async {
    // Fetch distinct categories from stories
    final stories = await _pbService.pb
        .collection('stories')
        .getFullList(filter: 'is_published=true', fields: 'category');

    // Extract unique categories
    final uniqueCategories = stories
        .map((r) => r.getStringValue('category'))
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    // Build category list
    return [
      const Category(
        id: 'all',
        label: '전체',
        icon: 'auto_stories',
        filterValue: null,
      ),
      ...uniqueCategories.map(
        (cat) => Category(
          id: cat,
          label: _getCategoryLabel(cat),
          icon: _getCategoryIcon(cat),
          filterValue: cat,
        ),
      ),
      const Category(
        id: 'favorite',
        label: '즐겨찾기',
        icon: 'favorite',
        isSpecial: true,
      ),
    ];
  }

  Future<List<HomeStory>> _fetchStories({String? category}) async {
    final stories = await _pbService.getStories(category: category);
    return stories.map((s) => _mapToHomeStory(s)).toList();
  }

  Future<StorySections> _fetchSections() async {
    try {
      // Fetch all stories for processing
      final allStories = await _pbService.pb
          .collection('stories')
          .getFullList(filter: 'is_published=true', sort: '-created');

      final homeStories = allStories
          .map((r) => _mapToHomeStoryFromRecord(r))
          .toList();

      // 🔥 Featured stories
      final featured = homeStories.where((s) => s.isFeatured).take(5).toList();

      // 🎧 Stories with audio
      final withAudio = homeStories.where((s) => s.hasAudio).take(5).toList();

      // ⭐ Most reviewed (sorted by review count)
      final mostReviewed = List<HomeStory>.from(homeStories)
        ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      mostReviewed.removeRange(
        5,
        mostReviewed.length.clamp(5, mostReviewed.length),
      );

      // 👁 Most viewed (sorted by view count)
      final mostViewed = List<HomeStory>.from(homeStories)
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      mostViewed.removeRange(5, mostViewed.length.clamp(5, mostViewed.length));

      // 🆕 Recent stories
      final recent = homeStories.take(5).toList();

      return StorySections(
        featured: featured,
        withAudio: withAudio,
        mostReviewed: mostReviewed.take(5).toList(),
        mostViewed: mostViewed.take(5).toList(),
        recent: recent,
      );
    } catch (e) {
      debugPrint('Error fetching sections: $e');
      return const StorySections();
    }
  }

  HomeStory _mapToHomeStory(Story story) {
    return HomeStory(
      id: story.id,
      title: story.title,
      thumbnailUrl: story.thumbnailUrl,
      category: story.category,
      ageMin: story.ageMin,
      ageMax: story.ageMax,
      totalChapters: story.totalChapters,
      isFeatured: story.isFeatured,
      hasAudio: story.hasAudio,
      hasQuiz: story.hasQuiz,
      hasIllustrations: story.hasIllustrations,
      averageRating: story.averageRating,
      reviewCount: story.reviewCount,
      viewCount: story.viewCount,
    );
  }

  HomeStory _mapToHomeStoryFromRecord(dynamic record) {
    final files = record.getListValue<String>('thumbnail');
    final baseUrl = _pbService.pb.baseURL;

    return HomeStory(
      id: record.id,
      title: record.getStringValue('title'),
      thumbnailUrl: files.isNotEmpty
          ? '$baseUrl/api/files/stories/${record.id}/${files.first}'
          : null,
      category: record.getStringValue('category'),
      ageMin: record.getIntValue('age_min'),
      ageMax: record.getIntValue('age_max'),
      totalChapters: record.getIntValue('total_chapters'),
      isFeatured: record.getBoolValue('is_featured'),
      hasAudio: record.getBoolValue('has_audio'),
      hasQuiz: record.getBoolValue('has_quiz'),
      hasIllustrations: record.getBoolValue('has_illustrations'),
      averageRating: record.data['average_rating'] != null
          ? (record.data['average_rating'] as num).toDouble()
          : null,
      reviewCount: record.getIntValue('review_count'),
      viewCount: record.getIntValue('view_count'),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'folktale':
        return '전통동화';
      case 'history':
        return '역사';
      case 'legend':
        return '전설';
      case 'fairy':
        return '동화';
      case 'edu':
        return '교육';
      default:
        return category;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'folktale':
        return 'auto_stories';
      case 'history':
        return 'history_edu';
      case 'legend':
        return 'stars';
      case 'fairy':
        return 'child_care';
      case 'edu':
        return 'school';
      default:
        return 'book';
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (state is! HomeLoaded) return;

    final current = state as HomeLoaded;
    final category = current.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => current.categories.first,
    );

    // Emit loading state for stories
    emit(
      current.copyWith(selectedCategoryId: categoryId, isLoadingStories: true),
    );

    try {
      List<HomeStory> stories;

      if (category.isSpecial) {
        // TODO: Load favorites from local storage
        stories = await _fetchStories();
      } else {
        stories = await _fetchStories(category: category.filterValue);
      }

      emit(
        current.copyWith(
          selectedCategoryId: categoryId,
          stories: stories,
          isLoadingStories: false,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load stories: $e'));
    }
  }

  Future<void> refresh() async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      final category = current.selectedCategory;
      await selectCategory(category?.id ?? 'all');
    }
  }

  // Helper to convert icon string to IconData
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'auto_stories':
        return Icons.auto_stories;
      case 'history_edu':
        return Icons.history_edu;
      case 'stars':
        return Icons.stars;
      case 'favorite':
        return Icons.favorite;
      case 'child_care':
        return Icons.child_care;
      case 'school':
        return Icons.school;
      case 'book':
        return Icons.book;
      default:
        return Icons.book;
    }
  }
}

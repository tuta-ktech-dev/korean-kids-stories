import 'package:injectable/injectable.dart';

import '../models/chapter.dart';
import '../models/story.dart';
import '../services/pocketbase_service.dart';

/// Repository for story-related operations
///
/// Abstracts data access and provides a clean API for the presentation layer
@injectable
class StoryRepository {
  StoryRepository(this._pbService);
  final PocketbaseService _pbService;

  /// Initialize the repository
  Future<void> initialize() async {
    await _pbService.initialize();
  }

  /// Fetch stories with optional filters
  /// 
  /// [category] - Filter by category
  /// [minAge] - Minimum age filter
  /// [maxAge] - Maximum age filter  
  /// [search] - Search term for title
  /// 
  /// Returns list of stories or throws [PocketbaseException]
  Future<List<Story>> getStories({
    String? category,
    int? minAge,
    int? maxAge,
    String? search,
  }) async {
    return _pbService.getStories(
      category: category,
      minAge: minAge,
      maxAge: maxAge,
      search: search,
    );
  }

  /// Get a single story by ID
  /// 
  /// Returns null if story not found
  Future<Story?> getStory(String id) async {
    return _pbService.getStory(id);
  }

  /// Get all chapters for a story
  /// 
  /// [storyId] - The story ID to fetch chapters for
  /// 
  /// Returns list of chapters sorted by chapter_number
  Future<List<Chapter>> getChapters(String storyId) async {
    return _pbService.getChapters(storyId);
  }

  /// Get a single chapter by ID
  /// 
  /// Returns null if chapter not found
  Future<Chapter?> getChapter(String chapterId) async {
    return _pbService.getChapter(chapterId);
  }

  /// Fetch stories with pagination support
  /// 
  /// [page] - Page number (1-based)
  /// [perPage] - Items per page
  /// [filters] - Additional filter parameters
  /// 
  /// Returns paginated results
  Future<StoryListResult> getStoriesPaginated({
    int page = 1,
    int perPage = 20,
    String? category,
    String? search,
  }) async {
    // Currently using the basic getStories and implementing pagination client-side
    // In production, you'd want server-side pagination
    final allStories = await _pbService.getStories(
      category: category,
      search: search,
    );

    final start = (page - 1) * perPage;
    final end = start + perPage;
    final paginatedStories = allStories.sublist(
      start.clamp(0, allStories.length),
      end.clamp(0, allStories.length),
    );

    return StoryListResult(
      stories: paginatedStories,
      totalItems: allStories.length,
      currentPage: page,
      totalPages: (allStories.length / perPage).ceil(),
      hasMore: end < allStories.length,
    );
  }

  /// Get featured stories
  Future<List<Story>> getFeaturedStories() async {
    final allStories = await _pbService.getStories();
    return allStories.where((s) => s.isFeatured).toList();
  }

  /// Get stories with audio
  Future<List<Story>> getStoriesWithAudio() async {
    final allStories = await _pbService.getStories();
    return allStories.where((s) => s.hasAudio).toList();
  }

  /// Get stories sorted by review count (most reviewed)
  Future<List<Story>> getMostReviewedStories({int limit = 10}) async {
    final allStories = await _pbService.getStories();
    final sorted = List<Story>.from(allStories)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(limit).toList();
  }

  /// Get stories sorted by view count (most viewed)
  Future<List<Story>> getMostViewedStories({int limit = 10}) async {
    final allStories = await _pbService.getStories();
    final sorted = List<Story>.from(allStories)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.take(limit).toList();
  }

  /// Get recent stories
  Future<List<Story>> getRecentStories({int limit = 10}) async {
    final allStories = await _pbService.getStories();
    final sorted = List<Story>.from(allStories)
      ..sort((a, b) => b.created.compareTo(a.created));
    return sorted.take(limit).toList();
  }

  /// Get unique categories from all stories
  Future<List<StoryCategory>> getCategories() async {
    final stories = await _pbService.getStories();
    final uniqueCategories = stories.map((s) => s.category).toSet().toList();
    
    return [
      const StoryCategory(
        id: 'all',
        label: '전체',
        iconName: 'auto_stories',
      ),
      ...uniqueCategories.map((cat) => StoryCategory(
            id: cat,
            label: _getCategoryLabel(cat),
            iconName: _getCategoryIcon(cat),
          )),
    ];
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
}

/// Result class for paginated story lists
class StoryListResult {
  final List<Story> stories;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  StoryListResult({
    required this.stories,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

/// Category model for stories
class StoryCategory {
  final String id;
  final String label;
  final String iconName;

  const StoryCategory({
    required this.id,
    required this.label,
    required this.iconName,
  });
}

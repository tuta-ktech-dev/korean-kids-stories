import 'package:equatable/equatable.dart';

// Category model
class Category extends Equatable {
  final String id;
  final String label;
  final String icon;
  final String? filterValue;
  final bool isSpecial;

  const Category({
    required this.id,
    required this.label,
    required this.icon,
    this.filterValue,
    this.isSpecial = false,
  });

  @override
  List<Object?> get props => [id, label, icon, filterValue, isSpecial];
}

// Story model (simplified for home)
class HomeStory extends Equatable {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String category;
  final int ageMin;
  final int ageMax;
  final int totalChapters;
  final bool isFeatured;
  final bool hasAudio;
  final bool hasQuiz;
  final bool hasIllustrations;
  final double? averageRating;
  final int reviewCount;
  final int viewCount;

  const HomeStory({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.category,
    required this.ageMin,
    required this.ageMax,
    required this.totalChapters,
    this.isFeatured = false,
    this.hasAudio = false,
    this.hasQuiz = false,
    this.hasIllustrations = false,
    this.averageRating,
    this.reviewCount = 0,
    this.viewCount = 0,
  });

  @override
  List<Object?> get props => [id, title, thumbnailUrl, category, ageMin, ageMax, totalChapters, isFeatured, hasAudio, hasQuiz, hasIllustrations, averageRating, reviewCount, viewCount];
}

// Story sections
class StorySections extends Equatable {
  final List<HomeStory> featured;      // 🔥 Nổi bật
  final List<HomeStory> withAudio;     // 🎧 Có Audio
  final List<HomeStory> mostReviewed;  // ⭐ Review nhiều
  final List<HomeStory> mostViewed;    // 👁 Lượt xem nhiều
  final List<HomeStory> recent;        // 🆕 Mới nhất

  const StorySections({
    this.featured = const [],
    this.withAudio = const [],
    this.mostReviewed = const [],
    this.mostViewed = const [],
    this.recent = const [],
  });

  @override
  List<Object?> get props => [featured, withAudio, mostReviewed, mostViewed, recent];

  StorySections copyWith({
    List<HomeStory>? featured,
    List<HomeStory>? withAudio,
    List<HomeStory>? mostReviewed,
    List<HomeStory>? mostViewed,
    List<HomeStory>? recent,
  }) {
    return StorySections(
      featured: featured ?? this.featured,
      withAudio: withAudio ?? this.withAudio,
      mostReviewed: mostReviewed ?? this.mostReviewed,
      mostViewed: mostViewed ?? this.mostViewed,
      recent: recent ?? this.recent,
    );
  }
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final List<HomeStory> stories;
  final StorySections sections;
  final String? selectedCategoryId;
  final bool isLoadingStories;
  final bool isLoadingMore;
  final bool hasMore;

  const HomeLoaded({
    required this.categories,
    required this.stories,
    this.sections = const StorySections(),
    this.selectedCategoryId,
    this.isLoadingStories = false,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  Category? get selectedCategory {
    if (selectedCategoryId == null) return null;
    return categories.firstWhere(
      (c) => c.id == selectedCategoryId,
      orElse: () => categories.first,
    );
  }

  @override
  List<Object?> get props =>
      [categories, stories, sections, selectedCategoryId, isLoadingStories, isLoadingMore, hasMore];

  HomeLoaded copyWith({
    List<Category>? categories,
    List<HomeStory>? stories,
    StorySections? sections,
    String? selectedCategoryId,
    bool? isLoadingStories,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      stories: stories ?? this.stories,
      sections: sections ?? this.sections,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoadingStories: isLoadingStories ?? this.isLoadingStories,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

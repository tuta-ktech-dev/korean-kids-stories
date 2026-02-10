import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../cubits/home_cubit/home_cubit.dart';
import '../widgets/story_card.dart';
import '../components/buttons/category_button.dart';
import '../components/headers/gradient_header.dart';
import '../components/inputs/app_search_bar.dart';
import '../components/story_card_skeleton.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: GradientHeader(
                title: '안녕하세요! 👋',
                subtitle: '오늘도 즐거운 이야기를 들어볼까요?',
                bottomWidget: AppSearchBar(
                  hintText: '재미있는 동화 찾기...',
                  onTap: () {
                    context.router.pushNamed('/search');
                  },
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(child: _buildCategories()),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Section Title
            SliverToBoxAdapter(child: _buildSectionTitle('✨ 추천 동화')),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Stories List
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildStoriesList(context, state),
            ),

            // 🔥 Featured Stories
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                '🔥 인기',
                (s) => s.sections.featured,
              ),
            ),

            // 🎧 Stories with Audio
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                '🎧 오디오',
                (s) => s.sections.withAudio,
              ),
            ),

            // ⭐ Most Reviewed
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                '⭐ 리뷰 많은',
                (s) => s.sections.mostReviewed,
              ),
            ),

            // 👁 Most Viewed
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                '👁 조회수 많은',
                (s) => s.sections.mostViewed,
              ),
            ),

            // 🆕 Recent Stories
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                '🆕 최신',
                (s) => s.sections.recent,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 12,
                children: state.categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isSelected = state.selectedCategoryId == category.id;

                  return CategoryButton(
                    icon: HomeCubit.getIconData(category.icon),
                    label: category.label,
                    color: _getCategoryColor(context, index),
                    isSelected: isSelected,
                    onTap: () {
                      context.read<HomeCubit>().selectCategory(category.id);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Color _getCategoryColor(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      isDark ? AppTheme.darkPrimaryPink : AppTheme.primaryPink,
      isDark ? AppTheme.darkPrimarySky : AppTheme.primarySky,
      isDark ? AppTheme.darkPrimaryMint : AppTheme.primaryMint,
      isDark ? AppTheme.darkPrimaryCoral : AppTheme.primaryCoral,
    ];
    return colors[index % colors.length];
  }

  Widget _buildSectionTitle(String title) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTheme.headingMedium(context)),
              if (state is HomeLoaded &&
                  !state.isLoadingStories &&
                  title == '✨ 추천 동화')
                TextButton(
                  onPressed: () => context.read<HomeCubit>().refresh(),
                  child: Text(
                    '새로고침',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: AppTheme.primaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoriesList(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is HomeError) {
      return SliverToBoxAdapter(child: _buildErrorState(context, state));
    }

    if (state is HomeLoaded) {
      if (state.isLoadingStories) {
        return const SliverToBoxAdapter(child: StoryCardSkeletonList(count: 3));
      }

      final stories = state.stories;

      if (stories.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyState(context));
      }

      return SliverToBoxAdapter(
        child: SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) =>
                _buildStoryCard(stories[index], context),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter();
  }

  Widget _buildStoryCard(HomeStory story, BuildContext context) {
    return StoryCard(
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
      onTap: () {
        context.router.push(StoryDetailRoute(storyId: story.id));
      },
    );
  }

  // Section with title - hides if empty
  Widget _buildSectionWithTitle(
    BuildContext context,
    HomeState state,
    String title,
    List<HomeStory> Function(HomeLoaded) getStories,
  ) {
    if (state is! HomeLoaded) return const SliverToBoxAdapter();

    final stories = getStories(state);
    if (stories.isEmpty) return const SliverToBoxAdapter();

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSectionTitle(title),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) =>
                _buildStoryCard(stories[index], context),
          ),
        ),
      ]),
    );
  }

  Widget _buildErrorState(BuildContext context, HomeError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(height: 16),
            Text('이야기를 불러올 수 없어요', style: AppTheme.bodyLarge(context)),
            const SizedBox(height: 8),
            Text('서버 연결을 확인해주세요', style: AppTheme.caption(context)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().initialize(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(height: 16),
            Text('등록된 이야기가 없어요', style: AppTheme.bodyLarge(context)),
            const SizedBox(height: 8),
            Text('관리자 페이지에서 이야기를 추가해주세요', style: AppTheme.caption(context)),
          ],
        ),
      ),
    );
  }
}

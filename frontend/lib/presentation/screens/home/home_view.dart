import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/home_cubit/home_cubit.dart';
import '../../widgets/story_card.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../components/buttons/category_button.dart';
import '../../components/headers/gradient_header.dart';
import '../../components/inputs/app_search_bar.dart';
import '../../components/story_card_skeleton.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().fullRefresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // Header
            SliverToBoxAdapter(
              child: GradientHeader(
                title: context.l10n.homeWelcome,
                subtitle: context.l10n.homeSubtitle,
                bottomWidget: AppSearchBar(
                  hintText: context.l10n.homeSearchHint,
                  onTap: () {
                    // Navigate to Search Tab (Index 1)
                    final tabsRouter = AutoTabsRouter.of(context);
                    tabsRouter.setActiveIndex(1);
                  },
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(child: _buildCategories()),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Section Title
            SliverToBoxAdapter(
              child: _buildSectionTitle(context.l10n.recommendedStories),
            ),

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
                context.l10n.popularSectionTitle,
                (s) => s.sections.featured,
              ),
            ),

            // 🎧 Stories with Audio
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                context.l10n.audioStories,
                (s) => s.sections.withAudio,
              ),
            ),

            // ⭐ Most Reviewed
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                context.l10n.mostReviewedStories,
                (s) => s.sections.mostReviewed,
              ),
            ),

            // 👁 Most Viewed
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                context.l10n.mostViewedStories,
                (s) => s.sections.mostViewed,
              ),
            ),

            // 🆕 Recent Stories
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => _buildSectionWithTitle(
                context,
                state,
                context.l10n.recentStories,
                (s) => s.sections.recent,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
          ),
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
                  title == context.l10n.recommendedStories)
                TextButton(
                  onPressed: () => context.read<HomeCubit>().refresh(),
                  child: Text(
                    context.l10n.refresh,
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
        child: _StoriesHorizontalList(
          stories: stories,
          hasMore: state.hasMore,
          isLoadingMore: state.isLoadingMore,
          onLoadMore: () => context.read<HomeCubit>().loadMore(),
          buildCard: (s) => _buildStoryCard(s, context),
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
        context.router.root.push(StoryDetailRoute(storyId: story.id));
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
          height: 300,
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
            Text(
              context.l10n.loadStoryError,
              style: AppTheme.bodyLarge(context),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.checkConnection,
              style: AppTheme.caption(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().initialize(),
              child: Text(context.l10n.retry),
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
            Text(context.l10n.noStories, style: AppTheme.bodyLarge(context)),
            const SizedBox(height: 8),
            Text(
              context.l10n.addStoriesAdmin,
              style: AppTheme.caption(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal list with load-more on scroll
class _StoriesHorizontalList extends StatefulWidget {
  const _StoriesHorizontalList({
    required this.stories,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.buildCard,
  });

  final List<HomeStory> stories;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final Widget Function(HomeStory) buildCard;

  @override
  State<_StoriesHorizontalList> createState() => _StoriesHorizontalListState();
}

class _StoriesHorizontalListState extends State<_StoriesHorizontalList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final pos = _controller.position;
    if (pos.pixels >= pos.maxScrollExtent - 150) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: widget.stories.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.stories.length) {
            return const SizedBox(
              width: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return widget.buildCard(widget.stories[index]);
        },
      ),
    );
  }
}

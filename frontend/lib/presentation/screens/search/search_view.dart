import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/responsive_padding.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../cubits/search_cubit/search_cubit.dart';
import '../../widgets/story_card.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<SearchCubit>().state;
    if (state is! SearchLoaded) return;
    if (state.isLoadingMore || !state.hasMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 150) {
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<SearchCubit>().state;
    if (state is SearchLoaded) {
      _searchController.text = state.query;
    } else if (state is! SearchSuggestionsLoaded) {
      context.read<SearchCubit>().loadSearchHistory();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchCubit>().search(query: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor(context)),
          onPressed: () => context.router.maybePop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            hintStyle: TextStyle(color: AppTheme.textMutedColor(context)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: AppTheme.textMutedColor(context)),
              onPressed: () {
                _searchController.clear();
                context.read<SearchCubit>().loadSearchHistory();
              },
            ),
          ),
          style: AppTheme.bodyLarge(context),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryColor(context)),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: ResponsivePadding(
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchLoaded) {
            return _buildSearchResults(state);
          }

          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTheme.bodyLarge(context)),
                ],
              ),
            );
          }

          // Initial state or history loaded
          return _buildSearchSuggestions();
        },
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noSearchResults(state.query),
              style: AppTheme.bodyLarge(context),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Text(
              context.l10n.searchAgainHint,
              style: AppTheme.caption(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length + (state.hasMore && state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final story = state.results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StoryCard(
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
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchSuggestionsLoaded && state.history.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.recentSearches,
                          style: AppTheme.headingMedium(context),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<SearchCubit>().clearHistory();
                          },
                          child: Text(context.l10n.clearAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: state.history.map((query) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.text = query;
                            _performSearch(query);
                          },
                          child: Chip(
                            label: Text(query),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              context.read<SearchCubit>().removeFromHistory(
                                query,
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Popular searches
          Text(
            context.l10n.popularSearches,
            style: AppTheme.headingMedium(context),
          ),
          const SizedBox(height: 12),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              final popular = state is SearchSuggestionsLoaded
                  ? state.popular
                  : const ['흥부와 놀부', '선녀와 나무꾼', '이순신', '거북선', '토끼'];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popular.map((query) {
              return ActionChip(
                label: Text(query),
                onPressed: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Categories
          Text(context.l10n.categories, style: AppTheme.headingMedium(context)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(
                context.l10n.categoryFolktale,
                'folktale',
                Icons.auto_stories,
              ),
              _buildCategoryChip(
                context.l10n.categoryHistory,
                'history',
                Icons.history_edu,
              ),
              _buildCategoryChip(
                context.l10n.categoryLegend,
                'legend',
                Icons.stars,
              ),
              _buildCategoryChip(
                context.l10n.categoryEdu,
                'edu',
                Icons.school,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Age filters
          Text(context.l10n.ageGroups, style: AppTheme.headingMedium(context)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAgeChip(context.l10n.ageGroup4to6, 4, 6),
              _buildAgeChip(context.l10n.ageGroup7to9, 7, 9),
              _buildAgeChip(context.l10n.ageGroup10to12, 10, 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        context.read<SearchCubit>().searchByCategory(category);
      },
    );
  }

  Widget _buildAgeChip(String label, int minAge, int maxAge) {
    return ActionChip(
      avatar: const Icon(Icons.child_care, size: 18),
      label: Text(label),
      onPressed: () {
        context.read<SearchCubit>().searchByAgeRange(minAge, maxAge);
      },
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../cubits/stories_cubit.dart';
import '../widgets/story_card.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppTheme.backgroundColor(context);
    final primaryColor = AppTheme.primaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, isDark, primaryColor),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _buildCategories(context, isDark),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Stories Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✨ 추천 동화',
                      style: AppTheme.headingMedium(context),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<StoriesCubit>().refresh();
                      },
                      child: Text(
                        '새로고침',
                        style: AppTheme.bodyMedium(context).copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Stories List from API
            BlocBuilder<StoriesCubit, StoriesState>(
              builder: (context, state) {
                if (state is StoriesLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (state is StoriesError) {
                  return SliverToBoxAdapter(
                    child: Center(
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
                              '이야기를 불러올 수 없어요',
                              style: AppTheme.bodyLarge(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '백엔드 서버가 실행 중인지 확인해주세요',
                              style: AppTheme.caption(context),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<StoriesCubit>().loadStories();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is StoriesLoaded) {
                  final stories = state.stories;
                  
                  if (stories.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
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
                              Text(
                                '아직 등록된 이야기가 없어요',
                                style: AppTheme.bodyLarge(context),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '관리자 페이지에서 이야기를 추가해주세요',
                                style: AppTheme.caption(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 320,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return StoryCard(
                            id: story.id,
                            title: story.title,
                            thumbnailUrl: story.thumbnailUrl,
                            category: story.category,
                            ageMin: story.ageMin,
                            ageMax: story.ageMax,
                            totalChapters: story.totalChapters,
                            onTap: () {
                              // Navigate to story detail
                            },
                          );
                        },
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter();
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkPrimaryPink, AppTheme.darkPrimaryCoral]
              : [AppTheme.primaryPink, AppTheme.primaryCoral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요! 👋',
                      style: AppTheme.headingMedium(context).copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘도 즐거운 이야기를 들어볼까요?',
                      style: AppTheme.bodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppTheme.textMutedColor(context),
                ),
                const SizedBox(width: 12),
                Text(
                  '재미있는 동화 찾기...',
                  style: AppTheme.bodyMedium(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CategoryButton(
            icon: Icons.auto_stories,
            label: '전통동화',
            color: isDark ? AppTheme.darkPrimaryPink : AppTheme.primaryPink,
            isSelected: true,
            onTap: () {},
          ),
          _CategoryButton(
            icon: Icons.history_edu,
            label: '역사',
            color: isDark ? AppTheme.darkPrimarySky : AppTheme.primarySky,
            onTap: () {},
          ),
          _CategoryButton(
            icon: Icons.stars,
            label: '전설',
            color: isDark ? AppTheme.darkPrimaryMint : AppTheme.primaryMint,
            onTap: () {},
          ),
          _CategoryButton(
            icon: Icons.favorite,
            label: '즐겨찾기',
            color: isDark ? AppTheme.darkPrimaryCoral : AppTheme.primaryCoral,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final surfaceColor = AppTheme.surfaceColor(context);
    final primaryColor = AppTheme.primaryColor(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: '홈', isActive: true, primaryColor: primaryColor, context: context),
          _NavItem(icon: Icons.search_rounded, label: '탐색', primaryColor: primaryColor, context: context),
          _NavItem(icon: Icons.library_books_rounded, label: '서재', primaryColor: primaryColor, context: context),
          _NavItem(icon: Icons.person_rounded, label: '내정보', primaryColor: primaryColor, context: context),
        ],
      ),
    );
  }
}

// Category button widget
class _CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: color, width: 3) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.caption(context).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? color : AppTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom nav item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color primaryColor;
  final BuildContext context;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.primaryColor,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isActive
          ? BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primaryColor : AppTheme.textMutedColor(context),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.caption(context).copyWith(
              color: isActive ? primaryColor : AppTheme.textMutedColor(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

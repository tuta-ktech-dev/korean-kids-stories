import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/story_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Korean-style curved header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryPink,
                      AppTheme.primaryCoral,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome text in Korean style
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
                                '안녕하세요! 👋', // Hello!
                                style: AppTheme.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '오늘도 즐거운 이야기를 들어볼까요?', // Shall we listen to a fun story today?
                                style: AppTheme.bodyLarge.copyWith(
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
                    // Search bar - Korean apps love big rounded search
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
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '재미있는 동화 찾기...', // Find interesting stories...
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories - Korean horizontal scroll
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CategoryButton(
                      icon: Icons.auto_stories,
                      label: '전통동화', // Folktale
                      color: AppTheme.primaryPink,
                      isSelected: true,
                    ),
                    _CategoryButton(
                      icon: Icons.history_edu,
                      label: '역사', // History
                      color: AppTheme.primarySky,
                    ),
                    _CategoryButton(
                      icon: Icons.stars,
                      label: '전설', // Legend
                      color: AppTheme.primaryMint,
                    ),
                    _CategoryButton(
                      icon: Icons.favorite,
                      label: '즐겨찾기', // Favorites
                      color: AppTheme.primaryCoral,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Featured Stories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✨ 추천 동화', // Recommended Stories
                      style: AppTheme.headingMedium,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '더보기', // See more
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Horizontal story list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 320,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: [
                    StoryCard(
                      title: '흥부와 놀부', // Heungbu and Nolbu
                      category: 'folktale',
                      ageMin: 5,
                      ageMax: 8,
                      totalChapters: 3,
                      onTap: () {},
                    ),
                    StoryCard(
                      title: '선녀와 나무꾼', // The Woodcutter and the Fairy
                      category: 'legend',
                      ageMin: 6,
                      ageMax: 10,
                      totalChapters: 5,
                      onTap: () {},
                    ),
                    StoryCard(
                      title: '장화홍련전', // Janghwa Hongryeon
                      category: 'folktale',
                      ageMin: 7,
                      ageMax: 10,
                      totalChapters: 4,
                      onTap: () {},
                    ),
                    StoryCard(
                      title: '세종대왕', // King Sejong
                      category: 'history',
                      ageMin: 8,
                      ageMax: 10,
                      totalChapters: 6,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Recently Played Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text(
                  '📚 최근에 들은 이야기', // Recently listened
                  style: AppTheme.headingMedium,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _RecentStoryItem(
                  title: '흥부와 놀부 - 제1화',
                  progress: 0.7,
                  color: AppTheme.primaryPink,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),

      // Korean-style bottom nav - rounded and floating
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
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
            _NavItem(icon: Icons.home_rounded, label: '홈', isActive: true),
            _NavItem(icon: Icons.search_rounded, label: '탐색'),
            _NavItem(icon: Icons.library_books_rounded, label: '서재'),
            _NavItem(icon: Icons.person_rounded, label: '내정보'),
          ],
        ),
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

  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: color, width: 3)
                : null,
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
          style: AppTheme.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppTheme.textMedium,
          ),
        ),
      ],
    );
  }
}

// Recent story item
class _RecentStoryItem extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;

  const _RecentStoryItem({
    required this.title,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              Icons.headphones_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
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

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isActive
          ? BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primaryPink : AppTheme.textLight,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: isActive ? AppTheme.primaryPink : AppTheme.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

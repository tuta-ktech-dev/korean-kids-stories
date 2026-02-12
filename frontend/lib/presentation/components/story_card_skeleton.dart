import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Skeleton loading card for stories
class StoryCardSkeleton extends StatelessWidget {
  const StoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppTheme.darkSurface : AppTheme.textLight;
    final highlightColor = isDark ? AppTheme.darkCard : AppTheme.backgroundSoft;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square skeleton thumbnail
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildShimmerEffect(context, baseColor, highlightColor),
                  // Skeleton badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      spacing: 4,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: highlightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: highlightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Skeleton category tag
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          // Skeleton title
          Container(
            width: 140,
            height: 16,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          // Skeleton second line of title
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Skeleton age/chapters
          Row(
            children: [
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context, Color baseColor, Color highlightColor) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          tileMode: TileMode.clamp,
        ).createShader(bounds);
      },
      child: Container(
        color: baseColor,
      ),
    );
  }
}

/// List of skeleton cards for horizontal scrolling
class StoryCardSkeletonList extends StatelessWidget {
  final int count;
  
  const StoryCardSkeletonList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        itemBuilder: (context, index) => const StoryCardSkeleton(),
      ),
    );
  }
}

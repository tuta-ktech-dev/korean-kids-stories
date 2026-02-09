import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../components/image_placeholder.dart';

class StoryCard extends StatelessWidget {
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

  const StoryCard({
    super.key,
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
    this.onTap,
  });

  bool get _hasValidThumbnail {
    if (thumbnailUrl == null) return false;
    if (thumbnailUrl!.isEmpty) return false;
    // Check if URL ends with just / (no filename)
    if (thumbnailUrl!.endsWith('/')) return false;
    return true;
  }

  Widget _buildFeatureBadges() {
    return Wrap(
      spacing: 4,
      children: [
        if (isFeatured)
          _buildBadge(Icons.star_rounded, Colors.amber),
        if (hasAudio)
          _buildBadge(Icons.headphones_rounded, Colors.orange),
        if (hasQuiz)
          _buildBadge(Icons.quiz_rounded, Colors.green),
        if (hasIllustrations)
          _buildBadge(Icons.palette_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 14,
        color: color,
      ),
    );
  }

  // Category colors adapt to theme
  Color _getCategoryColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (category) {
      case 'folktale':
        return isDark ? AppTheme.darkPrimaryPink : AppTheme.primaryPink;
      case 'history':
        return isDark ? AppTheme.darkPrimarySky : AppTheme.primarySky;
      case 'legend':
        return isDark ? AppTheme.darkPrimaryMint : AppTheme.primaryMint;
      default:
        return isDark ? AppTheme.darkPrimaryCoral : AppTheme.primaryLavender;
    }
  }

  String get _categoryLabel {
    switch (category) {
      case 'folktale':
        return '전통동화';
      case 'history':
        return '역사';
      case 'legend':
        return '전설';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with soft shadow and rounded corners
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                color: categoryColor.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or placeholder
                    _hasValidThumbnail
                        ? Image.network(
                            thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                ImagePlaceholder.story(
                              width: double.infinity,
                              height: double.infinity,
                              backgroundColor:
                                  categoryColor.withValues(alpha: 0.2),
                              iconColor: categoryColor,
                              borderRadius: 0,
                            ),
                          )
                        : ImagePlaceholder.story(
                            width: double.infinity,
                            height: double.infinity,
                            backgroundColor: categoryColor.withValues(alpha: 0.2),
                            iconColor: categoryColor,
                            borderRadius: 0,
                          ),
                    // Feature badges
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildFeatureBadges(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categoryLabel,
                style: AppTheme.caption(context).copyWith(
                  color: categoryColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              style: AppTheme.storyTitle(context).copyWith(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Age range + chapters
            Row(
              children: [
                Icon(
                  Icons.child_care_rounded,
                  size: 14,
                  color: AppTheme.textMutedColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '$ageMin-$ageMax세',
                  style: AppTheme.caption(context),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: AppTheme.textMutedColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalChapters화',
                  style: AppTheme.caption(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

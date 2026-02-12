import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
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
  final double? averageRating;
  final int reviewCount;
  final int viewCount;
  final VoidCallback? onTap;

  /// Optional width. When null (e.g. in horizontal list), uses 160.
  /// Set for grid layout to fill the cell.
  final double? width;

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
    this.averageRating,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.onTap,
    this.width,
  });

  bool get _hasValidThumbnail {
    if (thumbnailUrl == null) return false;
    if (thumbnailUrl!.isEmpty) return false;
    // Check if URL ends with just / (no filename)
    if (thumbnailUrl!.endsWith('/')) return false;
    return true;
  }

  /// Age icons: 1 = 5-6, 2 = 7-8, 3 = 9-10
  int get _ageIconCount {
    if (ageMax <= 6) return 1;
    if (ageMax <= 8) return 2;
    return 3;
  }

  /// Chapter icons: 1 = few (≤5), 2 = medium (6-15), 3 = many (16+)
  int get _chapterIconCount {
    if (totalChapters <= 5) return 1;
    if (totalChapters <= 15) return 2;
    return 3;
  }

  Widget _buildFeatureBadges() {
    return Wrap(
      spacing: 4,
      children: [
        if (isFeatured) _buildBadge(Icons.star_rounded, Colors.amber),
        if (hasAudio) _buildBadge(Icons.headphones_rounded, Colors.orange),
        if (hasQuiz) _buildBadge(Icons.quiz_rounded, Colors.green),
        if (hasIllustrations) _buildBadge(Icons.palette_rounded, Colors.purple),
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
      child: Icon(icon, size: 14, color: color),
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

  String _categoryLabel(BuildContext context) {
    switch (category) {
      case 'folktale':
        return context.l10n.categoryFolktale;
      case 'history':
        return context.l10n.categoryHistory;
      case 'legend':
        return context.l10n.categoryLegend;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context);

    final cardWidth = width ?? 160;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: width == null ? 12 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square thumbnail
            Container(
              width: cardWidth,
              height: cardWidth,
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
                                  backgroundColor: categoryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  iconColor: categoryColor,
                                  borderRadius: 0,
                                ),
                          )
                        : ImagePlaceholder.story(
                            width: double.infinity,
                            height: double.infinity,
                            backgroundColor: categoryColor.withValues(
                              alpha: 0.2,
                            ),
                            iconColor: categoryColor,
                            borderRadius: 0,
                          ),
                    // Feature badges
                    Positioned(top: 8, right: 8, child: _buildFeatureBadges()),
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
                _categoryLabel(context),
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
            // Age (icons) + chapters (icons) + audio badge
            Semantics(
              label: '${context.l10n.ageYearsFormat(ageMin, ageMax)}, ${context.l10n.episodesFormat(totalChapters)}${hasAudio ? ', ${context.l10n.audioStories}' : ''}',
              child: Row(
                children: [
                  ...List.generate(_ageIconCount, (_) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(Icons.child_care_rounded, size: 18, color: AppTheme.textMutedColor(context)),
                  )),
                  const SizedBox(width: 12),
                  ...List.generate(_chapterIconCount, (_) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(Icons.menu_book_rounded, size: 18, color: AppTheme.textMutedColor(context)),
                  )),
                  if (hasAudio) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.headphones_rounded, size: 18, color: Colors.orange.shade700),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

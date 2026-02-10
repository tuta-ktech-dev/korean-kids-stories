import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/story.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'story_detail_theme.dart';

class StoryDetailInfo extends StatelessWidget {
  final Story story;

  const StoryDetailInfo({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = StoryDetailTheme.of(context, story.category);
    final categoryLabel = _getCategoryLabel(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryBadge(color: theme.color, label: categoryLabel),
          const SizedBox(height: 12),
          Text(
            story.title,
            style: AppTheme.headingLarge(context),
          ),
          const SizedBox(height: 8),
          _StatsRow(story: story),
          const SizedBox(height: 16),
          if (story.summary.isNotEmpty)
            Text(story.summary, style: AppTheme.bodyMedium(context)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getCategoryLabel(BuildContext context) {
    switch (story.category) {
      case 'folktale':
        return context.l10n.categoryFolktale;
      case 'history':
        return context.l10n.categoryHistory;
      case 'legend':
        return context.l10n.categoryLegend;
      default:
        return story.category;
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _CategoryBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Story story;

  const _StatsRow({required this.story});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (story.averageRating != null) ...[
          Icon(Icons.star_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            story.averageRating!.toStringAsFixed(1),
            style: AppTheme.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text('(${story.reviewCount})', style: AppTheme.caption(context)),
          const SizedBox(width: 16),
        ],
        Icon(
          Icons.visibility_rounded,
          size: 16,
          color: AppTheme.textMutedColor(context),
        ),
        const SizedBox(width: 4),
        Text('${story.viewCount}', style: AppTheme.caption(context)),
        const SizedBox(width: 16),
        Icon(
          Icons.child_care_rounded,
          size: 16,
          color: AppTheme.textMutedColor(context),
        ),
        const SizedBox(width: 4),
        Text(
          '${story.ageMin}-${story.ageMax}세',
          style: AppTheme.caption(context),
        ),
      ],
    );
  }
}

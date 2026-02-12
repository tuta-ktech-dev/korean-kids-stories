import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/story.dart';
import '../../../components/image_placeholder.dart';
import 'story_detail_theme.dart';

class StoryDetailHeader extends StatelessWidget {
  final Story story;

  const StoryDetailHeader({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = StoryDetailTheme.of(context, story.category);

    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.width,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _StoryThumbnail(story: story, categoryColor: theme.color),
      ),
    );
  }
}

class _StoryThumbnail extends StatelessWidget {
  final Story story;
  final Color categoryColor;

  const _StoryThumbnail({
    required this.story,
    required this.categoryColor,
  });

  bool get _hasValidThumbnail {
    final url = story.thumbnailUrl;
    if (url == null || url.isEmpty || url.endsWith('/')) return false;
    return true;
  }

  /// Get optimized thumbnail URL for detail view
  /// Uses 600x600 for larger display while keeping size reasonable
  String? get _optimizedThumbnailUrl {
    if (!_hasValidThumbnail) return null;
    final separator = story.thumbnailUrl!.contains('?') ? '&' : '?';
    return '${story.thumbnailUrl}${separator}thumb=600x600';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: categoryColor.withValues(alpha: 0.2),
      child: _hasValidThumbnail
          ? CachedNetworkImage(
              imageUrl: _optimizedThumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              memCacheWidth: 600, // Optimize memory cache
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
          : ImagePlaceholder.story(
              width: double.infinity,
              height: double.infinity,
              backgroundColor: categoryColor.withValues(alpha: 0.2),
              iconColor: categoryColor,
            ),
    );
  }

  Widget _buildPlaceholder() {
    return ImagePlaceholder.story(
      width: double.infinity,
      height: double.infinity,
      backgroundColor: categoryColor.withValues(alpha: 0.2),
      iconColor: categoryColor,
    );
  }
}

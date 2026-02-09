import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/story.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../components/image_placeholder.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';

@RoutePage()
class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({
    super.key,
    @PathParam('id') required this.storyId,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  Story? _story;
  List<Map<String, dynamic>> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      final pbService = PocketbaseService();
      await pbService.initialize();

      // Load story and chapters in parallel
      final results = await Future.wait([
        pbService.getStory(widget.storyId),
        pbService.getChapters(widget.storyId),
      ]);

      setState(() {
        _story = results[0] as Story?;
        _chapters = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load story: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _story == null
                  ? _buildNotFound()
                  : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, style: AppTheme.bodyLarge(context)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStory,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 64, color: AppTheme.textMutedColor(context)),
          const SizedBox(height: 16),
          Text('이야기를 찾을 수 없어요', style: AppTheme.bodyLarge(context)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // App Bar with thumbnail
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildThumbnail(),
          ),
        ),

        // Story info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                _buildCategoryBadge(),
                const SizedBox(height: 12),

                // Title
                Text(
                  _story!.title,
                  style: AppTheme.headingLarge(context),
                ),
                const SizedBox(height: 8),

                // Rating and stats
                _buildStats(),
                const SizedBox(height: 16),

                // Summary
                Text(
                  _story!.summary,
                  style: AppTheme.bodyMedium(context),
                ),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(),
                const SizedBox(height: 32),

                // Chapters section
                Text(
                  '목차',
                  style: AppTheme.headingMedium(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Chapters list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildChapterItem(index),
            childCount: _chapters.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildThumbnail() {
    final categoryColor = _getCategoryColor();

    return Container(
      color: categoryColor.withOpacity(0.2),
      child: _story!.thumbnailUrl != null
          ? Image.network(
              _story!.thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : ImagePlaceholder.story(
              width: double.infinity,
              height: double.infinity,
              backgroundColor: categoryColor.withOpacity(0.2),
              iconColor: categoryColor,
            ),
    );
  }

  Widget _buildCategoryBadge() {
    final color = _getCategoryColor();
    final label = _getCategoryLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
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

  Widget _buildStats() {
    return Row(
      children: [
        // Rating
        if (_story!.averageRating != null) ...[
          Icon(Icons.star_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${_story!.averageRating!.toStringAsFixed(1)}',
            style: AppTheme.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Text(
            '(${_story!.reviewCount})',
            style: AppTheme.caption(context),
          ),
          const SizedBox(width: 16),
        ],

        // View count
        Icon(Icons.visibility_rounded, size: 16, color: AppTheme.textMutedColor(context)),
        const SizedBox(width: 4),
        Text(
          '${_story!.viewCount}',
          style: AppTheme.caption(context),
        ),
        const SizedBox(width: 16),

        // Age range
        Icon(Icons.child_care_rounded, size: 16, color: AppTheme.textMutedColor(context)),
        const SizedBox(width: 4),
        Text(
          '${_story!.ageMin}-${_story!.ageMax}세',
          style: AppTheme.caption(context),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Start reading button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _chapters.isNotEmpty
                ? () => _openReader(0)
                : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('시작하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Bookmark button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _toggleBookmark,
            icon: const Icon(Icons.bookmark_border),
            label: const Text('저장'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterItem(int index) {
    final chapter = _chapters[index];
    final isFree = chapter['is_free'] as bool? ?? true;
    final chapterNumber = chapter['chapter_number'] as int? ?? (index + 1);
    final title = chapter['title'] as String? ?? '제 $chapterNumber 화';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getCategoryColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$chapterNumber',
            style: AppTheme.bodyLarge(context).copyWith(
              fontWeight: FontWeight.bold,
              color: _getCategoryColor(),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: isFree
          ? Text('묣음', style: AppTheme.caption(context).copyWith(color: Colors.green))
          : Text('잠금', style: AppTheme.caption(context)),
      trailing: isFree
          ? Icon(Icons.play_circle_outline, color: AppTheme.primaryColor(context))
          : Icon(Icons.lock_outline, color: AppTheme.textMutedColor(context)),
      onTap: isFree ? () => _openReader(index) : null,
    );
  }

  Color _getCategoryColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_story?.category) {
      case 'folktale':
        return isDark ? AppTheme.darkPrimaryPink : AppTheme.primaryPink;
      case 'history':
        return isDark ? AppTheme.darkPrimarySky : AppTheme.primarySky;
      case 'legend':
        return isDark ? AppTheme.darkPrimaryMint : AppTheme.primaryMint;
      default:
        return isDark ? AppTheme.darkPrimaryCoral : AppTheme.primaryCoral;
    }
  }

  String _getCategoryLabel() {
    switch (_story?.category) {
      case 'folktale':
        return '전통동화';
      case 'history':
        return '역사';
      case 'legend':
        return '전설';
      default:
        return _story?.category ?? '';
    }
  }

  void _openReader(int chapterIndex) {
    // TODO: Navigate to reader screen
    context.router.pushNamed('/reader/${widget.storyId}/${_chapters[chapterIndex]['id']}');
  }

  void _toggleBookmark() {
    // TODO: Implement bookmark
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }
    // Add bookmark logic
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chapter.dart';
import '../../../data/models/story.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../components/image_placeholder.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class StoryDetailView extends StatefulWidget {
  final String storyId;

  const StoryDetailView({super.key, required this.storyId});

  @override
  State<StoryDetailView> createState() => _StoryDetailViewState();
}

class _StoryDetailViewState extends State<StoryDetailView> {
  Story? _story;
  List<Chapter> _chapters = [];
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
        _chapters = results[1] as List<Chapter>;
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
            child: Text(context.l10n.retry),
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
          Icon(
            Icons.book_outlined,
            size: 64,
            color: AppTheme.textMutedColor(context),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.storyNotFound, style: AppTheme.bodyLarge(context)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // App Bar with thumbnail
        SliverAppBar(
          expandedHeight: context.width,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(background: _buildThumbnail()),
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
                Text(_story!.title, style: AppTheme.headingLarge(context)),
                const SizedBox(height: 8),

                // Rating and stats
                _buildStats(),
                const SizedBox(height: 16),

                // Summary
                Text(_story!.summary, style: AppTheme.bodyMedium(context)),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(),
                const SizedBox(height: 32),

                // Chapters section
                Text(
                  context.l10n.tableOfContents,
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
      color: categoryColor.withValues(alpha: 0.2),
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
              backgroundColor: categoryColor.withValues(alpha: 0.2),
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.caption(
          context,
        ).copyWith(color: color, fontWeight: FontWeight.w600),
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
            _story!.averageRating!.toStringAsFixed(1),
            style: AppTheme.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Text('(${_story!.reviewCount})', style: AppTheme.caption(context)),
          const SizedBox(width: 16),
        ],

        // View count
        Icon(
          Icons.visibility_rounded,
          size: 16,
          color: AppTheme.textMutedColor(context),
        ),
        const SizedBox(width: 4),
        Text('${_story!.viewCount}', style: AppTheme.caption(context)),
        const SizedBox(width: 16),

        // Age range
        Icon(
          Icons.child_care_rounded,
          size: 16,
          color: AppTheme.textMutedColor(context),
        ),
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
            onPressed: _chapters.isNotEmpty ? () => _openReader(0) : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(context.l10n.startReading),
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
            label: Text(context.l10n.bookmark),
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
    final isFree = chapter.isFree;
    final chapterNumber = chapter.chapterNumber;
    final title = chapter.title.isNotEmpty
        ? chapter.title
        : context.l10n.chapterTitleFallback(chapterNumber);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getCategoryColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$chapterNumber',
            style: AppTheme.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: _getCategoryColor()),
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
          ? Text(
              context.l10n.free,
              style: AppTheme.caption(context).copyWith(color: Colors.green),
            )
          : Text(context.l10n.locked, style: AppTheme.caption(context)),
      trailing: isFree
          ? Icon(
              Icons.play_circle_outline,
              color: AppTheme.primaryColor(context),
            )
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
        return context.l10n.categoryFolktale;
      case 'history':
        return context.l10n.categoryHistory;
      case 'legend':
        return context.l10n.categoryLegend;
      default:
        return _story?.category ?? '';
    }
  }

  void _openReader(int chapterIndex) {
    // Navigate to reader screen
    context.router.root.pushNamed(
      '/reader/${widget.storyId}/${_chapters[chapterIndex].id}',
    );
  }

  void _toggleBookmark() {
    // TODO: Implement bookmark
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loginRequired)));
      return;
    }
    // Add bookmark logic
  }
}

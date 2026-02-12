import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/chapter.dart';
import '../../../data/models/story.dart';
import '../../cubits/story_detail_cubit/story_detail_cubit.dart';
import '../../widgets/responsive_padding.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'widgets/story_detail_bottom_bar.dart';
import 'widgets/story_detail_chapter_list.dart';
import 'widgets/story_detail_header.dart';
import 'widgets/story_detail_info.dart';

class StoryDetailView extends StatelessWidget {
  final String storyId;

  const StoryDetailView({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: ResponsivePadding(
        child: BlocBuilder<StoryDetailCubit, StoryDetailState>(
          builder: (context, state) {
          return switch (state) {
            StoryDetailLoading() => const _LoadingView(),
            StoryDetailError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context.read<StoryDetailCubit>().refresh(),
              ),
            StoryDetailNotFound() => _NotFoundView(),
            StoryDetailLoaded(:final story, :final chapters) => _ContentView(
                story: story,
                chapters: chapters,
                onRefresh: () => context.read<StoryDetailCubit>().refresh(),
              ),
            _ => const SizedBox.shrink(),
          };
        },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              context.l10n.loadStoryError,
              style: AppTheme.bodyLarge(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.checkConnection,
              style: AppTheme.caption(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text(
            context.l10n.storyNotFound,
            style: AppTheme.bodyLarge(context),
          ),
        ],
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final Story story;
  final List<Chapter> chapters;
  final VoidCallback onRefresh;

  const _ContentView({
    required this.story,
    required this.chapters,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                StoryDetailHeader(story: story),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StoryDetailInfo(story: story),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.tableOfContents,
                          style: AppTheme.headingMedium(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                StoryDetailChapterList(story: story, chapters: chapters),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
        StoryDetailBottomBar(story: story, chapters: chapters),
      ],
    );
  }
}

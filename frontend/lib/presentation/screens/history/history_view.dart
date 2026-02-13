import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cards/history_card.dart';
import '../../cubits/history_cubit/history_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    // Load history when entering screen
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.historyTitle,
          style: AppTheme.headingMedium(context),
        ),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HistoryCubit>().refresh(),
          ),
        ],
      ),
      body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: AppTheme.primaryColor(context),
                  unselectedLabelColor: AppTheme.textMutedColor(context),
                  indicatorColor: AppTheme.primaryColor(context),
                  tabs: [
                    Tab(
                      text: context.l10n.readingHistory,
                      icon: const Icon(Icons.menu_book),
                    ),
                    Tab(
                      text: context.l10n.completedChapters,
                      icon: const Icon(Icons.check_circle),
                    ),
                  ],
                ),
                Expanded(
                  child: BlocBuilder<HistoryCubit, HistoryState>(
                    builder: (context, state) {
                      if (state is HistoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is HistoryError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.l10n.historyLoadError,
                                style: AppTheme.bodyLarge(context),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<HistoryCubit>().refresh(),
                                child: Text(context.l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is HistoryLoaded) {
                        return TabBarView(
                          children: [
                            _ReadingHistoryTab(items: state.inProgressItems),
                            _CompletedStoriesTab(items: state.completedItems),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _ReadingHistoryTab extends StatelessWidget {
  final List<dynamic> items;

  const _ReadingHistoryTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.menu_book_outlined,
        title: context.l10n.noReadingHistoryYet,
        subtitle: context.l10n.startReadingStories,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return HistoryCard(
          title: item.story.title,
          subtitle: _formatHistorySubtitle(context, item),
          icon: Icons.menu_book,
          color: _getColorForIndex(index),
          timeAgo: _formatTimeAgo(context, item.lastReadAt),
          onTap: () {
            context.router.pushNamed(
              '/reader/${item.story.id}/${item.chapter?.id ?? ""}',
            );
          },
        );
      },
    );
  }

}

class _CompletedStoriesTab extends StatelessWidget {
  final List<dynamic> items;

  const _CompletedStoriesTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.check_circle_outline,
        title: context.l10n.noCompletedChaptersYet,
        subtitle: context.l10n.completeChapterHint,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return HistoryCard(
          title: item.story.title,
          subtitle: _formatHistorySubtitle(context, item),
          icon: Icons.check_circle,
          color: AppTheme.primaryMint,
          timeAgo: _formatTimeAgo(context, item.lastReadAt),
          onTap: () {
            context.router.pushNamed('/story/${item.story.id}');
          },
        );
      },
    );
  }

}

String _formatHistorySubtitle(BuildContext context, dynamic item) {
  final l10n = context.l10n;
  final percent = item.isCompleted ? 100 : item.percentRead.toInt();
  final percentStr = l10n.historyPercentComplete(percent);
  if (item.chapter != null) {
    return '${item.chapter!.title} • $percentStr';
  }
  return percentStr;
}

String _formatTimeAgo(BuildContext context, DateTime? lastReadAt) {
  if (lastReadAt == null) return '';
  final l10n = context.l10n;
  final diff = DateTime.now().difference(lastReadAt);

  if (diff.inMinutes < 60) {
    return l10n.timeAgoMinutes(diff.inMinutes);
  } else if (diff.inHours < 24) {
    return l10n.timeAgoHours(diff.inHours);
  } else if (diff.inDays < 7) {
    return l10n.timeAgoDays(diff.inDays);
  } else if (diff.inDays < 30) {
    return l10n.timeAgoWeeks((diff.inDays / 7).floor());
  } else {
    return l10n.timeAgoMonths((diff.inDays / 30).floor());
  }
}

Widget _buildEmptyState(
  BuildContext context, {
  IconData? icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/empty_reading_history.webp',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTheme.headingMedium(context)),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTheme.bodyMedium(context)
              .copyWith(color: AppTheme.textMutedColor(context)),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Color _getColorForIndex(int index) {
  final colors = [
    AppTheme.primaryPink,
    AppTheme.primaryMint,
    AppTheme.primarySky,
    AppTheme.primaryLavender,
    AppTheme.primaryCoral,
  ];
  return colors[index % colors.length];
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../components/cards/history_card.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is Unauthenticated || authState is AuthInitial) {
            return _buildGuestPrompt(context);
          }

          // Show history tabs for authenticated users
          return DefaultTabController(
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
                      text: context.l10n.completedStories,
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
                                'Error loading history',
                                style: AppTheme.bodyLarge(context),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<HistoryCubit>().refresh(),
                                child: const Text('Retry'),
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
          );
        },
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.textMutedColor(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 48,
                color: AppTheme.textMutedColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.loginRequired,
              style: AppTheme.headingMedium(context),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.historyLoginPrompt,
              style: AppTheme.bodyLarge(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.router.pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(context.l10n.loginAction),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.router.pushNamed('/register');
              },
              child: Text(
                context.l10n.signUp,
                style: AppTheme.bodyLarge(
                  context,
                ).copyWith(color: AppTheme.primaryColor(context)),
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
        title: 'No reading history yet',
        subtitle: 'Start reading some stories!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return HistoryCard(
          title: item.story.title,
          subtitle: item.displaySubtitle,
          icon: Icons.menu_book,
          color: _getColorForIndex(index),
          timeAgo: item.timeAgo,
          onTap: () {
            // Navigate to reader
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
        title: 'No completed stories yet',
        subtitle: 'Complete a story to see it here!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return HistoryCard(
          title: item.story.title,
          subtitle: item.displaySubtitle,
          icon: Icons.check_circle,
          color: AppTheme.primaryMint,
          timeAgo: item.timeAgo,
          onTap: () {
            context.router.pushNamed('/story/${item.story.id}');
          },
        );
      },
    );
  }
}

Widget _buildEmptyState(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppTheme.textMutedColor(context)),
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

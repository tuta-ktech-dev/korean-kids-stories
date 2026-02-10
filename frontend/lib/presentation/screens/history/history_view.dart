import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../components/cards/history_card.dart';

import '../../cubits/auth_cubit/auth_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

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
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Unauthenticated || state is AuthInitial) {
            return _buildGuestPrompt(context);
          }

          // Show history tabs for authenticated users
          return DefaultTabController(
            length: 3,
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
                      text: context.l10n.listeningHistory,
                      icon: const Icon(Icons.headphones),
                    ),
                    Tab(
                      text: context.l10n.searchHistory,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ReadingHistoryTab(),
                      _ListeningHistoryTab(),
                      _SearchHistoryTab(),
                    ],
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        HistoryCard(
          title: '흥부와 놀부',
          subtitle: '제1화 • 85% 완료',
          icon: Icons.menu_book,
          color: AppTheme.primaryPink,
          timeAgo: '2시간 전',
        ),
        HistoryCard(
          title: '선녀와 나무꾼',
          subtitle: '제3화 • 100% 완료',
          icon: Icons.check_circle,
          color: AppTheme.primaryMint,
          timeAgo: '어제',
        ),
        HistoryCard(
          title: '세종대왕 이야기',
          subtitle: '제2화 • 45% 완료',
          icon: Icons.menu_book,
          color: AppTheme.primarySky,
          timeAgo: '3일 전',
        ),
      ],
    );
  }
}

class _ListeningHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const HistoryCard(
          title: '흥부와 놀부',
          subtitle: '제1화 • 5분 30초 청취',
          icon: Icons.headphones,
          color: AppTheme.primaryPink,
          timeAgo: '2시간 전',
        ),
        _ListeningStatsCard(),
      ],
    );
  }
}

class _SearchHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        HistoryCard(
          title: '"전통동화"',
          subtitle: '카테고리 검색 • 12개 결과',
          icon: Icons.search,
          color: AppTheme.primaryCoral,
          timeAgo: '1시간 전',
        ),
        HistoryCard(
          title: '"흥부"',
          subtitle: '일반 검색 • 3개 결과',
          icon: Icons.search,
          color: AppTheme.primaryCoral,
          timeAgo: '2일 전',
        ),
      ],
    );
  }
}

class _ListeningStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryMint.withValues(alpha: 0.3),
            AppTheme.primarySky.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.weeklyStats,
            style: AppTheme.headingMedium(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: context.l10n.totalListening, value: '2시간 15분'),
              _StatItem(label: context.l10n.completedStories, value: '3개'),
              _StatItem(label: context.l10n.currentStreak, value: '5일'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headingMedium(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption(context)),
      ],
    );
  }
}

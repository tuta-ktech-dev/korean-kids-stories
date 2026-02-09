import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        appBar: AppBar(
          title: Text('내 활동', style: AppTheme.headingMedium(context)),
          backgroundColor: AppTheme.backgroundColor(context),
          elevation: 0,
          bottom: TabBar(
            labelColor: AppTheme.primaryColor(context),
            unselectedLabelColor: AppTheme.textMutedColor(context),
            indicatorColor: AppTheme.primaryColor(context),
            tabs: const [
              Tab(text: '읽은 이야기', icon: Icon(Icons.menu_book)),
              Tab(text: '들은 내용', icon: Icon(Icons.headphones)),
              Tab(text: '검색 기록', icon: Icon(Icons.search)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReadingHistoryTab(context: context),
            _ListeningHistoryTab(context: context),
            _SearchHistoryTab(context: context),
          ],
        ),
      ),
    );
  }
}

class _ReadingHistoryTab extends StatelessWidget {
  final BuildContext context;
  const _ReadingHistoryTab({required this.context});

  @override
  Widget build(BuildContext context) {
    // TODO: Load from reading_history collection
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HistoryCard(
          title: '흥부와 놀부',
          subtitle: '제1화 • 85% 완료',
          icon: Icons.menu_book,
          color: AppTheme.primaryPink,
          timeAgo: '2시간 전',
          context: context,
        ),
        _HistoryCard(
          title: '선녀와 나무꾼',
          subtitle: '제3화 • 100% 완료',
          icon: Icons.check_circle,
          color: AppTheme.primaryMint,
          timeAgo: '어제',
          context: context,
        ),
        _HistoryCard(
          title: '세종대왕 이야기',
          subtitle: '제2화 • 45% 완료',
          icon: Icons.menu_book,
          color: AppTheme.primarySky,
          timeAgo: '3일 전',
          context: context,
        ),
      ],
    );
  }
}

class _ListeningHistoryTab extends StatelessWidget {
  final BuildContext context;
  const _ListeningHistoryTab({required this.context});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HistoryCard(
          title: '흥부와 놀부',
          subtitle: '제1화 • 5분 30초 청취',
          icon: Icons.headphones,
          color: AppTheme.primaryPink,
          timeAgo: '2시간 전',
          context: context,
        ),
        _ListeningStatsCard(context: context),
      ],
    );
  }
}

class _SearchHistoryTab extends StatelessWidget {
  final BuildContext context;
  const _SearchHistoryTab({required this.context});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HistoryCard(
          title: '"전통동화"',
          subtitle: '카테고리 검색 • 12개 결과',
          icon: Icons.search,
          color: AppTheme.primaryCoral,
          timeAgo: '1시간 전',
          context: context,
        ),
        _HistoryCard(
          title: '"흥부"',
          subtitle: '일반 검색 • 3개 결과',
          icon: Icons.search,
          color: AppTheme.primaryCoral,
          timeAgo: '2일 전',
          context: context,
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String timeAgo;
  final BuildContext context;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.timeAgo,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTheme.bodyMedium(context)),
              ],
            ),
          ),
          Text(timeAgo, style: AppTheme.caption(context)),
        ],
      ),
    );
  }
}

class _ListeningStatsCard extends StatelessWidget {
  final BuildContext context;
  const _ListeningStatsCard({required this.context});

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
          Text('이번 주 통계', style: AppTheme.headingMedium(context).copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: '총 청취', value: '2시간 15분', context: context),
              _StatItem(label: '완료한 이야기', value: '3개', context: context),
              _StatItem(label: '연속 학습', value: '5일', context: context),
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
  final BuildContext context;

  const _StatItem({required this.label, required this.value, required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.headingMedium(context).copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption(context)),
      ],
    );
  }
}

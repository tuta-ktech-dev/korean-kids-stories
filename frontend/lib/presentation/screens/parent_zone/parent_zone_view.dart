import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../../core/notification/notification_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../injection.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../components/buttons/settings_item.dart';
import '../../components/cards/settings_section.dart';
import '../../cubits/history_cubit/history_cubit.dart';
import '../../cubits/parent_zone_cubit/parent_zone_cubit.dart';
import '../../cubits/parent_zone_cubit/parent_zone_state.dart';
import '../../cubits/settings_cubit/settings_cubit.dart';
import '../../widgets/report_bottom_sheet.dart';

class ParentZoneView extends StatelessWidget {
  const ParentZoneView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentZoneCubit()..loadAuthStatus(),
      child: const _ParentZoneContent(),
    );
  }
}

class _ParentZoneContent extends StatelessWidget {
  const _ParentZoneContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.parentZone,
          style: AppTheme.headingMedium(context),
        ),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
      ),
      body: BlocBuilder<ParentZoneCubit, ParentZoneState>(
        builder: (context, state) {
          if (state is ParentZoneAuthRequired || state is ParentZoneAuthFailed) {
            return _AuthPrompt(
              onAuthenticate: () => context.read<ParentZoneCubit>().authenticate(
                    context.l10n.parentZoneAuthReason,
                  ),
              error: state is ParentZoneAuthFailed ? state.message : null,
            );
          }
          if (state is ParentZoneNotSupported) {
            return _NotSupportedPrompt();
          }
          if (state is ParentZoneUnlocked) {
            return _ParentZoneContentBody();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _AuthPrompt extends StatelessWidget {
  final VoidCallback onAuthenticate;
  final String? error;

  const _AuthPrompt({
    required this.onAuthenticate,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fingerprint,
            size: 80,
            color: AppTheme.primaryColor(context),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.parentZone,
            style: AppTheme.headingMedium(context),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.parentZoneSubtitle,
            style: AppTheme.bodyMedium(context).copyWith(
              color: AppTheme.textMutedColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error!.length > 80 ? context.l10n.parentZoneAuthFailed : error!,
              style: AppTheme.caption(context).copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAuthenticate,
              icon: const Icon(Icons.security),
              label: Text(context.l10n.parentZoneAuthenticate),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotSupportedPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phonelink_erase,
              size: 64,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.parentZoneNotSupported,
              style: AppTheme.bodyLarge(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentZoneContentBody extends StatelessWidget {
  const _ParentZoneContentBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Parent Zone features
        _ParentZoneItem(
          icon: Icons.history,
          title: context.l10n.parentZoneChildActivity,
          subtitle: context.l10n.recentActivity,
          onTap: () => _ParentZoneHelpers.showActivitySheet(context),
        ),
        const SizedBox(height: 16),
        _ParentZoneItem(
          icon: Icons.workspace_premium,
          title: context.l10n.parentZonePremium,
          subtitle: context.l10n.parentZoneComingSoon,
          onTap: () {},
        ),
        const SizedBox(height: 24),

        // Report & Support
        SettingsSection(
          title: context.l10n.reportAndSupport,
          children: [
            SettingsItem(
              icon: Icons.report_problem_outlined,
              title: context.l10n.reportAppIssue,
              iconColor: Colors.orange,
              onTap: () => showReportSheet(
                context,
                type: ReportType.app,
                targetId: 'app',
                targetTitle: 'Korean Kids Tales App',
              ),
            ),
            SettingsItem(
              icon: Icons.help_outline,
              title: context.l10n.contactUs,
              onTap: () => _ParentZoneHelpers.showContactSheet(context),
            ),
            SettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: context.l10n.privacyPolicy,
              onTap: () => context.router.push(ContentRouteRoute(slug: 'privacy')),
            ),
            SettingsItem(
              icon: Icons.description_outlined,
              title: context.l10n.termsOfService,
              onTap: () => context.router.push(ContentRouteRoute(slug: 'terms')),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Reading (Parent control)
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final cps = settingsState is SettingsLoaded
                ? settingsState.minCharsPerSecond
                : SettingsCubit.defaultMinCharsPerSecond;
            return SettingsSection(
              title: context.l10n.minNextChapterTime,
              children: [
                SettingsItem(
                  icon: Icons.timer_outlined,
                  title: context.l10n.minNextChapterTime,
                  trailing: Text(
                    cps == 0
                        ? context.l10n.minNextChapterTimeOff
                        : context.l10n.minNextChapterTimeCharsPerSecond(cps),
                    style: AppTheme.bodyMedium(context),
                  ),
                  onTap: () =>
                      _ParentZoneHelpers.showMinNextChapterDialog(context),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Daily reading goal
        _DailyGoalSection(),
        const SizedBox(height: 24),

        // Daily reminder (no streak)
        _ReminderSection(),
        const SizedBox(height: 24),

        // App Info
        SettingsSection(
          title: context.l10n.appInfo,
          children: [
            SettingsItem(
              icon: Icons.language,
              title: context.l10n.language,
              trailing: Text(
                _ParentZoneHelpers.getLanguageName(context),
                style: AppTheme.bodyMedium(context),
              ),
              onTap: () => _ParentZoneHelpers.showLanguageDialog(context),
            ),
            SettingsItem(
              icon: Icons.info_outline,
              title: context.l10n.version,
              trailing: Text(
                '1.0.0',
                style: AppTheme.bodyMedium(context),
              ),
            ),
            SettingsItem(
              icon: Icons.star_outline,
              title: context.l10n.rateApp,
              onTap: () => _ParentZoneHelpers.openStore(context),
            ),
            SettingsItem(
              icon: Icons.share_outlined,
              title: context.l10n.shareApp,
              onTap: () => _ParentZoneHelpers.shareApp(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper methods for Parent Zone settings (moved from SettingsView)
class _ParentZoneHelpers {
  /// Chars per second: 0=off, higher=must read faster (stricter)
  static const List<int> _minCharsPerSecondOptions = [0, 5, 8, 10, 15, 20];

  static Future<void> showReminderDialog(BuildContext context) async {
    final enabled = await NotificationService.isReminderEnabled();
    final hour = await NotificationService.getReminderHour();
    final minute = await NotificationService.getReminderMinute();

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => _ReminderDialog(
        initialEnabled: enabled,
        initialHour: hour,
        initialMinute: minute,
        onSave: (en, h, m) async {
          await NotificationService.setReminderEnabled(en);
          await NotificationService.setReminderTime(h, m);
        },
      ),
    );
  }

  static void showActivitySheet(BuildContext context) {
    context.read<HistoryCubit>().loadHistory();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(ctx),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMutedColor(ctx).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  ctx.l10n.recentActivity,
                  style: AppTheme.headingMedium(ctx),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (ctx, state) {
                    if (state is HistoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is HistoryError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTheme.bodyMedium(ctx),
                        ),
                      );
                    }
                    if (state is! HistoryLoaded) {
                      return const SizedBox.shrink();
                    }
                    final items = state.inProgressItems + state.completedItems;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          ctx.l10n.activityEmpty,
                          style: AppTheme.bodyMedium(ctx).copyWith(
                            color: AppTheme.textMutedColor(ctx),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final sub = item.chapter != null
                            ? '${item.chapter!.title} • ${item.percentRead.toInt()}%'
                            : '${item.percentRead.toInt()}%';
                        final dur = item.durationSeconds > 0
                            ? ctx.l10n.durationMinutes(
                                (item.durationSeconds / 60).ceil())
                            : '';
                        return ListTile(
                          title: Text(item.story.title),
                          subtitle: Text('$sub${dur.isNotEmpty ? ' • $dur' : ''}'),
                          trailing: Text(
                            _formatTimeAgo(ctx, item.lastReadAt),
                            style: AppTheme.caption(ctx),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            ctx.router.pushNamed(
                              item.isCompleted
                                  ? '/story/${item.story.id}'
                                  : '/reader/${item.story.id}/${item.chapter?.id ?? ''}',
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTimeAgo(BuildContext context, DateTime? lastReadAt) {
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

  static void showMinNextChapterDialog(BuildContext context) {
    final settings = context.read<SettingsCubit>().state;
    final current = settings is SettingsLoaded
        ? settings.minCharsPerSecond
        : SettingsCubit.defaultMinCharsPerSecond;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.minNextChapterTime),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _minCharsPerSecondOptions.map((cps) {
            return ListTile(
              title: Text(
                cps == 0
                    ? ctx.l10n.minNextChapterTimeOff
                    : ctx.l10n.minNextChapterTimeCharsPerSecond(cps),
              ),
              trailing: current == cps ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                context.read<SettingsCubit>().setMinCharsPerSecond(cps);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  static void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(ctx, '한국어', const Locale('ko')),
            _buildLanguageOption(ctx, 'English', const Locale('en')),
            _buildLanguageOption(ctx, 'Tiếng Việt', const Locale('vi')),
          ],
        ),
      ),
    );
  }

  static Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
  ) {
    return ListTile(
      title: Text(label),
      onTap: () {
        context.read<SettingsCubit>().setLocale(locale);
        Navigator.pop(context);
      },
      trailing:
          Localizations.localeOf(context).languageCode == locale.languageCode
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
    );
  }

  static String getLanguageName(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return '한국어';
    }
  }

  static Future<void> showContactSheet(BuildContext context) async {
    final config = await getIt<AppConfigRepository>().getAll();
    final address = config['contact_address'] ?? '';
    final phone = config['contact_phone'] ?? '';
    final email = config['contact_email'] ?? '';
    final facebook = config['facebook_url'] ?? '';
    final naver = config['naver_url'] ?? '';

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(ctx),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMutedColor(ctx).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.contactUs,
                style: AppTheme.headingMedium(ctx),
              ),
              const SizedBox(height: 16),
              if (address.isNotEmpty)
                _ContactRow(
                  icon: Icons.location_on_outlined,
                  text: address,
                ),
              if (phone.isNotEmpty)
                _ContactRow(
                  icon: Icons.phone_outlined,
                  text: phone,
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                ),
              if (email.isNotEmpty)
                _ContactRow(
                  icon: Icons.email_outlined,
                  text: email,
                  onTap: () => launchUrl(Uri(scheme: 'mailto', path: email)),
                ),
              if (facebook.isNotEmpty)
                _ContactRow(
                  icon: Icons.facebook,
                  text: 'Facebook',
                  onTap: () => launchUrl(Uri.parse(facebook)),
                ),
              if (naver.isNotEmpty)
                _ContactRow(
                  icon: Icons.link,
                  text: 'Naver',
                  onTap: () => launchUrl(Uri.parse(naver)),
                ),
              if (address.isEmpty &&
                  phone.isEmpty &&
                  email.isEmpty &&
                  facebook.isEmpty &&
                  naver.isEmpty)
                Text(
                  'No contact info configured',
                  style: AppTheme.bodyMedium(ctx).copyWith(
                    color: AppTheme.textMutedColor(ctx),
                  ),
                ),
            ],
          ),
        ),
    );
  }

  static Future<void> openStore(BuildContext context) async {
    final config = await getIt<AppConfigRepository>().getAll();
    final playStore = config['play_store_url'];
    final appStore = config['app_store_url'];
    final urlStr = (playStore != null && playStore.isNotEmpty)
        ? playStore
        : (appStore != null && appStore.isNotEmpty)
            ? appStore
            : 'https://play.google.com/store/apps';
    final url = Uri.tryParse(urlStr);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> shareApp(BuildContext context) async {
    await Share.share(
      'Check out Korean Kids Tales - 꼬마 한동화!\nhttps://play.google.com/store/apps',
      subject: 'Korean Kids Tales',
    );
  }
}

class _DailyGoalSection extends StatelessWidget {
  const _DailyGoalSection();

  static const List<int> _storyOptions = [0, 1, 2, 3];
  static const List<int> _chapterOptions = [0, 3, 5, 10];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final goalStories =
            settingsState is SettingsLoaded ? settingsState.dailyGoalStories : 0;
        final goalChapters =
            settingsState is SettingsLoaded ? settingsState.dailyGoalChapters : 0;
        return SettingsSection(
          title: context.l10n.dailyGoal,
          children: [
            SettingsItem(
              icon: Icons.menu_book_outlined,
              title: context.l10n.dailyGoalStories,
              trailing: FutureBuilder<int>(
                future: getIt<ProgressRepository>().getStoriesReadToday(),
                builder: (_, snap) {
                  final current = snap.data ?? 0;
                  return Text(
                    goalStories == 0
                        ? context.l10n.dailyGoalOff
                        : context.l10n.dailyGoalFormat(
                            current.toString(),
                            goalStories.toString(),
                          ),
                    style: AppTheme.bodyMedium(context),
                  );
                },
              ),
              onTap: () => _showDailyGoalStoriesDialog(context),
            ),
            SettingsItem(
              icon: Icons.collections_bookmark_outlined,
              title: context.l10n.dailyGoalChapters,
              trailing: FutureBuilder<int>(
                future: getIt<ProgressRepository>().getChaptersReadToday(),
                builder: (_, snap) {
                  final current = snap.data ?? 0;
                  return Text(
                    goalChapters == 0
                        ? context.l10n.dailyGoalOff
                        : context.l10n.dailyGoalFormat(
                            current.toString(),
                            goalChapters.toString(),
                          ),
                    style: AppTheme.bodyMedium(context),
                  );
                },
              ),
              onTap: () => _showDailyGoalChaptersDialog(context),
            ),
          ],
        );
      },
    );
  }

  static void _showDailyGoalStoriesDialog(BuildContext context) {
    final settings = context.read<SettingsCubit>().state;
    final current = settings is SettingsLoaded
        ? settings.dailyGoalStories
        : 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.dailyGoalStories),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(ctx.l10n.dailyGoalOff),
              trailing: current == 0 ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                context.read<SettingsCubit>().setDailyGoalStories(0);
                Navigator.pop(ctx);
              },
            ),
            ..._storyOptions.where((v) => v > 0).map((v) {
              return ListTile(
                title: Text('$v'),
                trailing: current == v ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  context.read<SettingsCubit>().setDailyGoalStories(v);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  static void _showDailyGoalChaptersDialog(BuildContext context) {
    final settings = context.read<SettingsCubit>().state;
    final current = settings is SettingsLoaded
        ? settings.dailyGoalChapters
        : 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.dailyGoalChapters),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(ctx.l10n.dailyGoalOff),
              trailing: current == 0 ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                context.read<SettingsCubit>().setDailyGoalChapters(0);
                Navigator.pop(ctx);
              },
            ),
            ..._chapterOptions.where((v) => v > 0).map((v) {
              return ListTile(
                title: Text('$v'),
                trailing: current == v ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  context.read<SettingsCubit>().setDailyGoalChapters(v);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ReminderSection extends StatefulWidget {
  const _ReminderSection();

  @override
  State<_ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<_ReminderSection> {
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: context.l10n.reminderStreak,
      children: [
        SettingsItem(
          icon: Icons.notifications_outlined,
          title: context.l10n.reminderStreak,
          trailing: FutureBuilder<bool>(
            key: ValueKey(_refreshKey),
            future: NotificationService.isReminderEnabled(),
            builder: (ctx, snap) {
              return Text(
                snap.data == true
                    ? context.l10n.reminderOn
                    : context.l10n.reminderOff,
                style: AppTheme.bodyMedium(context),
              );
            },
          ),
          onTap: () async {
            await _ParentZoneHelpers.showReminderDialog(context);
            if (mounted) setState(() => _refreshKey++);
          },
        ),
      ],
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  final bool initialEnabled;
  final int initialHour;
  final int initialMinute;
  final Future<void> Function(bool enabled, int hour, int minute) onSave;

  const _ReminderDialog({
    required this.initialEnabled,
    required this.initialHour,
    required this.initialMinute,
    required this.onSave,
  });

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late bool _enabled;
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.reminderStreak),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.reminderStreakDesc,
            style: AppTheme.bodyMedium(context).copyWith(
              color: AppTheme.textMutedColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(context.l10n.reminderStreak)),
              Switch(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
            ],
          ),
          if (_enabled) ...[
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.l10n.reminderTime),
              subtitle: Text(
                '$_hour:${_minute.toString().padLeft(2, '0')}',
                style: AppTheme.bodyLarge(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: _hour, minute: _minute),
                );
                if (picked != null) {
                  setState(() {
                    _hour = picked.hour;
                    _minute = picked.minute;
                  });
                }
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.onSave(_enabled, _hour, _minute);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(context.l10n.continueAction),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTheme.bodyMedium(context)),
          ),
        ],
      ),
    );
    return onTap != null
        ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: child)
        : child;
  }
}

class _ParentZoneItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ParentZoneItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor(context).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor(context)),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.caption(context),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

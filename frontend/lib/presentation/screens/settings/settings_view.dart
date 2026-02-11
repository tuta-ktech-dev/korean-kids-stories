import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../injection.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../components/buttons/settings_item.dart';
import '../../components/cards/settings_section.dart';
import '../../cubits/settings_cubit/settings_cubit.dart';
import '../../widgets/report_bottom_sheet.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.settingsTitle,
          style: AppTheme.headingMedium(context),
        ),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Parent Zone - for parents only (PIN protected)
          SettingsSection(
            title: context.l10n.parentZone,
            children: [
              SettingsItem(
                icon: Icons.family_restroom,
                title: context.l10n.parentZone,
                iconColor: AppTheme.primaryColor(context),
                textColor: AppTheme.primaryColor(context),
                onTap: () => context.router.push(const ParentZoneRoute()),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Report Section
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
                    onTap: () => _showContactSheet(context),
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

          // App Section
          SettingsSection(
                title: context.l10n.appInfo,
                children: [
                  SettingsItem(
                    icon: Icons.language,
                    title: context.l10n.language,
                    trailing: Text(
                      _getLanguageName(context),
                      style: AppTheme.bodyMedium(context),
                    ),
                    onTap: () => _showLanguageDialog(context),
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
                    onTap: () => _openStore(context),
                  ),
                  SettingsItem(
                    icon: Icons.share_outlined,
                    title: context.l10n.shareApp,
                    onTap: () => _shareApp(context),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, '한국어', const Locale('ko')),
            _buildLanguageOption(context, 'English', const Locale('en')),
            _buildLanguageOption(context, 'Tiếng Việt', const Locale('vi')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
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

  Future<void> _showContactSheet(BuildContext context) async {
    final config = await getIt<AppConfigRepository>().getAll();
    final address = config['contact_address'] ?? '';
    final phone = config['contact_phone'] ?? '';
    final email = config['contact_email'] ?? '';
    final facebook = config['facebook_url'] ?? '';
    final naver = config['naver_url'] ?? '';

    if (context.mounted) {
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
                  onTap: null,
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
  }

  Future<void> _openStore(BuildContext context) async {
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

  Future<void> _shareApp(BuildContext context) async {
    await Share.share(
      'Check out Korean Kids Tales - 꼬마 한동화!\nhttps://play.google.com/store/apps',
      subject: 'Korean Kids Tales',
    );
  }

  String _getLanguageName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
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
            child: Text(
              text,
              style: AppTheme.bodyMedium(context),
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: child);
    }
    return child;
  }
}

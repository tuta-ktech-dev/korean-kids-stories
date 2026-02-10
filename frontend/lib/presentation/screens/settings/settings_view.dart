import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import '../../../data/repositories/app_config_repository.dart';
import '../../components/buttons/settings_item.dart';
import '../../components/cards/settings_section.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state is Authenticated;
          final isGuest = state is Unauthenticated;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // User Profile Card
              _buildUserCard(context, state),
              const SizedBox(height: 24),

              // Account Section
              if (isAuthenticated) ...[
                SettingsSection(
                  title: context.l10n.accountSection,
                  children: [
                    SettingsItem(
                      icon: Icons.person_outline,
                      title: context.l10n.editProfile,
                      onTap: () => context.router.pushNamed('/profile'),
                    ),
                    SettingsItem(
                      icon: Icons.lock_outline,
                      title: context.l10n.changePassword,
                      onTap: () => context.router.pushNamed('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Guest section - show login button
              if (isGuest) ...[
                SettingsSection(
                  title: context.l10n.login,
                  children: [
                    SettingsItem(
                      icon: Icons.login,
                      title: context.l10n.loginAction,
                      iconColor: AppTheme.primaryColor(context),
                      textColor: AppTheme.primaryColor(context),
                      onTap: () => context.router.pushNamed('/login'),
                    ),
                    SettingsItem(
                      icon: Icons.person_add_outlined,
                      title: context.l10n.signUp,
                      onTap: () => context.router.pushNamed('/register'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

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

              const SizedBox(height: 24),

              // Danger Zone - only for authenticated users
              if (isAuthenticated) ...[
                SettingsSection(
                  title: context.l10n.dangerZone,
                  children: [
                    SettingsItem(
                      icon: Icons.logout,
                      title: context.l10n.logout,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () => _showLogoutDialog(context),
                    ),
                    SettingsItem(
                      icon: Icons.delete_forever,
                      title: context.l10n.deleteAccount,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    final record = getIt<PocketbaseService>().currentUser;
    String? avatarUrl;
    if (record != null) {
      final raw = record.data['avatar'];
      if (raw != null) {
        final avatar = raw is List && raw.isNotEmpty
            ? raw.first.toString()
            : raw.toString();
        if (avatar.isNotEmpty) {
          avatarUrl = '${AppConfig.baseUrl}/api/files/users/${record.id}/$avatar';
        }
      }
    }
    return SizedBox(
      width: size,
      height: size,
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        backgroundImage:
            avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white, size: 32)
            : null,
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      return GestureDetector(
        onTap: () => context.router.pushNamed('/profile'),
        child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPink.withValues(alpha: 0.8),
              AppTheme.primaryCoral.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _buildAvatar(context, 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.userName ?? context.l10n.defaultUser,
                    style: AppTheme.headingMedium(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.email ?? '',
                    style: AppTheme.bodyMedium(
                      context,
                    ).copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      );
    } else {
      // Guest card
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.textMutedColor(context).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.textMutedColor(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: AppTheme.textMutedColor(context),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.guest,
                    style: AppTheme.headingMedium(
                      context,
                    ).copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.guestSubtitle,
                    style: AppTheme.bodyMedium(
                      context,
                    ).copyWith(color: AppTheme.textMutedColor(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: context.l10n.logout,
      content: context.l10n.logoutConfirmation,
      confirmText: context.l10n.logout,
      onConfirm: () {
        context.read<AuthCubit>().logout();
        context.router.replaceNamed('/');
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              context.l10n.deleteAccount,
              style: AppTheme.headingMedium(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.deleteAccountConfirmation,
              style: AppTheme.bodyLarge(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.deleteAccountWarning,
              style: AppTheme.bodyMedium(context).copyWith(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: AppTheme.bodyLarge(context),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.continueAction),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.l10n.finalConfirmation,
          style: AppTheme.headingMedium(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.deleteAccountPrompt,
              style: AppTheme.bodyMedium(context),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: context.l10n.deleteKeyword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: AppTheme.bodyLarge(context),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == context.l10n.deleteKeyword) {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
                context.router.replaceNamed('/');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.accountDeleted,
                      style: AppTheme.bodyMedium(context),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.deleteKeywordMismatch,
                      style: AppTheme.bodyMedium(context),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTheme.headingMedium(context)),
        content: Text(content, style: AppTheme.bodyLarge(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: AppTheme.bodyLarge(context),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
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

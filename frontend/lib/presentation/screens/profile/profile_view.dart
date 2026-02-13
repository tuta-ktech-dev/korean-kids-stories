import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_preferences_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/history_cubit/history_cubit.dart';
import '../../cubits/stats_cubit/stats_cubit.dart';
import '../../widgets/streak_badge.dart';
import '../../../core/router/app_router.dart';
import 'package:auto_route/auto_route.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final AuthRepository _authRepo;
  late final UserPreferencesRepository _prefsRepo;
  late final TextEditingController _nameController;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _notificationsEnabled = false;
  int _avatarVersion = 0; // Bump after upload to bust cache

  @override
  void initState() {
    super.initState();
    _authRepo = getIt<AuthRepository>();
    _prefsRepo = getIt<UserPreferencesRepository>();
    final user = _authRepo.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await _prefsRepo.getPreferences();
    if (mounted && prefs != null) {
      setState(() => _notificationsEnabled = prefs.notificationsEnabled);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final bytes = await xFile.readAsBytes();
      var ext = xFile.name.split('.').last;
      if (ext.isEmpty) ext = 'jpg';
      final filename = 'avatar.$ext';
      final multipart = http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: filename,
      );

      await _authRepo.updateProfile(avatarFile: multipart);
      if (mounted) {
        setState(() => _avatarVersion++);
        context.read<AuthCubit>().checkAuthStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.profileSaved,
              style: AppTheme.bodyMedium(context),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('PocketbaseException: ', ''),
              style: AppTheme.bodyMedium(context),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  String? _avatarUrl() {
    final record = getIt<PocketbaseService>().currentUser;
    if (record == null) return null;
    final raw = record.data['avatar'];
    if (raw == null) return null;
    // PocketBase file field: string (filename) or list of filenames
    final avatar = raw is List && raw.isNotEmpty
        ? raw.first.toString()
        : raw.toString();
    if (avatar.isEmpty) return null;
    final baseUrl = AppConfig.baseUrl;
    final url = '$baseUrl/api/files/users/${record.id}/$avatar';
    return '$url${url.contains('?') ? '&' : '?'}v=$_avatarVersion';
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    final currentName = _authRepo.currentUser?.name ?? '';

    if (newName == currentName) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No changes to save',
              style: AppTheme.bodyMedium(context),
            ),
          ),
        );
      }
      return;
    }

    if (newName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.enterName,
              style: AppTheme.bodyMedium(context),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _authRepo.updateProfile(name: newName);
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.profileSaved,
              style: AppTheme.bodyMedium(context),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('PocketbaseException: ', ''),
              style: AppTheme.bodyMedium(context),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.l10n.changePassword,
          style: AppTheme.headingMedium(ctx),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.password,
                style: AppTheme.bodyMedium(
                  ctx,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: oldController,
                obscureText: true,
                decoration: InputDecoration(hintText: context.l10n.oldPassword),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.newPassword,
                style: AppTheme.bodyMedium(
                  ctx,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: context.l10n.passwordLengthHint,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.confirmPassword,
                style: AppTheme.bodyMedium(
                  ctx,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: context.l10n.confirmPassword,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel, style: AppTheme.bodyLarge(ctx)),
          ),
          ElevatedButton(
            onPressed: () async {
              final old = oldController.text;
              final newPw = newController.text;
              final confirm = confirmController.text;

              if (old.isEmpty || newPw.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(context.l10n.enterEmailPassword)),
                );
                return;
              }
              if (newPw != confirm) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(context.l10n.passwordsDoNotMatch)),
                );
                return;
              }
              if (newPw.length < 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(context.l10n.passwordMinLength)),
                );
                return;
              }

              Navigator.pop(ctx);
              try {
                await _authRepo.changePassword(
                  oldPassword: old,
                  newPassword: newPw,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.passwordChanged,
                        style: AppTheme.bodyMedium(context),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceAll('PocketbaseException: ', ''),
                        style: AppTheme.bodyMedium(context),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor(context),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(context.l10n.saveNote),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          appBar: AppBar(
            title: Text(
              context.l10n.profileTitle,
              style: AppTheme.headingMedium(context),
            ),
            backgroundColor: AppTheme.backgroundColor(context),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryPink.withValues(
                            alpha: 0.3,
                          ),
                          backgroundImage: _avatarUrl() != null
                              ? NetworkImage(_avatarUrl()!)
                              : null,
                          child: _avatarUrl() == null
                              ? (_isUploadingAvatar
                                    ? SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 48,
                                        color: AppTheme.primaryPink,
                                      ))
                              : _isUploadingAvatar
                              ? Container(
                                  color: AppTheme.textColor(context)
                                      .withValues(alpha: 0.5),
                                  child: Center(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Level & XP card (reuses app-level StatsCubit with cache)
                BlocProvider.value(
                  value: context.read<StatsCubit>(),
                  child: _StatsLoader(
                    child: BlocBuilder<StatsCubit, StatsState>(
                    buildWhen: (p, c) =>
                        p.stats != c.stats || p.isLoading != c.isLoading,
                    builder: (context, statsState) {
                      final stats = statsState.stats;
                      if (statsState.isLoading && stats == null) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (stats == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPink.withValues(alpha: 0.3),
                              AppTheme.primaryMint.withValues(alpha: 0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              label: context.l10n.level,
                              value: '${stats.level}',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppTheme.textMutedColor(context)
                                  .withValues(alpha: 0.8),
                            ),
                            _StatItem(
                              label: context.l10n.xp,
                              value: '${stats.totalXp.toInt()}',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppTheme.textMutedColor(context)
                                  .withValues(alpha: 0.8),
                            ),
                            _StatItem(
                              label: context.l10n.currentStreak,
                              value: '${stats.streakDays}',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ),

                // Reading streak from History (actual reading days)
                BlocBuilder<HistoryCubit, HistoryState>(
                  buildWhen: (p, c) => p != c,
                  builder: (context, state) {
                    if (state is HistoryInitial) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<HistoryCubit>().loadHistory();
                      });
                    }
                    if (state is! HistoryLoaded) return const SizedBox.shrink();
                    final stats = state.stats;
                    if (stats.currentStreak == 0 && stats.longestStreak == 0) {
                      return const SizedBox.shrink();
                    }
                    return StreakBadge(
                      currentStreak: stats.currentStreak,
                      longestStreak: stats.longestStreak,
                      compact: true,
                    );
                  },
                ),

                // Sticker Album button
                OutlinedButton.icon(
                  onPressed: () =>
                      AutoRouter.of(context).push(const StickersRoute()),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: Text(context.l10n.stickerAlbum),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                Text(
                  context.l10n.nameLabel,
                  style: AppTheme.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: context.l10n.enterName),
                ),
                const SizedBox(height: 16),

                // Email (read-only)
                Text(
                  context.l10n.email,
                  style: AppTheme.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    state.email ?? '',
                    style: AppTheme.bodyMedium(
                      context,
                    ).copyWith(color: AppTheme.textMutedColor(context)),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(context.l10n.saveNote),
                  ),
                ),
                const SizedBox(height: 24),

                // Notification Settings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.primaryColor(context),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n.notificationSettings,
                            style: AppTheme.bodyLarge(context),
                          ),
                        ],
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: (v) async {
                          setState(() => _notificationsEnabled = v);
                          await _prefsRepo.savePreferences(
                            notificationsEnabled: v,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Change Password
                OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(context.l10n.changePassword),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Triggers loadStats when Profile is shown (uses cache if fresh)
class _StatsLoader extends StatefulWidget {
  final Widget child;

  const _StatsLoader({required this.child});

  @override
  State<_StatsLoader> createState() => _StatsLoaderState();
}

class _StatsLoaderState extends State<_StatsLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StatsCubit>().loadStats(forceRefresh: false);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.headingMedium(
            context,
          ).copyWith(color: AppTheme.textDark, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption(context).copyWith(color: AppTheme.textMedium),
        ),
      ],
    );
  }
}

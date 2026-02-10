import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.router.replaceNamed('/main');
        }
      },
      builder: (context, state) {
        // Handle initial state: auth already loaded in main() before runApp
        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.router.replaceNamed('/main');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPink,
                              AppTheme.primaryCoral,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPink.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        context.l10n.landingTitle,
                        style: AppTheme.headingLarge(
                          context,
                        ).copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Korean Kids Stories',
                        style: AppTheme.bodyLarge(
                          context,
                        ).copyWith(color: AppTheme.textMutedColor(context)),
                      ),
                      const SizedBox(height: 16),

                      // Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor(
                            context,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.l10n.landingSubtitle,
                          style: AppTheme.bodyMedium(context).copyWith(
                            color: AppTheme.primaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Guest access button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().loginAsGuest();
                          context.router.replaceNamed('/main');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(context.l10n.browseWithoutLogin),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.router.pushNamed('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: AppTheme.primaryColor(context),
                          ),
                        ),
                        child: Text(
                          context.l10n.login,
                          style: AppTheme.bodyLarge(context).copyWith(
                            color: AppTheme.primaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${context.l10n.dontHaveAccount} ',
                          style: AppTheme.bodyMedium(context),
                        ),
                        TextButton(
                          onPressed: () {
                            context.router.pushNamed('/register');
                          },
                          child: Text(
                            context.l10n.signUp,
                            style: AppTheme.bodyMedium(context).copyWith(
                              color: AppTheme.primaryColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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

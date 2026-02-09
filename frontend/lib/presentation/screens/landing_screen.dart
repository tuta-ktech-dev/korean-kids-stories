import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../cubits/auth_cubit/auth_cubit.dart';

@RoutePage()
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Auto navigate to main if already logged in
          context.router.replaceNamed('/main');
        }
      },
      child: Scaffold(
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
                              color: AppTheme.primaryPink.withValues(alpha: 0.3),
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
                        '한국 동화',
                        style: AppTheme.headingLarge(context).copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Korean Kids Stories',
                        style: AppTheme.bodyLarge(context).copyWith(
                          color: AppTheme.textMutedColor(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '전통부터 역사까지, 아이들을 위한 한국 이야기',
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
                        child: const Text('둘러보기'),
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
                          side: BorderSide(color: AppTheme.primaryColor(context)),
                        ),
                        child: Text(
                          '로그인',
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
                          '계정이 없으신가요? ',
                          style: AppTheme.bodyMedium(context),
                        ),
                        TextButton(
                          onPressed: () {
                            context.router.pushNamed('/register');
                          },
                          child: Text(
                            '회원가입',
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
      ),
    );
  }
}

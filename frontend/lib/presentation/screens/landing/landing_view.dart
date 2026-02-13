import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/responsive_padding.dart';
import '../onboarding/onboarding_view.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  bool _checkedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final completed = await isOnboardingCompleted();
    if (!mounted) return;
    setState(() => _checkedOnboarding = true);
    if (!completed) {
      context.router.replaceNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedOnboarding) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: ResponsivePadding(
          maxWidth: 480,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/landing_logo.png',
                        width: min(400, min(context.width, context.height)),
                        height: min(400, min(context.width, context.height)),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.auto_stories,
                          size: 60,
                          color: AppTheme.primaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 32),
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.router.replaceNamed('/main');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(context.l10n.landingStartButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

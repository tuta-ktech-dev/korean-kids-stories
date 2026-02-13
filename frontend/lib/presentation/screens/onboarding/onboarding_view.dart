import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

const _onboardingCompletedKey = 'onboarding_completed';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    if (!mounted) return;
    context.router.replaceNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingPage(
        image: 'assets/images/onboarding_1.png',
        title: context.l10n.onboardingPage1Title,
        subtitle: context.l10n.onboardingPage1Desc,
      ),
      _OnboardingPage(
        image: 'assets/images/onboarding_2.png',
        title: context.l10n.onboardingPage2Title,
        subtitle: context.l10n.onboardingPage2Desc,
      ),
      _OnboardingPage(
        image: 'assets/images/onboarding_3.png',
        title: context.l10n.onboardingPage3Title,
        subtitle: context.l10n.onboardingPage3Desc,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.onboardingBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: pages.length,
                itemBuilder: (context, i) => pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.primaryColor(context)
                              : AppTheme.textMutedColor(
                                  context,
                                ).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentPage < pages.length - 1
                          ? context.l10n.onboardingNextButton
                          : context.l10n.landingStartButton,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Center(child: Image.asset(image, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTheme.headingMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyLarge(
              context,
            ).copyWith(color: AppTheme.textMutedColor(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Check if onboarding was completed
Future<bool> isOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingCompletedKey) ?? false;
}

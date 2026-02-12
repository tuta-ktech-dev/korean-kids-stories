import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'onboarding_view.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingView();
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'landing_view.dart';

@RoutePage()
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingView();
  }
}

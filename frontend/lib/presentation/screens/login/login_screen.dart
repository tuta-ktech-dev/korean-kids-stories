import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'login_view.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

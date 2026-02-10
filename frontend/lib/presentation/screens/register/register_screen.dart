import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'register_view.dart';

@RoutePage()
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegisterView();
  }
}

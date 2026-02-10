import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'otp_verification_view.dart';

@RoutePage()
class OtpVerificationScreen extends StatelessWidget {
  final String? email;

  const OtpVerificationScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return OtpVerificationView(email: email);
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';

import '../../cubits/auth_cubit/auth_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

/// Screen hiển thị sau khi đăng ký - yêu cầu user check email để verify
class OtpVerificationView extends StatefulWidget {
  final String? email;

  const OtpVerificationView({super.key, this.email});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _canResend = false);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
          _resendTimer = 60;
        });
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    if (widget.email != null) {
      context.read<AuthCubit>().resendVerificationEmail(widget.email!);
    }

    _startResendTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.emailResent,
            style: AppTheme.bodyMedium(context),
          ),
        ),
      );
    }
  }

  void _onLoginPressed() {
    // Navigate to login after user has verified email
    context.router.replaceNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.verificationSuccess,
                style: AppTheme.bodyMedium(context),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.router.replaceNamed('/main');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: AppTheme.bodyMedium(context)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.textColor(context)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Email icon
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: AppTheme.primaryColor(context),
                  ),
                  const SizedBox(height: 32),

                  Text('이메일을 확인해주세요', style: AppTheme.headingLarge(context)),
                  const SizedBox(height: 16),

                  Text.rich(
                    TextSpan(
                      text: '아래 이메일로 인증 링크를 별냈습니다\n',
                      style: AppTheme.bodyMedium(context),
                      children: [
                        TextSpan(
                          text: widget.email ?? 'your@email.com',
                          style: AppTheme.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor(context),
                          ),
                        ),
                        TextSpan(text: '\n\n${context.l10n.clickVerifyLink}.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInstructionItem(
                          context,
                          icon: Icons.email_outlined,
                          text: context.l10n.checkEmail,
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionItem(
                          context,
                          icon: Icons.touch_app_outlined,
                          text: context.l10n.clickVerifyLink,
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionItem(
                          context,
                          icon: Icons.login_outlined,
                          text: context.l10n.loginInstruction,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(context.l10n.goToLogin),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resend email
                  Center(
                    child: _canResend
                        ? TextButton(
                            onPressed: _resendVerificationEmail,
                            child: Text(
                              context.l10n.resendEmail,
                              style: AppTheme.bodyLarge(context).copyWith(
                                color: AppTheme.primaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text(
                            context.l10n.resendTimer(_resendTimer),
                            style: AppTheme.bodyMedium(
                              context,
                            ).copyWith(color: AppTheme.textMutedColor(context)),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Note about spam
                  Text(
                    context.l10n.spamCheckNote,
                    style: AppTheme.caption(
                      context,
                    ).copyWith(color: AppTheme.textMutedColor(context)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor(context), size: 24),
        const SizedBox(width: 12),
        Text(text, style: AppTheme.bodyMedium(context)),
      ],
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../cubits/auth_cubit.dart';

@RoutePage()
class OtpVerificationScreen extends StatefulWidget {
  final String? email;
  
  const OtpVerificationScreen({
    super.key,
    this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
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

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      _showError('6자리 인증번호를 입력해주세요');
      return;
    }

    await context.read<AuthCubit>().verifyOtp(otp);
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    
    context.read<AuthCubit>().resendOtp();
    _startResendTimer();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증번호가 재전송되었습니다', style: AppTheme.bodyMedium(context)),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyMedium(context)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onOtpChanged(int index, String value) {
    // Remove any non-digit characters
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanedValue.isNotEmpty && cleanedValue != _controllers[index].text) {
      // Take only the last digit if multiple entered
      final digit = cleanedValue.substring(cleanedValue.length - 1);
      _controllers[index].text = digit;
      
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (cleanedValue.isEmpty && value.isEmpty) {
      // Backspace pressed, move to previous
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    
    // Auto verify when all filled
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('인증이 완료되었습니다!', style: AppTheme.bodyMedium(context)),
              backgroundColor: Colors.green,
            ),
          );
          context.router.replaceNamed("/main");
        } else if (state is AuthError) {
          _showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증번호 입력',
                    style: AppTheme.headingLarge(context),
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: '이메일로 전송된 6자리 인증번호를 입력해주세요\n',
                      style: AppTheme.bodyMedium(context),
                      children: [
                        TextSpan(
                          text: widget.email ?? 'your@email.com',
                          style: AppTheme.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // OTP Input fields - FIXED
                  KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      // Handle backspace globally
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        // Find which field has focus
                        for (int i = 0; i < 6; i++) {
                          if (_focusNodes[i].hasFocus &&
                              _controllers[i].text.isEmpty &&
                              i > 0) {
                            _controllers[i - 1].text = '';
                            _focusNodes[i - 1].requestFocus();
                            break;
                          }
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 48,
                          height: 56,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
                            maxLength: 1,
                            autofocus: index == 0,
                            style: AppTheme.headingMedium(context).copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: AppTheme.surfaceColor(context),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor(context),
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            onChanged: (value) => _onOtpChanged(index, value),
                            onEditingComplete: () {
                              if (index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('인증하기'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Resend OTP
                  Center(
                    child: _canResend
                        ? TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              '인증번호 재전송',
                              style: AppTheme.bodyLarge(context).copyWith(
                                color: AppTheme.primaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text(
                            '$_resendTimer초 후에 재전송 가능',
                            style: AppTheme.bodyMedium(context).copyWith(
                              color: AppTheme.textMutedColor(context),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}

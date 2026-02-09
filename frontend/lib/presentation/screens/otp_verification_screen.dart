import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

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
  bool _isLoading = false;
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

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      _showError('6자리 인증번호를 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);
    
    // TODO: Call verify OTP API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      // Show success and navigate to main
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증이 완료되었습니다!', style: AppTheme.bodyMedium(context)),
          backgroundColor: Colors.green,
        ),
      );
      context.router.replaceNamed("/main");
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    
    setState(() => _isLoading = true);
    
    // TODO: Call resend OTP API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
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
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto verify when all filled
    if (index == 5 && value.isNotEmpty) {
      final otp = _controllers.map((c) => c.text).join();
      if (otp.length == 6) {
        _verifyOtp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              
              // OTP Input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTheme.headingMedium(context).copyWith(fontSize: 24),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppTheme.surfaceColor(context),
                        border: OutlineInputBorder(
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
                      ],
                      onChanged: (value) => _onOtpChanged(index, value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
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

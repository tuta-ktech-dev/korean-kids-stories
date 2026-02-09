import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  Future<void> _register() async {
    // Validation
    if (_nameController.text.isEmpty) {
      _showError('이름을 입력해주세요');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('이메일을 입력해주세요');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError('비밀번호는 6자 이상이어야 합니다');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('비밀번호가 일치하지 않습니다');
      return;
    }
    if (!_agreeToTerms) {
      _showError('이용약관에 동의해주세요');
      return;
    }

    setState(() => _isLoading = true);
    
    // TODO: Call register API to send OTP
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      // Navigate to OTP verification
      // TODO: Pass email to OTP screen using state management or arguments
      context.router.pushNamed('/verify-otp');
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    // TODO: Google OAuth
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _registerWithApple() async {
    setState(() => _isLoading = true);
    // TODO: Apple OAuth
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyMedium(context)),
        backgroundColor: Colors.red,
      ),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '회원가입',
                style: AppTheme.headingLarge(context),
              ),
              const SizedBox(height: 8),
              Text(
                '새로운 계정을 만들어 이야기를 시작하세요',
                style: AppTheme.bodyMedium(context),
              ),
              const SizedBox(height: 32),
              
              // Name field
              _buildTextField(
                controller: _nameController,
                hintText: '이름 (자녀의 이름)',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              // Email field
              _buildTextField(
                controller: _emailController,
                hintText: '이메일',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              
              // Password field
              _buildTextField(
                controller: _passwordController,
                hintText: '비밀번호 (6자 이상)',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textMutedColor(context),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              
              // Confirm password field
              _buildTextField(
                controller: _confirmPasswordController,
                hintText: '비밀번호 확인',
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textMutedColor(context),
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 16),
              
              // Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                    activeColor: AppTheme.primaryColor(context),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                      child: Text.rich(
                        TextSpan(
                          text: '이용약관',
                          style: AppTheme.bodyMedium(context).copyWith(
                            color: AppTheme.primaryColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: ' 및 ',
                              style: AppTheme.bodyMedium(context),
                            ),
                            TextSpan(
                              text: '개인정보 처리방침',
                              style: AppTheme.bodyMedium(context).copyWith(
                                color: AppTheme.primaryColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '에 동의합니다',
                              style: AppTheme.bodyMedium(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                      : const Text('회원가입'),
                ),
              ),
              const SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.textMutedColor(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('또는', style: AppTheme.caption(context)),
                  ),
                  Expanded(child: Divider(color: AppTheme.textMutedColor(context))),
                ],
              ),
              const SizedBox(height: 24),
              
              // Social register
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onTap: _registerWithGoogle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: _registerWithApple,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이미 계정이 있으신가요? ', style: AppTheme.bodyMedium(context)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '로그인',
                      style: AppTheme.bodyMedium(context).copyWith(
                        color: AppTheme.primaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textMutedColor(context))
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surfaceColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textMutedColor(context).withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.bodyLarge(context)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

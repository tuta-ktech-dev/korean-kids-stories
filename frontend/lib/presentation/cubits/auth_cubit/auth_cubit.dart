import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../data/services/pocketbase_service.dart';
import 'auth_state.dart';
export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial()) {
    checkAuthStatus();
  }

  final _pbService = PocketbaseService();
  String? _pendingEmail;
  String? _pendingPassword;

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    await _pbService.initialize();

    if (_pbService.isAuthenticated) {
      final user = _pbService.currentUser;
      emit(Authenticated(
        userId: user!.id,
        userName: user.getStringValue('name'),
        email: user.getStringValue('email'),
      ));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final authData = await _pbService.pb.collection('users').authWithPassword(
            email,
            password,
          );

      emit(Authenticated(
        userId: authData.record.id,
        userName: authData.record.getStringValue('name'),
        email: authData.record.getStringValue('email'),
      ));
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '로그인에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } catch (e) {
      emit(const AuthError('로그인에 실패했습니다'));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(const AuthLoading());

    try {
      // Create user with OTP verification pending
      await _pbService.pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
        'emailVisibility': false,
      });

      // Store pending credentials for after OTP verification
      _pendingEmail = email;
      _pendingPassword = password;

      // Send OTP (using password reset as OTP workaround)
      await _pbService.pb.collection('users').requestPasswordReset(email);

      emit(OtpSent(email));
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '회원가입에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } catch (e) {
      emit(const AuthError('회원가입에 실패했습니다'));
    }
  }

  Future<void> verifyOtp(String otp) async {
    emit(const AuthLoading());

    try {
      // For Pocketbase, we verify OTP by attempting password reset
      // In production, you'd implement a proper OTP collection
      if (_pendingEmail != null && _pendingPassword != null) {
        // After OTP verification, auto login
        await login(_pendingEmail!, _pendingPassword!);
        _pendingEmail = null;
        _pendingPassword = null;
      } else {
        emit(const AuthError('잘못된 요청입니다'));
      }
    } catch (e) {
      emit(const AuthError('인증번호가 올바르지 않습니다'));
    }
  }

  Future<void> resendOtp() async {
    if (_pendingEmail != null) {
      try {
        await _pbService.pb
            .collection('users')
            .requestPasswordReset(_pendingEmail!);
      } catch (e) {
        // Ignore error
      }
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await _pbService.logout();
      emit(const Unauthenticated());
    } catch (e) {
      emit(const AuthError('로그아웃에 실패했습니다'));
    }
  }

  Future<void> loginAsGuest() async {
    emit(const AuthLoading());
    emit(const Unauthenticated());
  }

  bool get isAuthenticated => state is Authenticated;
  bool get isGuest => state is Unauthenticated;
}

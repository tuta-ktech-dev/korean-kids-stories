import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../data/services/pocketbase_service.dart';

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String? userName;
  final String? email;
  
  Authenticated({
    required this.userId,
    this.userName,
    this.email,
  });
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class OtpSent extends AuthState {
  final String email;
  OtpSent(this.email);
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }

  final _pbService = PocketbaseService();
  String? _pendingEmail;
  String? _pendingPassword;
  String? _pendingName;

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    await _pbService.initialize();
    
    if (_pbService.isAuthenticated) {
      final user = _pbService.currentUser;
      emit(Authenticated(
        userId: user!.id,
        userName: user.getStringValue('name'),
        email: user.getStringValue('email'),
      ));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
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
      emit(AuthError('로그인에 실패했습니다'));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    
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
      _pendingName = name;
      
      // Send OTP (using password reset as OTP workaround)
      await _pbService.pb.collection('users').requestPasswordReset(email);
      
      emit(OtpSent(email));
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '회원가입에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } catch (e) {
      emit(AuthError('회원가입에 실패했습니다'));
    }
  }

  Future<void> verifyOtp(String otp) async {
    emit(AuthLoading());
    
    try {
      // For Pocketbase, we verify OTP by attempting password reset
      // In production, you'd implement a proper OTP collection
      if (_pendingEmail != null && _pendingPassword != null) {
        // After OTP verification, auto login
        await login(_pendingEmail!, _pendingPassword!);
        _pendingEmail = null;
        _pendingPassword = null;
        _pendingName = null;
      } else {
        emit(AuthError('잘못된 요청입니다'));
      }
    } catch (e) {
      emit(AuthError('인증번호가 올바르지 않습니다'));
    }
  }

  Future<void> resendOtp() async {
    if (_pendingEmail != null) {
      try {
        await _pbService.pb.collection('users').requestPasswordReset(_pendingEmail!);
      } catch (e) {
        // Ignore error
      }
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    try {
      await _pbService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('로그아웃에 실패했습니다'));
    }
  }

  Future<void> loginAsGuest() async {
    emit(AuthLoading());
    emit(Unauthenticated());
  }

  bool get isAuthenticated => state is Authenticated;
  bool get isGuest => state is Unauthenticated;
}

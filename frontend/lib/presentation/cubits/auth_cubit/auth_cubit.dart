import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import 'auth_state.dart';
export 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? getIt<AuthRepository>(),
      super(const AuthInitial());

  final AuthRepository _authRepository;
  String? _pendingEmail;
  String? _pendingPassword;

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      await _authRepository.initialize();

      if (_authRepository.isAuthenticated) {
        final user = _authRepository.currentUser;
        if (user != null) {
          emit(
            Authenticated(
              userId: user.id,
              userName: user.name,
              email: user.email,
            ),
          );
        } else {
          emit(const Unauthenticated());
        }
      } else {
        emit(const Unauthenticated());
      }
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('인증 상태 확인에 실패했습니다'));
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.login(email, password);

      emit(
        Authenticated(userId: user.id, userName: user.name, email: user.email),
      );
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '로그인에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('로그인에 실패했습니다'));
    }
  }

  /// Register a new user
  ///
  /// After registration, sends verification email and transitions
  /// to email verification flow
  Future<void> register(String name, String email, String password) async {
    emit(const AuthLoading());

    try {
      // Create user - will send verification email automatically
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );

      // Store pending credentials for auto-login after verification
      _pendingEmail = email;
      _pendingPassword = password;

      // Emit verification required state
      emit(EmailVerificationRequired(email));
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '회원가입에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('회원가입에 실패했습니다'));
    }
  }

  /// Verify email with token
  ///
  /// After successful verification, auto-login if credentials are pending
  Future<void> verifyEmail(String token) async {
    emit(const AuthLoading());

    try {
      await _authRepository.verifyEmail(token);

      // After verification, auto-login if we have pending credentials
      if (_pendingEmail != null && _pendingPassword != null) {
        await login(_pendingEmail!, _pendingPassword!);
        _pendingEmail = null;
        _pendingPassword = null;
      } else {
        // No pending credentials, just show success
        emit(const Unauthenticated());
      }
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '이메일 인증에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('인증번호가 올바르지 않습니다'));
    }
  }

  /// Resend verification email. Returns true on success.
  Future<bool> resendVerificationEmail([String? email]) async {
    final targetEmail = email ?? _pendingEmail;
    if (targetEmail == null) return false;
    try {
      await _authRepository.resendVerificationEmail(targetEmail);
      return true;
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
      return false;
    } catch (e) {
      emit(const AuthError('인증 메일 재발송에 실패했습니다'));
      return false;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    emit(const AuthLoading());

    try {
      await _authRepository.requestPasswordReset(email);
      emit(PasswordResetEmailSent(email));
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '비밀번호 재설정 요청에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('비밀번호 재설정 요청에 실패했습니다'));
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset(String token, String newPassword) async {
    emit(const AuthLoading());

    try {
      await _authRepository.confirmPasswordReset(
        token: token,
        newPassword: newPassword,
      );
      emit(const PasswordResetSuccess());
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '비밀번호 재설정에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('비밀번호 재설정에 실패했습니다'));
    }
  }

  /// Logout current user
  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      _pendingEmail = null;
      _pendingPassword = null;
      emit(const Unauthenticated());
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('로그아웃에 실패했습니다'));
    }
  }

  /// Login as guest (unauthenticated)
  void loginAsGuest() {
    emit(const AuthLoading());
    emit(const Unauthenticated());
  }

  /// Login with OAuth provider
  Future<void> loginWithOAuth(String provider) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.loginWithOAuth(provider);
      emit(
        Authenticated(userId: user.id, userName: user.name, email: user.email),
      );
    } on ClientException catch (e) {
      final errorMsg = e.response['message'] ?? '소셜 로그인에 실패했습니다';
      emit(AuthError(errorMsg.toString()));
    } on PocketbaseException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('소셜 로그인에 실패했습니다'));
    }
  }

  bool get isAuthenticated => state is Authenticated;
  bool get isGuest => state is Unauthenticated;
}

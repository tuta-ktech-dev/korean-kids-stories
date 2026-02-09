import 'package:flutter_bloc/flutter_bloc.dart';
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

// Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }

  final _pbService = PocketbaseService();

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
      // TODO: Implement actual login with Pocketbase
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo, simulate successful login
      emit(Authenticated(
        userId: 'demo_user_id',
        userName: 'Demo User',
        email: email,
      ));
    } catch (e) {
      emit(AuthError('로그인에 실패했습니다'));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    
    try {
      // TODO: Implement actual registration
      await Future.delayed(const Duration(seconds: 1));
      
      emit(Unauthenticated()); // Need to verify OTP first
    } catch (e) {
      emit(AuthError('회원가입에 실패했습니다'));
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
    
    // Guest is also Unauthenticated but we track it differently
    emit(Unauthenticated());
  }

  bool get isAuthenticated => state is Authenticated;
  bool get isGuest => state is Unauthenticated;
}

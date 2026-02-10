import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String userId;
  final String? userName;
  final String? email;

  const Authenticated({
    required this.userId,
    this.userName,
    this.email,
  });

  @override
  List<Object?> get props => [userId, userName, email];

  Authenticated copyWith({
    String? userId,
    String? userName,
    String? email,
  }) {
    return Authenticated(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
    );
  }
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Email verification required after registration
class EmailVerificationRequired extends AuthState {
  final String email;

  const EmailVerificationRequired(this.email);

  @override
  List<Object?> get props => [email];
}

/// Password reset email sent
class PasswordResetEmailSent extends AuthState {
  final String email;

  const PasswordResetEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Password reset successful
class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

/// Legacy state - kept for backward compatibility if needed
/// @deprecated Use EmailVerificationRequired instead
class OtpSent extends AuthState {
  final String email;

  const OtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

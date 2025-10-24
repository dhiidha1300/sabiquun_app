import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';

/// Authentication state for the application
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking if user is already authenticated
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// User is authenticated
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication in progress (login, signup, etc.)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authentication error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Account pending approval
class AccountPendingApproval extends AuthState {
  final String email;

  const AccountPendingApproval(this.email);

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

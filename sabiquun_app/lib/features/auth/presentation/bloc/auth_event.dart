import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already authenticated on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

/// Sign up with user details
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber, profilePhotoUrl];
}

/// Logout current user
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Request password reset
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Reset password with token
class PasswordUpdateRequested extends AuthEvent {
  final String newPassword;

  const PasswordUpdateRequested(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

/// Refresh authentication token
class TokenRefreshRequested extends AuthEvent {
  const TokenRefreshRequested();
}

/// Update user profile
class ProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  const ProfileUpdateRequested({
    this.fullName,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, profilePhotoUrl];
}

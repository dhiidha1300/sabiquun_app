import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordUpdateRequested>(_onPasswordUpdateRequested);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  /// Check if user is already authenticated
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (result.isSuccess && result.user != null) {
        // Check if account is pending approval
        if (result.user!.accountStatus.isPending) {
          emit(AccountPendingApproval(event.email));
          return;
        }

        emit(Authenticated(result.user!));
      } else {
        emit(AuthError(result.errorMessage ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle sign up request
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        profilePhotoUrl: event.profilePhotoUrl,
      );

      if (result.isSuccess && result.user != null) {
        // New users are pending approval by default
        emit(AccountPendingApproval(event.email));
      } else {
        emit(AuthError(result.errorMessage ?? 'Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await authRepository.logout();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
      // Still emit unauthenticated even if logout fails
      emit(const Unauthenticated());
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await authRepository.sendPasswordResetEmail(event.email);
      emit(PasswordResetEmailSent(event.email));
    } catch (e) {
      emit(AuthError('Failed to send password reset email: ${e.toString()}'));
    }
  }

  /// Handle password update request
  Future<void> _onPasswordUpdateRequested(
    PasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await authRepository.resetPassword(event.newPassword);

      // After successful password reset, user should login again
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError('Failed to update password: ${e.toString()}'));
    }
  }

  /// Handle token refresh request
  Future<void> _onTokenRefreshRequested(
    TokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshed = await authRepository.refreshToken();

      if (!refreshed) {
        // Token refresh failed, logout user
        emit(const Unauthenticated());
      }
      // If successful, keep current state
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Handle profile update request
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;

    try {
      await authRepository.updateProfile(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        profilePhotoUrl: event.profilePhotoUrl,
      );

      // Reload user data
      final updatedUser = await authRepository.getCurrentUser();
      if (updatedUser != null) {
        emit(Authenticated(updatedUser));
      }
    } catch (e) {
      emit(AuthError('Failed to update profile: ${e.toString()}'));
      // Restore previous state
      emit(Authenticated(currentUser));
    }
  }
}

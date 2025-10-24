import 'package:sabiquun_app/core/errors/failures.dart';
import 'package:sabiquun_app/features/auth/domain/entities/auth_result.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  /// Sign up with user details
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  });

  /// Logout current user
  Future<void> logout();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh authentication token
  Future<bool> refreshToken();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Reset password with new password
  Future<void> resetPassword(String newPassword);

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  });

  /// Verify email with token
  Future<void> verifyEmail(String token);

  /// Check if email exists
  Future<bool> emailExists(String email);
}

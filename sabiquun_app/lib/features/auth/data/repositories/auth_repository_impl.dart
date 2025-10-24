import 'package:sabiquun_app/core/constants/account_status.dart';
import 'package:sabiquun_app/core/errors/failures.dart';
import 'package:sabiquun_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sabiquun_app/features/auth/domain/entities/auth_result.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';
import 'package:sabiquun_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sabiquun_app/shared/services/secure_storage_service.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = userModel.toEntity();

      // Check account status
      if (user.accountStatus == AccountStatus.pending) {
        return AuthResult.failure(
          message: 'Your account is pending admin approval',
          type: AuthErrorType.accountPending,
        );
      }

      if (user.accountStatus == AccountStatus.suspended) {
        return AuthResult.failure(
          message: 'Your account has been suspended',
          type: AuthErrorType.accountSuspended,
        );
      }

      if (user.accountStatus == AccountStatus.autoDeactivated) {
        return AuthResult.failure(
          message: 'Your account has been deactivated due to high penalty balance',
          type: AuthErrorType.accountDeactivated,
        );
      }

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(
        message: e.toString().replaceAll('Exception: ', ''),
        type: AuthErrorType.invalidCredentials,
      );
    }
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      final userModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
      );

      return AuthResult.success(userModel.toEntity());
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      AuthErrorType errorType = AuthErrorType.unknown;

      if (errorMessage.contains('already') || errorMessage.contains('exists')) {
        errorType = AuthErrorType.emailAlreadyInUse;
      } else if (errorMessage.contains('password')) {
        errorType = AuthErrorType.weakPassword;
      }

      return AuthResult.failure(
        message: errorMessage,
        type: errorType,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
      await storageService.deleteAllTokens();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await remoteDataSource.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      return await remoteDataSource.refreshToken();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> resetPassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      await remoteDataSource.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    // Implementation depends on Supabase email verification setup
    throw UnimplementedError('Email verification not implemented yet');
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      return await remoteDataSource.emailExists(email);
    } catch (e) {
      return false;
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';

/// Result of authentication operations
class AuthResult extends Equatable {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.errorType,
  });

  /// Create successful authentication result
  factory AuthResult.success(UserEntity user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  /// Create failed authentication result
  factory AuthResult.failure({
    required String message,
    AuthErrorType? type,
  }) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
      errorType: type ?? AuthErrorType.unknown,
    );
  }

  @override
  List<Object?> get props => [isSuccess, user, errorMessage, errorType];
}

/// Types of authentication errors
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  accountPending,
  accountSuspended,
  accountDeactivated,
  networkError,
  serverError,
  tokenExpired,
  unknown,
}

extension AuthErrorTypeX on AuthErrorType {
  String get message {
    switch (this) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password';
      case AuthErrorType.userNotFound:
        return 'User not found';
      case AuthErrorType.emailAlreadyInUse:
        return 'Email is already registered';
      case AuthErrorType.weakPassword:
        return 'Password is too weak';
      case AuthErrorType.accountPending:
        return 'Your account is pending admin approval';
      case AuthErrorType.accountSuspended:
        return 'Your account has been suspended';
      case AuthErrorType.accountDeactivated:
        return 'Your account has been deactivated';
      case AuthErrorType.networkError:
        return 'Network error. Please check your connection';
      case AuthErrorType.serverError:
        return 'Server error. Please try again later';
      case AuthErrorType.tokenExpired:
        return 'Session expired. Please login again';
      case AuthErrorType.unknown:
        return 'An unknown error occurred';
    }
  }
}

import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server failure (API errors)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
      : super(message);
}

/// Cache failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
      : super(message);
}

/// Network failure (connectivity issues)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred'])
      : super(message);
}

/// Authentication failure (auth-specific errors)
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication error occurred'])
      : super(message);
}

/// Validation failure (input validation errors)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error occurred'])
      : super(message);
}

/// Unknown failure (unexpected errors)
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Unknown error occurred'])
      : super(message);
}

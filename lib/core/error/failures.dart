/// Base class for all domain-level failures.
///
/// Failures represent expected business/domain errors that ViewModels and UI
/// handle gracefully without exposing raw infrastructure exceptions.
sealed class Failure {
  final String message;
  final int? code;
  final Object? cause;

  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Failure caused by network connectivity issues (offline, socket connection dropped).
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
    super.cause,
  });
}

/// Failure caused by remote server / API issues (HTTP 5xx, upstream error).
final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'A server error occurred. Please try again later.',
    super.code,
    super.cause,
  });
}

/// Failure caused by authentication issues (expired session, invalid credentials).
final class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed. Please log in again.',
    super.code,
    super.cause,
  });
}

/// Failure caused by request timeouts (connection timeout, receive timeout).
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out. Please try again.',
    super.code,
    super.cause,
  });
}

/// Failure caused by API rate limiting or quota exhaustion (HTTP 429).
final class RateLimitFailure extends Failure {
  final Duration? retryAfter;

  const RateLimitFailure({
    super.message = 'Rate limit exceeded. Please wait before retrying.',
    super.code,
    super.cause,
    this.retryAfter,
  });

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is RateLimitFailure &&
      retryAfter == other.retryAfter;

  @override
  int get hashCode => Object.hash(super.hashCode, retryAfter);
}

/// Failure caused by local persistence issues (SQLite, Drift, storage write/read error).
final class DatabaseFailure extends Failure {
  const DatabaseFailure({
    super.message = 'Database operation failed.',
    super.code,
    super.cause,
  });
}

/// Failure caused by parsing or serialization issues (invalid JSON, unexpected payload).
final class ParsingFailure extends Failure {
  const ParsingFailure({
    super.message = 'Failed to parse response data.',
    super.code,
    super.cause,
  });
}

/// Fallback failure for unexpected or unhandled exceptions.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code,
    super.cause,
  });
}

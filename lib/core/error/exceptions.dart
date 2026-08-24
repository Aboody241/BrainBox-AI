/// Base exception for application infrastructure and data layers.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Object? details;

  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => '$runtimeType: $message (statusCode: $statusCode)';
}

/// Thrown when remote API responds with a non-2xx status code.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Thrown when network connection cannot be established or drops.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection error',
    super.statusCode,
    super.details,
  });
}

/// Thrown when an authentication error occurs (401, 403, invalid token).
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Thrown when an operation times out.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Operation timed out',
    super.statusCode,
    super.details,
  });
}

/// Thrown when API quota or rate limit is exceeded (429).
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    required super.message,
    super.statusCode,
    super.details,
    this.retryAfter,
  });
}

/// Thrown when local database or storage operation fails.
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Thrown when payload cannot be parsed into expected model / DTO.
class ParsingException extends AppException {
  const ParsingException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

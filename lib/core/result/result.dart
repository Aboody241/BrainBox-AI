import '../error/failures.dart';

/// A monadic wrapper representing either a successful computation [Success]
/// or a failed computation [Error].
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result] holding [data].
  const factory Result.success(T data) = Success<T>;

  /// Creates a failed [Result] holding a domain [failure].
  const factory Result.failure(Failure failure) = Error<T>;

  /// Returns `true` if this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this result is an [Error].
  bool get isFailure => this is Error<T>;

  /// Returns the encapsulated data if [Success], otherwise `null`.
  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Error<T>() => null,
      };

  /// Returns the encapsulated [Failure] if [Error], otherwise `null`.
  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Error<T>(:final failure) => failure,
      };

  /// Pattern matching helper for exhaustive handling of [Success] and [Error].
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success<T>(:final data) => success(data),
        Error<T>(failure: final f) => failure(f),
      };

  /// Transforms the encapsulated value if this is [Success].
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(:final data) => Result.success(transform(data)),
        Error<T>(:final failure) => Result.failure(failure),
      };

  /// Asynchronously transforms the encapsulated value if this is [Success].
  Future<Result<R>> asyncMap<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success<T>(:final data) => Result.success(await transform(data)),
      Error<T>(:final failure) => Result.failure(failure),
    };
  }

  /// Chains another [Result]-producing computation if this is [Success].
  Result<R> flatMap<R>(Result<R> Function(T data) transform) => switch (this) {
        Success<T>(:final data) => transform(data),
        Error<T>(:final failure) => Result.failure(failure),
      };

  /// Asynchronously chains another [Result]-producing computation if this is [Success].
  Future<Result<R>> asyncFlatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    return switch (this) {
      Success<T>(:final data) => await transform(data),
      Error<T>(:final failure) => Result.failure(failure),
    };
  }

  /// Returns the encapsulated data if [Success], or computes [fallback] on [Failure].
  T getOrElse(T Function(Failure failure) fallback) => switch (this) {
        Success<T>(:final data) => data,
        Error<T>(:final failure) => fallback(failure),
      };
}

/// Successful result holding [data] of type [T].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() => 'Result.success($data)';
}

/// Failed result holding a domain [failure].
final class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Result.failure($failure)';
}

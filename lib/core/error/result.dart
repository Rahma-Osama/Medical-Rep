import 'app_failure.dart';

sealed class Result<T> {
  const Result();

  /// Handles success and typed [AppFailure] — single failure path (no duplicate callbacks).
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

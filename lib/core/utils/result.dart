// core/utils/result.dart
sealed class Result<S, F> {
  const Result();

  static Result<S, F> success<S, F>(S data) => Success<S, F>(data);
  static Result<S, F> failure<S, F>(F error) => Failure<S, F>(error);

  T when<T>({
    required T Function(S data) success,
    required T Function(F error) failure,
  }) {
    if (this is Success<S, F>) {
      return success((this as Success<S, F>).data);
    } else {
      return failure((this as Failure<S, F>).error);
    }
  }
}

final class Success<S, F> extends Result<S, F> {
final S data;
const Success(this.data);
}

final class Failure<S, F> extends Result<S, F> {
final F error;
const Failure(this.error);
}
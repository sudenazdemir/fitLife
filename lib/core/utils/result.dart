class Result<T> {
  final T? data;
  final String? error;

  const Result._({this.data, this.error});

  const Result.success(T value) : this._(data: value);

  const Result.failure(String message) : this._(error: message);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

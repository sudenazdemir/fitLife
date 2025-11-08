sealed class Result<T> {
  const Result();
  R fold<R>(R Function(String err) onErr, R Function(T data) onOk);
}

class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);
  @override
  R fold<R>(R Function(String) onErr, R Function(T) onOk) => onOk(data);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
  @override
  R fold<R>(R Function(String) onErr, R Function(T) onOk) => onErr(message);
}

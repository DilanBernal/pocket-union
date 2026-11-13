import 'domain_error.dart';

sealed class AppResponse<T> {
  const AppResponse();
}

final class Success<T> extends AppResponse<T> {
  final T value;

  const Success(this.value);
}

final class Failure<T> extends AppResponse<T> {
  final DomainError error;

  const Failure(this.error);
}
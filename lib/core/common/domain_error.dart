class DomainError {
  final String message;
  final String code;
  final Object? exception;
  final StackTrace? stackTrace;

  const DomainError({
    required this.message,
    required this.code,
    this.exception,
    this.stackTrace,
  });

  factory DomainError.fromException(
      Object exception,
      String code, {
        StackTrace? stackTrace,
      }) {
    return DomainError(
      message: exception.toString(),
      code: code,
      exception: exception,
      stackTrace: stackTrace,
    );
  }
}
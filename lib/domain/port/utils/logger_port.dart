/// Port for logging text messages and objects across the application.
abstract class LoggerPort {
  /// Logs an informational message.
  void info(String message);

  /// Logs a debug message.
  void debug(String message);

  /// Logs a warning message.
  void warning(String message);

  /// Logs an error message with an optional [error] and [stackTrace].
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// Logs an object (map, list, model, etc.) with an optional [label].
  void logObject(Object object, {String? label});
}

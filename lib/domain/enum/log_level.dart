/// Severity levels for application logging.
/// The [value] maps to `dart:developer` log severity levels.
enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000),
  object(700);

  final int value;

  const LogLevel(this.value);
}

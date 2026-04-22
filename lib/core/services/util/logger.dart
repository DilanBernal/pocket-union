import 'dart:convert';
import 'dart:developer' as developer;

import 'package:pocket_union/domain/enum/log_level.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';

class LoggerService extends LoggerPort {
  final String _tag;

  LoggerService({String tag = 'PocketUnion'}) : _tag = tag;

  @override
  void info(String message) {
    _log(LogLevel.info, message);
  }

  @override
  void debug(String message) {
    _log(LogLevel.debug, message);
  }

  @override
  void warning(String message) {
    _log(LogLevel.warning, message);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final buffer = StringBuffer(message);
    if (error != null) {
      buffer.write(' | Cause: $error');
    }
    _log(LogLevel.error, buffer.toString());
  }

  @override
  void logObject(Object object, {String? label}) {
    final prefix = label != null ? '[$label] ' : '';
    try {
      final encoded = const JsonEncoder.withIndent('  ').convert(object);
      _log(LogLevel.object, '$prefix$encoded');
    } catch (_) {
      _log(LogLevel.object, '$prefix$object');
    }
  }

  void _log(LogLevel level, String message) {
    // if (kDebugMode) {
    developer.log(
      message,
      name: _tag,
      level: level.value,
      time: DateTime.now(),
    );
    // }
  }
}

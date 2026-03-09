import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/services/util/logger.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';

final loggerProvider = Provider<LoggerPort>((ref) {
  var loggerService = LoggerService();
  return loggerService;
});

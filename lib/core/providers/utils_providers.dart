import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/services/util/logger.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final loggerProvider = Provider<LoggerPort>((ref) {
  return LoggerService();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  final instance = await SharedPreferences.getInstance();
  var isInSession = instance.getBool("isInSession");
  if (isInSession == null) {
    instance.setBool('isInSession', false);
  }
  return instance;
});

final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async {
  final logger = ref.watch(loggerProvider);

  try {
    if (!Supabase.instance.isInitialized) {
      final url = const String.fromEnvironment('SUPABASE_URL').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : 'http://10.0.2.2:54321';
      final anonKey =
          const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : 'yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

      if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
        throw Exception('Variables de entorno faltantes. ');
      }

      await Supabase.initialize(url: url, anonKey: anonKey);
      logger.info('Supabase inicializado correctamente');
    }

    return Supabase.instance.client;
  } catch (e, st) {
    logger.error('Error inicializando Supabase', error: e, stackTrace: st);
    rethrow;
  }
});

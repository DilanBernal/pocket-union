import 'package:flutter_dotenv/flutter_dotenv.dart';
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

final dotEnvProvider = FutureProvider<DotEnv>((ref) async {
  await dotenv.load(fileName: ".env", isOptional: false);
  return dotenv;
});

final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async {
  await ref.watch(dotEnvProvider.future);
  var logger = ref.watch(loggerProvider);
  try {
    if (Supabase.instance.isInitialized) {
      return Supabase.instance.client;
    }
  } on AssertionError catch (_) {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_API_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } catch (error) {
    logger.error("Ocurrio un error iniciando supabase");
  }

  return Supabase.instance.client;
});

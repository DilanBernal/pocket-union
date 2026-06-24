
import 'package:pocket_union/core/util/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';


@riverpod
Future<SupabaseClient> supabaseClientProvider(Ref ref ) async {
  final logger = ref.watch(loggerProvider);

  try {
    return Supabase.instance.client;
  } on AssertionError catch (_) {
    final url = const String.fromEnvironment('SUPABASE_API_URL').isNotEmpty
        ? const String.fromEnvironment('SUPABASE_API_URL')
        : 'http://10.0.2.2:54321';
    final anonKey =
    const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
        ? const String.fromEnvironment('SUPABASE_ANON_KEY')
        : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception('Variables de entorno faltantes. ');
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    logger.info('Supabase inicializado correctamente');
    return Supabase.instance.client;
  } catch (e, st) {
    logger.error('Error inicializando Supabase', error: e, stackTrace: st);
    rethrow;
  }
}
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_provider.dart';

part 'supabase_client_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SupabaseClient> supabaseClient(Ref ref) async {
  final logger = ref.watch(loggerProvider);

  try {
    // return FutureProvider.
    return Supabase.instance.client;
  } on AssertionError catch (_) {
    final url = const String.fromEnvironment('SUPABASE_API_URL').isNotEmpty
        ? const String.fromEnvironment('SUPABASE_API_URL')
        : 'http://10.0.2.2:54321';
    final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
        ? const String.fromEnvironment('SUPABASE_ANON_KEY')
        : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Variables de entorno faltantes. ');
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
    logger.info('Supabase inicializado correctamente');
    return Supabase.instance.client;
  } catch (e, st) {
    logger.error('Error inicializando Supabase', error: e, stackTrace: st);
    rethrow;
  }
}

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
    final url = const String.fromEnvironment('SUPABASE_API_URL');
    final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Variables de entorno faltantes. Debes proporcionar SUPABASE_API_URL y SUPABASE_ANON_KEY via --dart-define',
      );
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
    logger.info('Supabase inicializado correctamente');
    return Supabase.instance.client;
  } catch (e, st) {
    logger.error('Error inicializando Supabase', error: e, stackTrace: st);
    rethrow;
  }
}

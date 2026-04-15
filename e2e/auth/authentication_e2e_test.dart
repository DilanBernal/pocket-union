import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _e2eEmail = String.fromEnvironment('E2E_TEST_EMAIL');
const _e2ePassword = String.fromEnvironment('E2E_TEST_PASSWORD');
const _hasCredentials = _e2eEmail != '' && _e2ePassword != '';

Future<void> _ensureSupabaseInitialized() async {
  final url = const String.fromEnvironment('SUPABASE_URL').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_URL')
      : 'http://10.0.2.2:54321';
  final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : 'yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw Exception('Variables de entorno faltantes. ');
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
}

void testAuthenticationE2E() {
  setUpAll(() async {
    if (!_hasCredentials) return;
    await _ensureSupabaseInitialized();
  });

  group('E2E - Autenticacion', () {
    test('Login real con credenciales E2E', () async {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _e2eEmail,
        password: _e2ePassword,
      );

      expect(response.session, isNotNull);
      expect(response.user, isNotNull);
    }, skip: !_hasCredentials);

    test('Perfil del usuario autenticado es consultable', () async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      expect(userId, isNotNull);

      final profile = await Supabase.instance.client
          .from('profile')
          .select('id')
          .eq('id', userId!)
          .single();

      expect(profile['id'], userId);
    }, skip: !_hasCredentials);

    tearDownAll(() async {
      if (!_hasCredentials) return;
      await Supabase.instance.client.auth.signOut();
    });
  });
}

void main() => testAuthenticationE2E();

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _e2eEmail = String.fromEnvironment('E2E_TEST_EMAIL');
const _e2ePassword = String.fromEnvironment('E2E_TEST_PASSWORD');
const _hasCredentials = _e2eEmail != '' && _e2ePassword != '';

Future<void> _ensureSupabaseInitialized() async {
  await dotenv.load(fileName: '.env', isOptional: false);

  if (!Supabase.instance.isInitialized) {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_API_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
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

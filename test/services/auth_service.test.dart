import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/ports/user_port_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../mocks/db.mock.dart';
import '../mocks/logger.mock.dart';
import '../mocks/userDao.mock.dart';

void main() {
  late AppDatabase db;
  late SupabaseClient spClient;
  setUp(() {
    db = getMockDatabase();
    spClient = SupabaseClient(
      'https://your-supabase-url.supabase.co',
      'your-supabase-key',
      httpClient: MockSupabaseHttpClient(),
    );
  });
  test(
    'AuthService should register correctly when correct data is provided',
    () async {
      final UserLocalPort userDao = MockUserDao();

      final authService = AuthService(
        userLocalPort: userDao,
        supabaseClient: spClient,
        logger: MockLogger(),
        coupleService: null!,
        sharedPreferencesAsync: null!,
        sharedPreferencesWithCache: null!,
      );
      // final authService = AuthService();
      // final token = await authService.getToken('username', 'password');
      // expect(token, isNotNull);
      // expect(token, isA<String>());
    },
  );
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/features/auth/login/domain/entities/user_credentials.dart';
import 'package:pocket_union/features/auth/login/domain/entities/auth_result.dart';

import '../../../../../domain/port/utils/logger_port.dart';

part 'auth_remote_data_source.g.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResult> login(UserCredentials credentials);
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final client = ref.watch(supabaseClientProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return AuthRemoteDataSourceImpl(client, logger);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  final LoggerPort _logger;

  AuthRemoteDataSourceImpl(this._client, this._logger);

  @override
  Future<AuthResult> login(UserCredentials credentials) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw Exception('No se pudo obtener el id del usuario');
      }

      return AuthResult(userId: userId);
    } catch (e) {
      _logger.error('Ocurrió un error intentando iniciar sesión', error: e);
      rethrow;
    }
  }
}

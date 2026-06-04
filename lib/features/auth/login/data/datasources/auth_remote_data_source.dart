import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/auth/user.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/features/auth/domain/entities/user_credentials.dart';
import 'package:pocket_union/features/auth/domain/entities/auth_result.dart';

import '../../../../../domain/port/utils/logger_port.dart';

part 'auth_remote_data_source.g.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResult> login(UserCredentials credentials);
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final client = ref.watch(supabaseClientProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  final userPort = ref.watch(userDaoProvider);
  final preferences = ref.watch(sharedPreferencesProvider).requireValue;
  return AuthRemoteDataSourceImpl(client, logger, userPort, preferences);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Ref _ref;
  final SupabaseClient _client;
  final LoggerPort _logger;
  final SharedPreferences _sharedPreferences;

  AuthRemoteDataSourceImpl(
    this._ref,
    this._client,
    this._logger,
    this._sharedPreferences,
  );

  @override
  Future<AuthResult> login(UserCredentials credentials) async {
    try {
      await _sharedPreferences.setBool('isFirstLaunch', false);

      final response = await _client.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw Exception('No se pudo obtener el id del usuario');
      }

      final userProfile = DomainUser.fromMap(
        await _client
            .from('profile')
            .select('id, full_name, user_balance, last_sync, avatar_url')
            .filter('id', 'eq', userId)
            .single(),
      );

      userProfile.inCloud = true;
      final userDao = _ref.read(userDaoProvider);

      await Future.wait([
        _sharedPreferences.setBool('isInSession', true),
        _sharedPreferences.setString('idUser', userId),
        userDao.upsertUser(userProfile),
        _sharedPreferences.setString('userProfile', userProfile.toString()),
      ]);

      try {
        final coupleRows = await _client
            .from('couple')
            .select('id, user1_id, user2_id, is_usable')
            .or('user1_id.eq.$userId,user2_id.eq.$userId')
            .limit(1);

        if (coupleRows.isNotEmpty) {
          await _sharedPreferences.setString(
            'coupleId',
            coupleRows.first['id'] as String,
          );

          if (coupleRows.first['is_usable'] == CoupleUsableState.ready.value) {
            final idToSearch = userId == coupleRows.first['user1_id']
                ? coupleRows.first['user2_id'] as String?
                : coupleRows.first['user1_id'] as String?;

            if (idToSearch == null) {
              throw Exception('No se pudo determinar el usuario de la pareja');
            }

            final coupleProfile = DomainUser.fromMap(
              await _client
                  .from('profile')
                  .select()
                  .eq('id', idToSearch)
                  .single(),
            );

            coupleProfile.inCloud = true;

            await Future.wait([
              _localPort.upsertUser(coupleProfile),
              _sharedPreferences.setString(
                'coupleProfile',
                coupleProfile.toString(),
              ),
            ]);
          }
        }
      } catch (e, st) {
        userDao.upsertUser(coupleProfile);
      }

      _logger.info('AuthRemoteDataSource: Login exitoso para $userId');
      return AuthResult(userId: userId);
    } catch (e, st) {
      _logger.error(
        'Ocurrió un error intentando iniciar sesión',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

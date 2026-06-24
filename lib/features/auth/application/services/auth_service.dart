import 'package:pocket_union/core/common/domain_error.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/features/auth/login/dtos/login_dto.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:pocket_union/features/auth/domain/models/auth_result_model.dart';
import 'package:pocket_union/features/auth/domain/ports/auth_port.dart';
import 'package:pocket_union/features/auth/domain/ports/user_port_local.dart';
import 'package:pocket_union/features/auth/register/dtos/register_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common/app_response.dart';
import '../../../../core/utils/logger_provider.dart';
import '../../../../core/utils/supabase_client_provider.dart';
import '../../domain/enums/couple_usable_state.dart';
import '../dao/user_dao_local.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
Future<AuthPort> authService(Ref ref) async {
  final userLocalPort = await ref.watch(userLocalPortProvider.future);
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final logger = ref.watch(loggerProvider);
  return AuthService(
    supabaseClient: supabaseClient,
    userLocalPort: userLocalPort,
    logger: logger,
  );
}

class AuthService extends AuthPort {
  final UserLocalPort _userLocalPort;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  AuthService({
    required UserLocalPort userLocalPort,
    required SupabaseClient supabaseClient,
    required LoggerPort logger,
  }) : _logger = logger,
       _supabaseClient = supabaseClient,
       _userLocalPort = userLocalPort;

  @override
  Future<AppResponse<AuthResultModel>> login(LoginDto request) async {
    try {
      // await _sharedPreferences.setBool('isFirstLaunch', false);
      final loginRes = await _supabaseClient.auth.signInWithPassword(
        email: request.email,
        password: request.password,
      );
      if (loginRes.user?.id == null) {
        return Failure(
          DomainError(
            message: 'AuthService: Error en login, userId es null',
            code: 'login_error',
          ),
        );
      }
      UserEntity userProfile = UserEntity.fromMap(
        await _supabaseClient
            .from('profile')
            .select('id, full_name, user_balance, last_sync')
            .filter('id', 'eq', loginRes.user!.id)
            .single(),
      );
      userProfile.inCloud = true;
      var response = await Future.wait([
        // _sharedPreferences.setBool('isInSession', true),
        // _sharedPreferences.setString('idUser', loginRes.user!.id),
        _userLocalPort.upsertUser(userProfile),
        // _sharedPreferences.setString('userProfile', userProfile.toString()),
      ]);
      _logger.info('AuthService: Login exitoso para ${loginRes.user!.id}');

      // Guardar coupleId en SharedPreferences
      try {
        final coupleRows = await _supabaseClient
            .from('couple')
            .select('id, user1_id, user2_id, is_usable')
            .or(
              'user1_id.eq.${loginRes.user!.id},user2_id.eq.${loginRes.user!.id}',
            )
            .limit(1);
        if (coupleRows.isNotEmpty) {
          // await _sharedPreferences.setString(
          //   'coupleId',
          //   coupleRows.first['id'],
          // );
          if (coupleRows.first['is_usable'] == CoupleUsableState.ready.value) {
            final idToSearch = loginRes.user!.id == coupleRows.first['user1_id']
                ? coupleRows.first['user2_id']
                : coupleRows.first['user1_id'];
            UserEntity coupleProfile = UserEntity.fromMap(
              await _supabaseClient
                  .from('profile')
                  .select()
                  .eq('id', idToSearch)
                  .single(),
            );

            coupleProfile.inCloud = true;

            await Future.wait([
              _userLocalPort.upsertUser(coupleProfile),
              // _sharedPreferences.setString(
              //   'coupleProfile',
              //   coupleProfile.toString(),
              // ),
            ]);
          }
        }
      } catch (e) {
        _logger.error('AuthService: No se pudo obtener coupleId', error: e);
      }

      if (response.isNotEmpty) {
        _logger.info('AuthService: Datos de sesión guardados correctamente');
      }
      return Success(AuthResultModel(userId: loginRes.user!.id));
    } catch (error) {
      _logger.error('AuthService: Error en login', error: error);
      rethrow;
    }
  }

  @override
  Future<AppResponse<AuthResultModel>> register(RegisterDto request) async {
    try {
      var res = await _supabaseClient.auth.signUp(
        password: request.password,
        email: request.email,
        data: {'full_name': request.fullName},
      );

      if (res.user != null) {
        final domainUser = UserEntity(
          id: res.user!.id,
          fullName: request.fullName,
          balance: 0,
          inCloud: true,
        );

        var resultados = await Future.wait([
          // _sharedPreferences.setBool('isFirstLaunch', false),
          _userLocalPort.upsertUser(domainUser),
        ]);
        if (resultados.isNotEmpty) {
          _logger.info(
            'AuthService: Usuario registrado y guardado en SQLite: ${res.user!.id}',
          );
        }
      }

      _logger.info('AuthService: Registro completado');
      return Success(AuthResultModel(userId: res.user?.id ?? ''));
    } catch (e) {
      _logger.error('AuthService: Error al intentar registrarse', error: e);
      rethrow;
    }
  }
}

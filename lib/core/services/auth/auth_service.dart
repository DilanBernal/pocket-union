import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_auth_port.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends IAuthPort {
  final SupabaseClient _supabaseClient;
  final UserLocalPort _userDaoPort;
  final SharedPreferences _sharedPreferences;
  final LoggerPort _logger;

  AuthService(
    this._supabaseClient,
    this._userDaoPort,
    this._sharedPreferences,
    this._logger,
  );

  @override
  Future<AuthResponse> login(LoginDto loginRequest) async {
    try {
      await _sharedPreferences.setBool("isFirstLaunch", false);
      final loginRes = await _supabaseClient.auth.signInWithPassword(
        email: loginRequest.email,
        password: loginRequest.password,
      );
      if (loginRes.user?.id == null) {
        throw Exception("No trae el id del usuario");
      }
      DomainUser userProfile = DomainUser.fromMap(
        await _supabaseClient
            .from("profile")
            .select("id, full_name, user_balance, last_sync")
            .filter('id', 'eq', loginRes.user!.id)
            .single(),
      );
      userProfile.inCloud = true;
      var response = await Future.wait([
        _sharedPreferences.setBool("isInSession", true),
        _sharedPreferences.setString("idUser", loginRes.user!.id),
        _userDaoPort.upsertUser(userProfile),
        _sharedPreferences.setString("userProfile", userProfile.toString()),
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
          await _sharedPreferences.setString(
            'coupleId',
            coupleRows.first['id'],
          );
          if (coupleRows.first['is_usable'] == CoupleUsableState.ready.value) {
            final idToSearch = loginRes.user!.id == coupleRows.first['user1_id']
                ? coupleRows.first['user2_id']
                : coupleRows.first['user1_id'];
            DomainUser coupleProfile = DomainUser.fromMap(
              await _supabaseClient
                  .from('profile')
                  .select()
                  .eq('id', idToSearch)
                  .single(),
            );

            coupleProfile.inCloud = true;

            await Future.wait([
              _userDaoPort.upsertUser(coupleProfile),
              _sharedPreferences.setString(
                "coupleProfile",
                coupleProfile.toString(),
              ),
            ]);
          }
        }
      } catch (e) {
        _logger.error('AuthService: No se pudo obtener coupleId', error: e);
      }

      if (response.isNotEmpty) {
        _logger.info('AuthService: Datos de sesión guardados correctamente');
      }
      return loginRes;
    } catch (error) {
      _logger.error('AuthService: Error en login', error: error);
    }
    return AuthResponse();
  }

  @override
  Future<AuthResponse> register(RegisterDto registerRequest) async {
    try {
      var res = await _supabaseClient.auth.signUp(
        password: registerRequest.password,
        email: registerRequest.email,
        data: {
          'fullName': registerRequest.fullName,
          'full_name': registerRequest.fullName,
        },
      );

      // Guardar el usuario en SQLite con el ID de Supabase
      if (res.user != null) {
        final domainUser = DomainUser(
          id: res.user!.id,
          fullName: registerRequest.fullName,
          balance: 0,
          inCloud: true,
        );

        var resultados = await Future.wait([
          _sharedPreferences.setBool("isFirstLaunch", false),
          _userDaoPort.upsertUser(domainUser),
        ]);
        if (resultados.isNotEmpty) {
          _logger.info(
            'AuthService: Usuario registrado y guardado en SQLite: ${res.user!.id}',
          );
        }
      }

      _logger.info('AuthService: Registro completado');
      return res;
    } catch (e) {
      _logger.error('AuthService: Error al intentar registrarse', error: e);
      rethrow;
    }
  }

  @override
  Future<void> logout(String email) async {
    try {
      await _supabaseClient.auth.signOut();
      _logger.info('AuthService: Usuario deslogueado de Supabase');

      var resultados = await Future.wait([
        _userDaoPort.deleteAllUsers(),
        _sharedPreferences.setBool('isFirstLaunch', true),
        _sharedPreferences.setBool('isInSession', false),
        _sharedPreferences.remove('coupleId'),
        _sharedPreferences.remove('inviteCode'),
        _sharedPreferences.remove('idUser'),
        _sharedPreferences.remove('coupleProfile'),
      ]);
      if (resultados.isNotEmpty) {
        _logger.info('AuthService: SharedPreferences limpiado');
      }
    } catch (e) {
      _logger.error('AuthService: Error al hacer logout', error: e);
      rethrow;
    }
  }
}

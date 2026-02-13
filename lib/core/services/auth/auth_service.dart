import 'package:flutter/foundation.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/auth/auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/new_couple_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/port/feat/user_port.dart';

class AuthService extends AuthPort {
  final SupabaseClient _supabaseClient;
  final UserPort _userDaoPort;
  final SharedPreferences _sharedPreferences;

  AuthService(this._supabaseClient, this._userDaoPort, this._sharedPreferences);

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
      DomainUser userProfile = DomainUser.fromMap(await _supabaseClient
          .from("profile")
          .select("id, full_name, user_balance, last_sync")
          .filter('id', 'eq', loginRes.user!.id)
          .single());
      userProfile.inCloud = true;
      var sqlIteResponse = await _userDaoPort.upsertUser(userProfile);
      await _sharedPreferences.setBool("isInSession", true);
      await _sharedPreferences.setString("idUser", loginRes.user!.id);
      debugPrint(userProfile.toString());
      await _sharedPreferences.setString("userProfile", userProfile.toString());

      if (sqlIteResponse) {
        debugPrint("Se creo correctamente ${sqlIteResponse.toString()}");
      }
      return loginRes;
    } catch (error) {
      debugPrint(error.toString());
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
            'full_name': registerRequest.fullName
          });

      // Guardar el usuario en SQLite con el ID de Supabase
      if (res.user != null) {
        final domainUser = DomainUser(
            id: res.user!.id,
            fullName: registerRequest.fullName,
            balance: 0,
            inCloud: true);
        await _sharedPreferences.setBool("isFirstLaunch", false);

        await _userDaoPort.upsertUser(domainUser);
        debugPrint("Usuario registrado y guardado en SQLite: ${res.user!.id}");
      }

      debugPrint(res.toString());
      return res;
    } catch (e) {
      debugPrint("ocurrio un error al intentar registrarse ${e.toString()}");
      throw e;
    }
  }

  @override
  Future<dynamic> acceptCouple(NewCoupleDto coupleDto) {
    // TODO: implement acceptCouple
    throw UnimplementedError();
  }

  @override
  Future<void> logout(String email) async {
    try {
      // 1. Sign out from Supabase
      await _supabaseClient.auth.signOut();
      debugPrint("Usuario deslogueado de Supabase");

      // 2. Delete all users from SQLite
      final deleteResult = await _userDaoPort.deleteAllUsers();
      if (deleteResult) {
        debugPrint("Usuarios eliminados de SQLite");
      }

      // 3. Clear SharedPreferences - reset to first launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', true);
      await prefs.setBool('isInSession', false);
      debugPrint("SharedPreferences limpiado - isFirstLaunch reset");
    } catch (e) {
      debugPrint("Error al hacer logout: $e");
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/auth/auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/new_couple_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/port/feat/user_port.dart';

class AuthService extends AuthPort {
  final SupabaseClient _supabaseClient;
  final UserPort _userDaoPort;
  final _uuid = Uuid();

  AuthService(this._supabaseClient, this._userDaoPort);

  @override
  Future<AuthResponse> login(LoginDto loginRequest) async {
    try {
      final loginRes = await _supabaseClient.auth.signInWithPassword(
        email: loginRequest.email,
        password: loginRequest.password,
      );
      var sqlIteResponse = await _userDaoPort.upsertUser(DomainUser(
          id: loginRes.user!.id,
          fullName: "Prueba por ahora",
          balance: 0,
          inCloud: true));
      if (sqlIteResponse) {
        debugPrint("Se creo correctamente ${sqlIteResponse.toString()}");
      }
      return loginRes;
    } catch (error) {
      print(error);
    }
    return AuthResponse();
  }

  @override
  Future<AuthResponse> register(RegisterDto registerRequest) async {
    String sa = _uuid.v4();
    try {
      var res = await _supabaseClient.auth.signUp(
          password: registerRequest.password,
          email: registerRequest.email,
          data: {
            'fullName': registerRequest.fullName,
            'full_name': registerRequest.fullName
          });
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
  Future<dynamic> logout(String email) {
    // TODO: implement logout
    throw UnimplementedError();
  }
}

import 'package:pocket_union/domain/port/auth/auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/new_couple_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AuthService extends AuthPort {
  final SupabaseClient _supabaseClient;
  final _uuid = Uuid();

  AuthService(this._supabaseClient);

  @override
  Future<AuthResponse> login(LoginDto loginRequest) async {
    var response = await _supabaseClient.auth.signInWithPassword(
        email: loginRequest.email, password: loginRequest.password);
    print(response);
    return AuthResponse();
  }

  @override
  Future<AuthResponse> register(RegisterDto registerRequest) {
    String sa = _uuid.v4();
    print(sa);

    throw UnimplementedError();
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

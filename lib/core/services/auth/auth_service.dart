import 'package:pocket_union/domain/port/auth/auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends AuthPort {
  final SupabaseClient _supabaseClient;

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
    // TODO: implement register
    throw UnimplementedError();
  }
}

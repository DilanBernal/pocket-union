import 'package:pocket_union/domain/port/auth_port.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends AuthPort {
  final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  @override
  Future<String> login(LoginDto loginRequest) async {
    return "";
  }
}

import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthPort {
  Future<AuthResponse> login(LoginDto loginRequest);
  Future<AuthResponse> register(RegisterDto registerRequest);
  Future logout(String email);
}

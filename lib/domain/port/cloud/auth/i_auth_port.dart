import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/features/auth/register/domain/entities/register_credentials.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthPort {
  Future<AuthResponse> login(LoginDto loginRequest);
  Future<AuthResponse> register(RegisterCredentials registerRequest);
  Future logout();
}

import '../entities/user_credentials.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login(UserCredentials credentials);
}
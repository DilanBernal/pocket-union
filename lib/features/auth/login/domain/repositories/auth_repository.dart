import '../../../domain/entities/auth_result.dart';
import '../../../domain/entities/user_credentials.dart';

abstract class AuthRepository {
  Future<AuthResult> login(UserCredentials credentials);
}

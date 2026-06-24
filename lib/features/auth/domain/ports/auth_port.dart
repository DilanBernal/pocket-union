import 'package:pocket_union/features/auth/application/dtos/login_dto.dart';
import 'package:pocket_union/features/auth/domain/models/auth_result_model.dart';

abstract class AuthPort {
  Future<AuthResultModel> login(LoginDto request);
  // Future<AuthResultModel> register(String email, String fullName, String password);
}

import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/login/dtos/login_dto.dart';
import 'package:pocket_union/features/auth/domain/models/auth_result_model.dart';
import 'package:pocket_union/features/auth/register/dtos/register_dto.dart';

abstract class AuthPort {
  Future<AppResponse<AuthResultModel>> login(LoginDto request);
  Future<AppResponse<AuthResultModel>> register(RegisterDto request);
}

import 'package:pocket_union/dto/login_dto.dart';

abstract class AuthPort {
  Future<String> login(LoginDto loginRequest);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/user_credentials.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'login_usecase.g.dart';

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthResult> call(UserCredentials credentials) {
    return _repository.login(credentials);
  }
}
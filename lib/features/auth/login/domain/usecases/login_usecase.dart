import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/auth_result.dart';
import '../../../domain/entities/user_credentials.dart';
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
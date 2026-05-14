import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pocket_union/features/auth/login/domain/entities/auth_result.dart';
import 'package:pocket_union/features/auth/login/domain/entities/user_credentials.dart';
import 'package:pocket_union/features/auth/login/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthResult> login(UserCredentials credentials) {
    return _remoteDataSource.login(credentials);
  }
}
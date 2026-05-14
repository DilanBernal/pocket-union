import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pocket_union/features/auth/login/domain/entities/auth_result.dart';
import 'package:pocket_union/features/auth/login/domain/entities/user_credentials.dart';
import 'package:pocket_union/features/auth/login/domain/usecases/login_usecase.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  AsyncValue<AuthResult?> build() => const AsyncData(null);

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(loginUseCaseProvider);
      return useCase.call(UserCredentials(email: email, password: password));
    });
  }
}

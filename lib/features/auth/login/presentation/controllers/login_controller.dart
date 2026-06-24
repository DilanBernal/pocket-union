import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/auth_result_model.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  AsyncValue<AuthResultModel?> build() => const AsyncData(null);

  Future<bool> login(String email, String password) async {
    // state = const AsyncLoading();
    return true;
  }
}
import 'package:pocket_union/features/auth/application/dtos/login_dto.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/auth_result_model.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  AsyncValue<AuthResultModel?> build() => const AsyncData(null);

  Future<bool> login(LoginDto request) async {
    state = const AsyncLoading();

    try {
      final authPort = await ref.read(authServiceProvider.future);
      final response = await authPort.login(request);
      if (!ref.mounted) {
        return false;
      }
      if (response.userId.isNotEmpty) {
        state = AsyncData(response);
        return true;
      } else {
        state = const AsyncData(null);
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

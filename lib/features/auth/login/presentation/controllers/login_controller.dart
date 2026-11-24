import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/login/dtos/login_dto.dart';
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
      switch (response) {
        case Success<AuthResultModel>():
          final value = response.value;
          if (value.userId.isNotEmpty) {
            state = AsyncData(value);
            return true;
          } else {
            state = const AsyncData(null);
            return false;
          }
        case Failure<AuthResultModel>():
          final error = response.error;
          state = AsyncError(error, StackTrace.current);
          return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

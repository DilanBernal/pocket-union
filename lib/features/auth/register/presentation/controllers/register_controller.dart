import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/models/auth_result_model.dart';
import 'package:pocket_union/features/auth/register/dtos/register_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  @override
  AsyncValue<AuthResultModel?> build() => const AsyncData(null);

  Future<void> register(RegisterDto request) async {
    state = const AsyncLoading();
    try {
      final authPort = await ref.read(authServiceProvider.future);
      final response = await authPort.register(request);
      if (!ref.mounted) {
        return;
      }
      switch (response) {
        case Success<AuthResultModel>():
          final value = response.value;
          if (value.userId.isNotEmpty) {
            state = AsyncData(value);
          }
          break;
        case Failure<AuthResultModel>():
          final error = response.error;
          state = AsyncError(error, StackTrace.current);
          break;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

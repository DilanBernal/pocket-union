import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  AsyncValue build() => const AsyncData(null);

  Future<UserEntity?> getActualUser() async {
    // final userId = prefs.getString(PreferencesCacheKeys.userId);
    final logger = ref.read(loggerProvider);
    try {
      final userService = await ref.read(authServiceProvider.future);
      final userResponse = await userService.getCurrentUser();
      logger.info('User response: $userResponse');
      return switch (userResponse) {
        Success<UserEntity?>() => userResponse.value,
        Failure<UserEntity?>() => null,
      };
    } catch (e) {
      logger.error('Error getting actual user: $e');
    }
  }

  Future<UserEntity?> getActualPartnerUser() async {
    // final userId = prefs.getString(PreferencesCacheKeys.userId);
    final logger = ref.read(loggerProvider);
    try {
      final userService = await ref.read(authServiceProvider.future);
      final userResponse = await userService.getCurrentUserPartner();
      logger.info('User response: $userResponse');
      return switch (userResponse) {
        Success<UserEntity?>() => userResponse.value,
        Failure<UserEntity?>() => null,
      };
    } catch (e) {
      logger.error('Error getting actual partner user: $e');
    }
  }
}

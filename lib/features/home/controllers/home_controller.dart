import 'package:flutter/widgets.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/features/auth/application/services/auth_service.dart';
import 'package:pocket_union/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  AsyncValue build() => const AsyncData(null);

  UserEntity? _actualUser;
  UserEntity? _actualPartnerUser;

  Future<UserEntity?> getActualUser(bool forceRefresh) async {
    // final userId = prefs.getString(PreferencesCacheKeys.userId);
    if (_actualUser != null && !forceRefresh) {
      return _actualUser;
    }
    final logger = ref.read(loggerProvider);
    try {
      final userService = await ref.read(authServiceProvider.future);
      final userResponse = await userService.getCurrentUser();
      logger.info('User response: $userResponse');
      return switch (userResponse) {
        Success<UserEntity?>(): 
        break,
        Failure<UserEntity?>() => null,
      };
    } catch (e) {
      logger.error('Error getting actual user: $e');
      return null;
    }
  }

  Future<UserEntity?> getActualPartnerUser(bool forceRefresh) async {
    // final userId = prefs.getString(PreferencesCacheKeys.userId);
    if (_actualPartnerUser != null && !forceRefresh) {
      return _actualPartnerUser;
    }
    final logger = ref.read(loggerProvider);
    try {
      final userService = await ref.read(authServiceProvider.future);
      final userResponse = await userService.getCurrentUserPartner();
      logger.info('User response: $userResponse');
      return switch (userResponse) {
        Success<UserEntity?>() => _actualPartnerUser = userResponse.value,
        Failure<UserEntity?>() => null,
      };
    } catch (e) {
      logger.error('Error getting actual partner user: $e');
      return null;
    }
  }
}

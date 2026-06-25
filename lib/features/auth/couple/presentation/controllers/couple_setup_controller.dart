import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/core/common/domain_error.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/features/auth/application/services/couple_service.dart';
import 'package:pocket_union/features/auth/domain/enums/couple_usable_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'couple_setup_controller.g.dart';

@riverpod
class CoupleSetupController extends _$CoupleSetupController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> _getUserId() async {
    final prefs = await ref.read(sharedPreferencesWithCacheProvider.future);
    return prefs.getString(PreferencesCacheKeys.userId);
  }

  Future<AppResponse<String>> createCouple() async {
    state = const AsyncLoading();

    try {
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        final error = DomainError(
          message: 'No se encontró tu sesión. Inicia sesión de nuevo.',
          code: 'couple_setup_user_missing',
        );
        state = AsyncError(error, StackTrace.current);
        return Failure(error);
      }

      final coupleService = await ref.read(coupleServiceProvider.future);
      final response = await coupleService.createCouple(userId);

      switch (response) {
        case Failure():
          state = AsyncError(response.error, StackTrace.current);
          return Failure(response.error);
        case Success(value: final coupleData):
          final prefs = await ref.read(
            sharedPreferencesWithCacheProvider.future,
          );
          await prefs.setString('coupleId', coupleData.$1.id);
          await prefs.setString('inviteCode', coupleData.$2);

          state = const AsyncData(null);
          return Success(coupleData.$2);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return Failure(
        DomainError.fromException(e, 'couple_setup_create', stackTrace: st),
      );
    }
  }

  Future<AppResponse<String>> joinCoupleByCode(String inviteCode) async {
    state = const AsyncLoading();

    try {
      final code = inviteCode.trim().toUpperCase();
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        final error = DomainError(
          message: 'No se encontró tu sesión. Inicia sesión de nuevo.',
          code: 'couple_setup_user_missing',
        );
        state = AsyncError(error, StackTrace.current);
        return Failure(error);
      }

      final coupleService = await ref.read(coupleServiceProvider.future);
      final response = await coupleService.joinCoupleByCode(code, userId);

      switch (response) {
        case Failure():
          state = AsyncError(response.error, StackTrace.current);
          return Failure(response.error);
        case Success(value: final coupleEntity):
          final prefs = await ref.read(
            sharedPreferencesWithCacheProvider.future,
          );
          await prefs.setString('coupleId', coupleEntity.id);
          await prefs.setBool('isInSession', true);

          state = const AsyncData(null);
          return Success(coupleEntity.id);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return Failure(
        DomainError.fromException(e, 'couple_setup_join', stackTrace: st),
      );
    }
  }

  Future<AppResponse<bool>> checkPartnerJoined() async {
    state = const AsyncLoading();

    try {
      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) {
        final error = DomainError(
          message: 'No se encontró tu sesión. Inicia sesión de nuevo.',
          code: 'couple_setup_user_missing',
        );
        state = AsyncError(error, StackTrace.current);
        return Failure(error);
      }

      final coupleService = await ref.read(coupleServiceProvider.future);
      final response = await coupleService.getCoupleByUserId(userId);

      switch (response) {
        case Failure():
          state = AsyncError(response.error, StackTrace.current);
          return Failure(response.error);
        case Success(value: final coupleEntity)
            when coupleEntity != null &&
                coupleEntity.isUsable == CoupleUsableState.ready:
          final prefs = await ref.read(
            sharedPreferencesWithCacheProvider.future,
          );
          await prefs.setString('coupleId', coupleEntity.id);
          await prefs.setBool('isInSession', true);

          state = const AsyncData(null);
          return Success(true);
        case Success():
          state = const AsyncData(null);
          return Success(false);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return Failure(
        DomainError.fromException(e, 'couple_setup_check', stackTrace: st),
      );
    }
  }
}

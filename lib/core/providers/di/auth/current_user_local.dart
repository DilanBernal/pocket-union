// lib/core/providers/current_user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/user.dart';
import '../../data_local_providers.dart';

class CurrentUserNotifier extends AsyncNotifier<DomainUser?> {
  @override
  Future<DomainUser?> build() async {
    final userDao = ref.watch(userDaoProvider);
    return await userDao.getCurrentUser();
  }

  /// Llama esto después de login/register para no ir a la DB de nuevo
  void setUser(DomainUser user) {
    state = AsyncData(user);
  }

  /// Llama esto en logout
  void clearUser() {
    state = const AsyncData(null);
  }

  /// Llama esto si necesitas refrescar desde la DB (ej: sync con Supabase)
  Future<void> refresh() async {
    state = const AsyncLoading();
    final userDao = ref.read(userDaoProvider);
    state = await AsyncValue.guard(() => userDao.getCurrentUser());
  }

  /// Actualiza campos puntuales sin ir a la DB
  void updateUser(DomainUser Function(DomainUser current) updater) {
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(updater(current));
    }
  }
}

final currentUserProvider =
AsyncNotifierProvider<CurrentUserNotifier, DomainUser?>(
  CurrentUserNotifier.new,
);
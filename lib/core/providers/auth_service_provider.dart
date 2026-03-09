import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/core/services/auth/auth_service.dart';
import 'package:pocket_union/core/services/auth/couple_service.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/cloud/auth/auth_port.dart';
import 'package:pocket_union/domain/port/cloud/auth/couple_port.dart';

final authServiceProvider = FutureProvider<AuthPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final userSqlite = ref.watch(userDaoProvider);
  final refs = await ref.watch(sharedPreferencesProvider.future);
  return AuthService(supabaseClient, userSqlite, refs);
});

final currentUserProvider = FutureProvider<DomainUser?>((ref) async {
  final userDao = ref.watch(userDaoProvider);
  return await userDao.getCurrentUser();
});

// CoupleService provider (requiere internet para create/join)
final coupleServiceProvider = FutureProvider<CouplePort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final coupleDao = ref.watch(coupleDaoProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return CoupleService(coupleDao, supabaseClient, prefs);
});

// Estado actual del couple del usuario
final currentCoupleProvider = FutureProvider<Couple?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final userId = prefs.getString('idUser');
  if (userId == null) return null;

  try {
    final coupleService = await ref.watch(coupleServiceProvider.future);
    final couple = await coupleService.getCoupleByUserId(userId);
    if (couple != null) {
      await prefs.setString('coupleId', couple.id);
    }
    return couple;
  } catch (_) {
    final coupleDao = ref.watch(coupleDaoProvider);
    return coupleDao.getCoupleByUserId(userId);
  }
});

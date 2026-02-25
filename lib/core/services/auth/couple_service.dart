import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/port/auth/couple_port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoupleService implements CouplePort {
  final CouplePort _coupleDao;
  final SupabaseClient _supabaseClient;
  final SharedPreferences _sharedPreferences;

  CoupleService(this._coupleDao, this._supabaseClient, this._sharedPreferences);

  /// Generates a 6-character alphanumeric invite code.
  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Creates a couple in Supabase (mandatory — requires internet),
  /// then saves locally in SQLite.
  @override
  Future<Couple> createCouple(String userId, String inviteCode) async {
    // 1. Insert in Supabase — this is mandatory, needs internet
    debugPrint('CoupleService: Creando couple para userId=$userId');
    final response = await _supabaseClient
        .from('couple')
        .insert({
          'user1_id': userId,
          'invite_code': inviteCode,
          'is_usable': CoupleUsableState.waiting.value,
        })
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception(
          'No se pudo crear la pareja. Verifica tu conexión e intenta de nuevo.');
    }

    final couple = Couple.fromJson(response);

    // 2. Save locally in SQLite
    try {
      await _coupleDao.upsertCouple(couple);
    } catch (e) {
      debugPrint('CoupleService: Error guardando couple en SQLite: $e');
    }

    return couple;
  }

  /// Finds a couple by invite code in Supabase, adds user2,
  /// sets status to READY, then saves locally.
  @override
  Future<Couple> joinCoupleByCode(String inviteCode, String userId) async {
    // 1. Find couple by invite code in Supabase
    final rows = await _supabaseClient
        .from('couple')
        .select()
        .eq('invite_code', inviteCode.toUpperCase().trim())
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('No se encontró una pareja con ese código de invitación');
    }

    final coupleData = rows.first;

    if (coupleData['user2_id'] != null) {
      throw Exception('Esta invitación ya fue aceptada por otra persona');
    }

    if (coupleData['user1_id'] == userId) {
      throw Exception('No puedes unirte a tu propia invitación');
    }

    // 2. Update couple in Supabase: set user2 + READY
    debugPrint(
        'CoupleService: Uniendo userId=$userId a couple=${coupleData['id']}');
    final updated = await _supabaseClient
        .from('couple')
        .update({
          'user2_id': userId,
          'is_usable': CoupleUsableState.ready.value,
        })
        .eq('id', coupleData['id'])
        .select()
        .maybeSingle();
    if (updated == null) {
      throw Exception(
          'No se pudo unir a la pareja. Es posible que ya haya sido tomada o '
          'que no tengas permisos. Intenta de nuevo.');
    }

    final couple = Couple.fromJson(updated);

    // 3. Save locally in SQLite
    try {
      Future.wait([
        _coupleDao.upsertCouple(couple),
        _sharedPreferences.setString('coupleId', couple.id)
      ]);
    } catch (e) {
      debugPrint('CoupleService: Error guardando couple en SQLite: $e');
    }

    return couple;
  }

  /// Gets couple from Supabase first, falls back to local SQLite.
  @override
  Future<Couple?> getCoupleByUserId(String userId) async {
    try {
      final rows = await _supabaseClient
          .from('couple')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .limit(1);

      if (rows.isNotEmpty) {
        final couple = Couple.fromJson(rows.first);
        // Sync to local
        try {
          await _coupleDao.upsertCouple(couple);
        } catch (_) {}
        return couple;
      }
    } catch (e) {
      debugPrint('CoupleService: Supabase fetch failed, trying local: $e');
    }

    // Fallback to local
    return _coupleDao.getCoupleByUserId(userId);
  }

  @override
  Future<Couple?> getCoupleByInviteCode(String inviteCode) async {
    try {
      final rows = await _supabaseClient
          .from('couple')
          .select()
          .eq('invite_code', inviteCode.toUpperCase().trim())
          .limit(1);

      if (rows.isNotEmpty) {
        return Couple.fromJson(rows.first);
      }
    } catch (e) {
      debugPrint('CoupleService: Error buscando couple por código: $e');
    }

    return _coupleDao.getCoupleByInviteCode(inviteCode);
  }

  @override
  Future<bool> upsertCouple(Couple couple) async {
    return _coupleDao.upsertCouple(couple);
  }

  @override
  Future<bool> deleteCouple(String coupleId) async {
    return _coupleDao.deleteCouple(coupleId);
  }
}

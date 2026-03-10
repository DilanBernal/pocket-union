import 'dart:math';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_couple_port.dart';
import 'package:pocket_union/domain/port/local/couple_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoupleService implements ICouplePort {
  final CoupleLocalPort _coupleDao;
  final SupabaseClient _supabaseClient;
  final SharedPreferences _sharedPreferences;
  final LoggerPort _logger;

  CoupleService(
    this._coupleDao,
    this._supabaseClient,
    this._sharedPreferences,
    this._logger,
  );

  /// Generates a 6-character alphanumeric invite code.
  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Future<Couple> createCouple(String userId, String inviteCode) async {
    _logger.info('CoupleService: Creando couple para userId=$userId');
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
        'No se pudo crear la pareja. Verifica tu conexión e intenta de nuevo.',
      );
    }

    final couple = Couple.fromJson(response);

    try {
      await _coupleDao.upsertCouple(couple);
    } catch (e) {
      _logger.error(
        'CoupleService: Error guardando couple en SQLite',
        error: e,
      );
    }

    return couple;
  }

  @override
  Future<Couple> joinCoupleByCode(String inviteCode, String userId) async {
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

    _logger.info(
      'CoupleService: Uniendo userId=$userId a couple=${coupleData['id']}',
    );
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
        'que no tengas permisos. Intenta de nuevo.',
      );
    }

    final couple = Couple.fromJson(updated);

    try {
      Future.wait([
        _coupleDao.upsertCouple(couple),
        _sharedPreferences.setString('coupleId', couple.id),
      ]);
    } catch (e) {
      _logger.error(
        'CoupleService: Error guardando couple en SQLite',
        error: e,
      );
    }

    return couple;
  }

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
        try {
          await _coupleDao.upsertCouple(couple);
        } catch (_) {}
        return couple;
      }
    } catch (e) {
      _logger.error(
        'CoupleService: Supabase fetch failed, trying local',
        error: e,
      );
    }

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
      _logger.error(
        'CoupleService: Error buscando couple por código',
        error: e,
      );
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

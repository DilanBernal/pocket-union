import 'dart:math';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/application/dao/couple_dao_local.dart';
import 'package:pocket_union/features/auth/domain/entities/couple_entity.dart';
import 'package:pocket_union/features/auth/domain/enums/couple_usable_state.dart';
import 'package:pocket_union/features/auth/domain/ports/couple_port.dart';
import 'package:pocket_union/features/auth/domain/ports/couple_port_local.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/common/domain_error.dart';
import '../../../../core/ports/logger_port.dart';
import '../../../../core/utils/logger_provider.dart';
import '../../../../core/utils/supabase_client_provider.dart';

part 'couple_service.g.dart';

@Riverpod(keepAlive: true)
Future<CouplePort> coupleService(Ref ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final logger = ref.watch(loggerProvider);
  final couplePort = await ref.watch(coupleDaoLocalProvider.future);
  return CoupleService(
    supabaseClient: supabaseClient,
    logger: logger,
    coupleService: couplePort,
  );
}

class CoupleService implements CouplePort {
  final CouplePortLocal _coupleDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  CoupleService({
    required SupabaseClient supabaseClient,
    required LoggerPort logger,
    required CouplePortLocal coupleService,
  }) : _coupleDao = coupleService,
       _supabaseClient = supabaseClient,
       _logger = logger;

  /// Generates a 6-character alphanumeric invite code.
  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Future<AppResponse<CoupleEntity>> createCoupleWithInviteCode(
    String userId,
    String inviteCode,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<AppResponse<(CoupleEntity, String)>> createCouple(
    String userId,
  ) async {
    try {
      var inviteCode = generateInviteCode();

      var alreadyExistsCoupleWithCode = await _supabaseClient
          .from('couple_invite_codes')
          .select('code')
          .eq('code', inviteCode)
          .limit(1)
          .maybeSingle();

      if (alreadyExistsCoupleWithCode != null) {
        while (alreadyExistsCoupleWithCode != null) {
          inviteCode = generateInviteCode();
          alreadyExistsCoupleWithCode = await _supabaseClient
              .from('couple_invite_codes')
              .select('code')
              .eq('code', inviteCode)
              .limit(1)
              .maybeSingle();
        }
      }

      final couple = CoupleEntity(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        user1Id: userId,
        isUsable: CoupleUsableState.waiting,
      );
      final response = await _supabaseClient
          .from('couple')
          .insert(couple.toJson())
          .select()
          .maybeSingle();

      await _supabaseClient.from('couple_invite_codes').insert({
        'code': inviteCode,
        'id': response!['id'],
      });

      await _coupleDao.upsertCouple(couple);

      return Success((couple, inviteCode));
    } catch (e, st) {
      _logger.error(
        'Error creating couple for userId: $userId',
        error: e,
        stackTrace: st,
      );
      return Failure(DomainError.fromException(e, ''));
    }
  }

  @override
  Future<bool> deleteCouple(String coupleId) {
    // TODO: implement deleteCouple
    throw UnimplementedError();
  }

  @override
  Future<AppResponse<CoupleEntity?>> getCoupleByInviteCode(String inviteCode) {
    // TODO: implement getCoupleByInviteCode
    throw UnimplementedError();
  }

  @override
  Future<AppResponse<CoupleEntity?>> getCoupleByUserId(String userId) {
    // TODO: implement getCoupleByUserId
    throw UnimplementedError();
  }

  @override
  Future<AppResponse<CoupleEntity>> joinCoupleByCode(
    String inviteCode,
    String userId,
  ) {
    // TODO: implement joinCoupleByCode
    throw UnimplementedError();
  }

  @override
  Future<bool> upsertCouple(
    CoupleEntity couple, {
    bool inNetwork = false,
  }) async {
    try {
      if (inNetwork) {
        try {
          await _supabaseClient.from('couple').upsert(couple.toJson());
          _logger.info('Upserting couple in network: ${couple.id}');
        } catch (_) {}
      }
      await _coupleDao.upsertCouple(couple);
      return _coupleDao.upsertCouple(couple);
    } catch (e, st) {
      _logger.error(
        'Error upserting couple: ${couple.id}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<AppResponse<CoupleEntity?>> getCoupleByUserIdInNetwork(
    String userId,
  ) async {
    try {
      final rows = await _supabaseClient
          .from('couple')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .maybeSingle();

      if (rows != null) {
        try {
          final couple = CoupleEntity.fromMap(rows);
          await _coupleDao.upsertCouple(couple);
          return Success(couple);
        } catch (e, st) {
          _logger.error(
            'Ocurrió un error al guardar la couple',
            error: e,
            stackTrace: st,
          );
        }
      }
      return Success(null);
    } catch (e, st) {
      _logger.error(
        'Error getting couple by userId in network: $userId',
        error: e,
        stackTrace: st,
      );
      return Failure(DomainError.fromException(e, ''));
    }
  }
}

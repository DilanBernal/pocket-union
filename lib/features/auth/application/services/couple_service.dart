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

      var alreadyExistsCoupleWithCode = await _getCoupleCodeFunction(
        inviteCode,
        userId,
      );

      CoupleEntity? couple;

      if (alreadyExistsCoupleWithCode != null) {
        couple = await _validateCoupleCreation(
          alreadyExistsCoupleWithCode,
          userId,
          inviteCode,
          couple,
        );
      }

      if (couple == null) {
        couple = CoupleEntity(
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
      } else {
        inviteCode = alreadyExistsCoupleWithCode?.inviteCode ?? inviteCode;
      }

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

  Future<_CoupleCodeFunctionResponse?> _getCoupleCodeFunction(
    String inviteCode,
    String userId,
  ) async {
    var response = await _supabaseClient.rpc(
      'get_couple_invite_code_with_existence',
      params: {'p_couple_code': inviteCode, 'p_user_id': userId},
    );
    if (response == null || response.isEmpty) {
      return null;
    }
    response = response[0];

    return _CoupleCodeFunctionResponse()
      ..coupleId = response['couple_id']
      ..inviteCode = response['invite_code']
      ..userId = response['user_id']
      ..userPosition = response['user_position'];
  }

  Future<CoupleEntity?> _validateCoupleCreation(
    _CoupleCodeFunctionResponse? alreadyExistsCoupleWithCode,
    String userId,
    String inviteCode,
    CoupleEntity? couple,
  ) async {
    bool canExit = false;
    while (alreadyExistsCoupleWithCode != null && !canExit) {
      if (alreadyExistsCoupleWithCode.userId == userId) {
        final coupleRow = await _supabaseClient
            .from('couple')
            .select()
            .eq(
              alreadyExistsCoupleWithCode.userPosition == 1
                  ? 'user1_id'
                  : alreadyExistsCoupleWithCode.userPosition == 2
                  ? 'user2_id'
                  : 'id',
              userId,
            )
            .limit(1)
            .maybeSingle();
        if (coupleRow == null) break;
        couple = CoupleEntity.fromMap(coupleRow);
        break;
      } else {
        inviteCode = generateInviteCode();
        alreadyExistsCoupleWithCode = await _getCoupleCodeFunction(
          inviteCode,
          userId,
        );
      }
    }
    return couple;
  }
}

class _CoupleCodeFunctionResponse {
  String? coupleId;
  String? inviteCode;
  String? userId;
  int? userPosition;
  _CoupleCodeFunctionResponse();
}

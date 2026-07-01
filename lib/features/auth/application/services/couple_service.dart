import 'dart:async';
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
  ) async {
    try {
      // Validate invite code uniqueness
      var alreadyExistsCoupleWithCode = await _getCoupleCodeFunction(
        inviteCode,
        userId,
      );

      if (alreadyExistsCoupleWithCode != null) {
        _logger.error('Invite code already exists: $inviteCode');
        return Failure(
          DomainError.fromException(
            Exception('Invite code already in use'),
            'The code $inviteCode already exists',
          ),
        );
      }

      // Create couple locally
      final couple = CoupleEntity(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        user1Id: userId,
        isUsable: CoupleUsableState.waiting,
      );

      await _coupleDao.upsertCouple(couple);

      // Sync to network (async, non-blocking)
      unawaited(
        Future(() async {
          try {
            await _supabaseClient.from('couple').insert(couple.toJson());
            await _supabaseClient.from('couple_invite_codes').insert({
              'code': inviteCode,
              'id': couple.id,
            });
            _logger.info(
              'Couple created in network with preset code: ${couple.id}',
            );
          } catch (e, st) {
            _logger.error(
              'Error syncing couple creation to network',
              error: e,
              stackTrace: st,
            );
          }
        }),
      );

      return Success(couple);
    } catch (e, st) {
      _logger.error(
        'Error creating couple with invite code for userId: $userId',
        error: e,
        stackTrace: st,
      );
      return Failure(DomainError.fromException(e, ''));
    }
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
  Future<bool> deleteCouple(String coupleId) async {
    try {
      // Delete locally (soft delete)
      final result = await _coupleDao.deleteCouple(coupleId);

      if (!result) {
        _logger.warning('Failed to delete couple locally: $coupleId');
        return false;
      }

      // Sync to network (async, non-blocking)
      unawaited(
        Future(() async {
          try {
            // Soft delete in Supabase
            await _supabaseClient
                .from('couple')
                .update({'is_deleted': true})
                .eq('id', coupleId);

            // Clean up invite codes
            await _supabaseClient
                .from('couple_invite_codes')
                .delete()
                .eq('id', coupleId);

            _logger.info('Couple deleted in network: $coupleId');
          } catch (e, st) {
            _logger.error(
              'Error syncing couple deletion to network',
              error: e,
              stackTrace: st,
            );
          }
        }),
      );

      return true;
    } catch (e, st) {
      _logger.error(
        'Error deleting couple: $coupleId',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<AppResponse<CoupleEntity?>> getCoupleByInviteCode(
    String inviteCode,
  ) async {
    try {
      // Query couple_invite_codes table
      final codeRow = await _supabaseClient
          .from('couple_invite_codes')
          .select()
          .eq('code', inviteCode)
          .maybeSingle();

      if (codeRow == null) {
        _logger.info('Invite code not found: $inviteCode');
        return const Success(null);
      }

      final coupleId = codeRow['id'] as String?;
      if (coupleId == null) {
        _logger.warning('Invite code has no associated couple ID');
        return const Success(null);
      }

      // Fetch couple from couple table
      final coupleRow = await _supabaseClient
          .from('couple')
          .select()
          .eq('id', coupleId)
          .maybeSingle();

      if (coupleRow == null) {
        _logger.warning('Couple not found for code: $inviteCode');
        return const Success(null);
      }

      // Map to CoupleEntity and sync locally
      final couple = CoupleEntity.fromMap(coupleRow);
      await _coupleDao.upsertCouple(couple);

      return Success(couple);
    } catch (e, st) {
      _logger.error(
        'Error getting couple by invite code: $inviteCode',
        error: e,
        stackTrace: st,
      );
      return Failure(DomainError.fromException(e, ''));
    }
  }

  @override
  Future<AppResponse<CoupleEntity?>> getCoupleByUserId(
    String userId, {
    bool inNetwork = false,
  }) async {
    try {
      var couple = await _coupleDao.getCoupleByUserId(userId);
      if (couple != null && !inNetwork) {
        return Success(couple);
      }
      final coupleRow = await _supabaseClient
          .from('couple')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .single()
          .limit(1);

      if (couple?.user1Id != coupleRow['user1_id']) {
        couple = couple!.copyWith(user1Id: coupleRow['user1_id']);
      }
      if (couple?.user2Id != coupleRow['user2_id']) {
        couple = couple!.copyWith(user2Id: coupleRow['user2_id']);
      }
      if (couple?.isUsable != coupleRow['is_usable']) {
        couple = couple!.copyWith(
          isUsable: CoupleUsableState.fromString(
            coupleRow['is_usable'] ??
                    couple.user1Id != null && couple.user2Id != null
                ? 'ACTIVE'
                : 'WAITING',
          ),
        );
      }

      return Success(couple);
    } catch (e, st) {
      _logger.error(
        'Error getting couple by userId: $userId',
        error: e,
        stackTrace: st,
      );
      return Failure(DomainError.fromException(e, ''));
    }
  }

  @override
  Future<AppResponse<CoupleEntity>> joinCoupleByCode(
    String inviteCode,
    String userId,
  ) async {
    try {
      // Validación rápida local
      final localCouple = await _coupleDao.getCoupleByUserId(userId);

      if (localCouple != null &&
          localCouple.user1Id != null &&
          localCouple.user2Id != null) {
        return Failure(
          DomainError.fromException(
            Exception('User already in a couple'),
            'You are already in a couple.',
          ),
        );
      }

      // Toda la lógica ocurre en PostgreSQL
      await _supabaseClient.rpc(
        'join_couple_by_invite_code',
        params: {'p_invite_code': inviteCode},
      );

      final coupleResponse = await getCoupleByUserIdInNetwork(userId);

      if (coupleResponse is Failure ||
          (coupleResponse is Success &&
              (coupleResponse as Success<CoupleEntity?>).value == null)) {
        return Failure(
          DomainError.fromException(
            Exception('Failed to fetch couple after joining'),
            'Failed to fetch couple after joining.',
          ),
        );
      }

      final couple = (coupleResponse as Success<CoupleEntity?>).value;
      await _coupleDao.upsertCouple(couple!);

      _logger.info('User joined couple: userId=$userId, coupleId=${couple.id}');

      return Success((coupleResponse as Success).value);
    } on PostgrestException catch (e, st) {
      _logger.error(
        'RPC join_couple_by_invite_code failed',
        error: e,
        stackTrace: st,
      );

      return Failure(DomainError.fromException(e, e.message));
    } catch (e, st) {
      _logger.error(
        'Unexpected error joining couple',
        error: e,
        stackTrace: st,
      );

      return Failure(
        DomainError.fromException(e, 'Unexpected error joining couple.'),
      );
    }
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
          .limit(1)
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

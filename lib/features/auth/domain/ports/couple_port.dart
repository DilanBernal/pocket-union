import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/domain/entities/couple_entity.dart';

abstract class CouplePort {
  Future<AppResponse<CoupleEntity>> createCoupleWithInviteCode(
    String userId,
    String inviteCode,
  );
  Future<AppResponse<(CoupleEntity, String)>> createCouple(String userId);

  Future<AppResponse<CoupleEntity>> joinCoupleByCode(
    String inviteCode,
    String userId,
  );

  Future<AppResponse<CoupleEntity?>> getCoupleByUserId(
    String userId, {
    bool inNetwork = false,
  });

  Future<AppResponse<CoupleEntity?>> getCoupleByInviteCode(String inviteCode);

  Future<AppResponse<CoupleEntity?>> getCoupleByUserIdInNetwork(String userId);

  Future<bool> upsertCouple(CoupleEntity couple, {bool inNetwork = false});

  Future<bool> deleteCouple(String coupleId);
}

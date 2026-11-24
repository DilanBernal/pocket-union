import '../entities/couple_entity.dart';

abstract class CouplePortLocal {
  Future<CoupleEntity> createCouple(String userId, String inviteCode);

  Future<CoupleEntity> joinCoupleByCode(String inviteCode, String userId);

  Future<CoupleEntity?> getCoupleById(String id);

  Future<CoupleEntity?> getCoupleByUserId(String userId);

  Future<List<CoupleEntity>> getByFilter(CoupleEntity filter);

  Future<bool> upsertCouple(CoupleEntity couple);

  Future<bool> deleteCouple(String coupleId);
}

import 'package:pocket_union/domain/models/couple.dart';

abstract class ICouplePort {
  Future<Couple> createCouple(String userId, String inviteCode);

  Future<Couple> joinCoupleByCode(String inviteCode, String userId);

  Future<Couple?> getCoupleByUserId(String userId);

  Future<Couple?> getCoupleByInviteCode(String inviteCode);

  Future<bool> upsertCouple(Couple couple);

  Future<bool> deleteCouple(String coupleId);
}

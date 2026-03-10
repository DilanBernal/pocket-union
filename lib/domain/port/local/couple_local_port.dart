import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/dto/filter/couple_filter_dto.dart';

abstract class CoupleLocalPort {
  Future<Couple> createCouple(String userId, String inviteCode);

  Future<Couple> joinCoupleByCode(String inviteCode, String userId);

  Future<Couple?> getCoupleById(String id);

  Future<Couple?> getCoupleByUserId(String userId);

  Future<Couple?> getCoupleByInviteCode(String inviteCode);

  Future<List<Couple>> getByFilter(CoupleFilterDto filter);

  Future<bool> upsertCouple(Couple couple);

  Future<bool> deleteCouple(String coupleId);
}

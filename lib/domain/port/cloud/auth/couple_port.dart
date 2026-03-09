import 'package:pocket_union/domain/models/couple.dart';

abstract class CouplePort {
  /// Creates a new couple with user1 and an invite code. Returns the created Couple.
  Future<Couple> createCouple(String userId, String inviteCode);

  /// Joins an existing couple as user2 using the invite code. Returns the updated Couple.
  Future<Couple> joinCoupleByCode(String inviteCode, String userId);

  /// Gets the couple for the given userId (as user1 or user2).
  Future<Couple?> getCoupleByUserId(String userId);

  /// Gets a couple by its invite code.
  Future<Couple?> getCoupleByInviteCode(String inviteCode);

  /// Saves/updates a couple locally.
  Future<bool> upsertCouple(Couple couple);

  /// Deletes the local couple data.
  Future<bool> deleteCouple(String coupleId);
}

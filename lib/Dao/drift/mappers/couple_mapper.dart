import 'package:drift/drift.dart';

import '../../../domain/enum/couple_usable_state.dart';
import '../../../domain/models/couple.dart';
import '../app_database.dart' as drift;

class CoupleMapper {
  Couple toDomain(drift.Couple data) {
    return Couple(
      id: data.id,
      createdAt: data.createdAt,
      user1Id: data.user1Id,
      user2Id: data.user2Id,
      inviteCode: data.inviteCode,
      isUsable: CoupleUsableState.fromString(data.isUsable),
    );
  }

  drift.CouplesCompanion toCompanion(Couple couple) {
    final now = DateTime.now().toUtc();
    return drift.CouplesCompanion.insert(
      id: couple.id,
      user1Id: Value(couple.user1Id),
      user2Id: Value(couple.user2Id),
      inviteCode: Value(couple.inviteCode),
      isUsable: Value(couple.isUsable.value),
      createdAt: Value(couple.createdAt),
      syncStatus: const Value('synced'),
      localUpdatedAt: Value(now),
      isDeleted: const Value(false),
    );
  }
}
